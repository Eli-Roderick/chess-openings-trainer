import 'package:chess_core/src/training/accuracy.dart';
import 'package:chess_core/src/training/attribution.dart';
import 'package:chess_core/src/training/constants.dart';
import 'package:chess_core/src/training/run.dart';
import 'package:chess_core/src/training/srs.dart';
import 'package:chess_core/src/training/weak_pool.dart';
import 'package:meta/meta.dart';

/// Settings that change derived stats.
@immutable
final class DeriveSettings {
  /// Creates settings (defaults per docs/plan/01-product-spec.md §10).
  const new({
    this.weakEnterBelow = defaultWeakEnterBelow,
    this.weakExitCleanRuns = defaultWeakExitCleanRuns,
  });

  /// Weak pool entry threshold.
  final double weakEnterBelow;

  /// Clean runs in a row needed to leave the weak pool.
  final int weakExitCleanRuns;
}

/// Derived statistics of one line, shaped like the `line_stats` table
/// (docs/plan/03-data-model.md §2.7).
@immutable
final class LineStats {
  /// Creates stats.
  const new({
    required this.lineKey,
    required this.archived,
    required this.runCount,
    required this.accuracy,
    required this.lastPlayedAt,
    required this.weak,
    required this.srs,
  });

  /// Line key (current or archived).
  final String lineKey;

  /// True if the key is not a current line.
  final bool archived;

  /// Eligible runs, all time (direct and inherited).
  final int runCount;

  /// Last-10 accuracy, or null with no eligible runs.
  final double? accuracy;

  /// Latest `finishedAt` of an eligible run.
  final int? lastPlayedAt;

  /// Weak-pool state (always outside for archived keys).
  final WeakPoolState weak;

  /// SRS state (initial for archived keys).
  final SrsState srs;

  /// `line_stats.inWeakPool`.
  bool get inWeakPool => weak.inPool;

  /// `line_stats.weakCleanStreak`.
  int get weakCleanStreak => weak.cleanStreak;

  @override
  bool operator ==(Object other) =>
      other is LineStats &&
      other.lineKey == lineKey &&
      other.archived == archived &&
      other.runCount == runCount &&
      other.accuracy == accuracy &&
      other.lastPlayedAt == lastPlayedAt &&
      other.weak == weak &&
      other.srs == srs;

  @override
  int get hashCode => Object.hash(
    lineKey,
    archived,
    runCount,
    accuracy,
    lastPlayedAt,
    weak,
    srs,
  );

  @override
  String toString() =>
      'LineStats($lineKey${archived ? ' archived' : ''}, runs $runCount, '
      'acc $accuracy, last $lastPlayedAt, $weak, $srs)';
}

/// Derives the stats of every current line and of every archived key that
/// has runs (docs/plan/04-algorithms.md §8). Runs may be in any order; they
/// are sorted by `finishedAt`, then `id`. Current lines come first in
/// [lines] order, then archived keys sorted.
List<LineStats> deriveRepertoire({
  required List<LineRef> lines,
  required Iterable<RunRecord> runs,
  DeriveSettings settings = const DeriveSettings(),
}) => _derive(lines: lines, runs: runs, settings: settings, only: null);

/// Incremental derivation: the stats of [keys] only (current or archived),
/// identical to their entries in [deriveRepertoire]. Unknown keys without
/// runs are omitted.
List<LineStats> deriveLines({
  required Iterable<String> keys,
  required List<LineRef> lines,
  required Iterable<RunRecord> runs,
  DeriveSettings settings = const DeriveSettings(),
}) => _derive(lines: lines, runs: runs, settings: settings, only: keys.toSet());

List<LineStats> _derive({
  required List<LineRef> lines,
  required Iterable<RunRecord> runs,
  required DeriveSettings settings,
  required Set<String>? only,
}) {
  bool wanted(String key) => only == null || only.contains(key);
  final index = LineIndex(lines);
  final current = {for (final l in lines) l.key};
  final eligible = <String, List<RunRecord>>{};
  final direct = <String, List<RunRecord>>{};
  final archivedRuns = <String, List<RunRecord>>{};

  final sorted = runs.toList()..sort(compareRuns);
  for (final run in sorted) {
    switch (index.attribute(ucis: run.ucis, lineKey: run.lineKey)) {
      case DirectAttribution(:final key):
        if (!wanted(key)) continue;
        (direct[key] ??= []).add(run);
        if (run.isEligible) (eligible[key] ??= []).add(run);
      case InheritedAttribution(:final keys):
        if (!run.isEligible) continue;
        for (final key in keys) {
          if (wanted(key)) (eligible[key] ??= []).add(run);
        }
      case ArchivedAttribution(:final key):
        if (wanted(key)) (archivedRuns[key] ??= []).add(run);
    }
  }

  LineStats stats(String key, List<RunRecord> elig, {required bool archived}) =>
      LineStats(
        lineKey: key,
        archived: archived,
        runCount: elig.length,
        accuracy: lineAccuracy(elig),
        lastPlayedAt: elig.isEmpty ? null : elig.last.finishedAt,
        weak: archived
            ? WeakPoolState.outside
            : replayWeakPool(
                elig,
                enterBelow: settings.weakEnterBelow,
                exitCleanRuns: settings.weakExitCleanRuns,
              ),
        srs: archived
            ? SrsState.initial
            : replaySrs(key, direct[key] ?? const []),
      );

  final archivedKeys =
      archivedRuns.keys.where((k) => !current.contains(k)).toList()..sort();
  return [
    for (final l in lines)
      if (wanted(l.key))
        stats(l.key, eligible[l.key] ?? const [], archived: false),
    for (final key in archivedKeys)
      stats(key, [
        for (final r in archivedRuns[key]!)
          if (r.isEligible) r,
      ], archived: true),
  ];
}
