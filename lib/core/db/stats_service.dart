import 'dart:async';
import 'dart:isolate';

import 'package:chess_core/chess_core.dart';
import 'package:logging/logging.dart';
import 'package:repertoire_trainer/core/db/repositories/repertoire_repository.dart';
import 'package:repertoire_trainer/core/db/repositories/run_repository.dart';
import 'package:repertoire_trainer/core/db/repositories/stats_repository.dart';
import 'package:repertoire_trainer/core/settings/app_settings.dart';

final _log = Logger('stats');

/// Keeps `line_stats` derived from runs (docs/plan/04-algorithms.md §8):
/// incrementally after a run, fully after an import or a threshold change.
final class StatsService {
  /// Creates the service.
  new({
    required this._repertoires,
    required this._runs,
    required this._stats,
    required this._settings,
    this.isolateThreshold = 2000,
  });

  final RepertoireRepository _repertoires;
  final RunRepository _runs;
  final StatsRepository _stats;
  final Future<AppSettings> Function() _settings;

  /// Derivations over more runs than this run in a background isolate.
  final int isolateThreshold;

  StreamSubscription<AppSettings>? _settingsSub;

  /// Stores [run] and re-derives only the lines it affects.
  Future<void> recordRun(RunRecord run) async {
    await _runs.insertRun(run);
    await _stats.addPlyResults(run);
    final lines = await _repertoires.lineRefs(run.repertoireId);
    final keys = switch (LineIndex(lines)
        .attribute(ucis: run.ucis, lineKey: run.lineKey)) {
      DirectAttribution(:final key) => [key],
      InheritedAttribution(:final keys) => keys,
      ArchivedAttribution(:final key) => [key],
    };
    final runs = await _runs.runsForRepertoire(run.repertoireId);
    final settings = (await _settings()).deriveSettings;
    final derived = await _maybeIsolate(
      runs.length,
      () =>
          deriveLines(keys: keys, lines: lines, runs: runs, settings: settings),
    );
    await _stats.upsertDerived(run.repertoireId, derived);
  }

  /// Re-derives every line of [repertoireId] (after import, re-import or a
  /// sync merge).
  Future<void> rebuildRepertoire(String repertoireId) async {
    final lines = await _repertoires.lineRefs(repertoireId);
    final runs = await _runs.runsForRepertoire(repertoireId);
    final settings = (await _settings()).deriveSettings;
    final derived = await _maybeIsolate(
      runs.length,
      () => deriveRepertoire(lines: lines, runs: runs, settings: settings),
    );
    await _stats.replaceDerived(repertoireId, derived);
    await _stats.rebuildPlyStats(repertoireId);
  }

  /// Re-derives every repertoire.
  Future<void> rebuildAll() async {
    for (final id in await _repertoires.allIds()) {
      await rebuildRepertoire(id);
    }
  }

  /// Rebuilds everything whenever a setting that changes derived stats (weak
  /// thresholds, day start) changes in [settings].
  void listenToSettings(Stream<AppSettings> settings) {
    unawaited(_settingsSub?.cancel());
    (int, int, int)? last;
    _settingsSub = settings.listen((s) {
      final key = (
        s.weakEnterBelowPercent,
        s.weakExitCleanRuns,
        s.dayStartHour,
      );
      final previous = last;
      last = key;
      if (previous != null && previous != key) {
        unawaited(
          rebuildAll().catchError((Object e, StackTrace st) {
            _log.severe('Re-derivation after settings change failed', e, st);
          }),
        );
      }
    });
  }

  /// Stops listening to settings.
  Future<void> dispose() async => await _settingsSub?.cancel();

  Future<List<LineStats>> _maybeIsolate(
    int runCount,
    List<LineStats> Function() derive,
  ) async => runCount > isolateThreshold ? await Isolate.run(derive) : derive();
}
