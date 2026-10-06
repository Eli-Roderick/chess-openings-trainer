import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repertoire_trainer/app/layout/adaptive_layout.dart';
import 'package:repertoire_trainer/core/db/database_info.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/core/diagnostics/derivation_timings.dart';
import 'package:repertoire_trainer/core/diagnostics/deviation_timings.dart';
import 'package:repertoire_trainer/core/diagnostics/drill_latency.dart';
import 'package:repertoire_trainer/core/diagnostics/frame_stats.dart';
import 'package:repertoire_trainer/core/diagnostics/log_setup.dart';
import 'package:repertoire_trainer/core/diagnostics/startup_timings.dart';
import 'package:repertoire_trainer/core/engine/engine_providers.dart';
import 'package:repertoire_trainer/core/errors/describe_error.dart';
import 'package:repertoire_trainer/core/files/providers.dart';
import 'package:repertoire_trainer/core/import/import_benchmark.dart';
import 'package:repertoire_trainer/core/import/import_runner.dart';
import 'package:repertoire_trainer/core/settings/app_settings.dart';
import 'package:repertoire_trainer/core/sync/drive_transport.dart';
import 'package:repertoire_trainer/core/sync/sync_controller.dart';
import 'package:repertoire_trainer/l10n/gen/app_localizations.dart';
import 'package:uci_engine/uci_engine.dart';

/// Hidden Diagnostics (docs/plan/10-testing-and-quality.md §6): startup
/// timings, frames, drill latency, deviation jobs, the engine, sync and the
/// log export.
class DiagnosticsScreen extends StatelessWidget {
  /// Creates the screen.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = StartupTimings.instance;
    String ms(Duration? d) =>
        d == null ? l10n.notAvailable : l10n.msValue('${d.inMilliseconds}');
    final frames = FrameStats.instance;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.diagnosticsTitle)),
      body: AdaptiveLayout(
        phone: ListView(
          children: [
            _Header(l10n.startupTimings),
            _Value(l10n.processToMain, ms(t.processToMain)),
            _Value(l10n.mainToRunApp, ms(t.mainToRunApp)),
            _Value(l10n.runAppToFirstFrame, ms(t.runAppToFirstFrame)),
            _Value(l10n.firstFrameToHome, ms(t.firstFrameToHomeData)),
            _Value(l10n.mainToHome, ms(t.mainToHomeData)),
            _Header(l10n.framesTitle),
            ListenableBuilder(
              listenable: frames,
              builder: (context, _) => Column(
                children: [
                  _Value(
                    l10n.framesBudget,
                    l10n.msValue(
                      (frames.budget.inMicroseconds / 1000).toStringAsFixed(1),
                    ),
                  ),
                  _Value(l10n.framesCount, '${frames.count}'),
                  _Value(l10n.framesJanky, '${frames.janky}'),
                  _Value(
                    l10n.framesOverBudget,
                    l10n.percentDecimal(
                      frames.overBudgetPercent.toStringAsFixed(2),
                    ),
                  ),
                  _Value(l10n.framesSlowBuilds, '${frames.slowBuilds}'),
                  _Value(l10n.framesSlowRasters, '${frames.slowRasters}'),
                  _Value(
                    l10n.framesAverageBuild,
                    l10n.msValue(
                      (frames.averageBuild.inMicroseconds / 1000)
                          .toStringAsFixed(1),
                    ),
                  ),
                  _Value(
                    l10n.framesAverageRaster,
                    l10n.msValue(
                      (frames.averageRaster.inMicroseconds / 1000)
                          .toStringAsFixed(1),
                    ),
                  ),
                  _Value(
                    l10n.framesWorstRaster,
                    l10n.msValue(
                      (frames.worstRaster.inMicroseconds / 1000)
                          .toStringAsFixed(1),
                    ),
                  ),
                  _Value(
                    l10n.framesWorst,
                    l10n.msValue(
                      (frames.worst.inMicroseconds / 1000).toStringAsFixed(1),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: OutlinedButton(
                        key: const Key('reset-frames'),
                        onPressed: frames.reset,
                        child: Text(l10n.reset),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _Header(l10n.drillLatency),
            ListenableBuilder(
              listenable: DrillLatency.instance,
              builder: (context, _) {
                final latency = DrillLatency.instance;
                return Column(
                  key: const Key('diagnostics-latency'),
                  children: [
                    _Value(l10n.latencyP50, ms(latency.p50)),
                    _Value(l10n.latencyP95, ms(latency.p95)),
                    _Value(l10n.latencySamples, '${latency.count}'),
                  ],
                );
              },
            ),
            _Header(l10n.deviationJobs),
            ListenableBuilder(
              listenable: DeviationTimings.instance,
              builder: (context, _) {
                final t = DeviationTimings.instance;
                final rate = t.readyRate;
                return Column(
                  key: const Key('diagnostics-deviations'),
                  children: [
                    _Value(l10n.latencyP50, ms(t.p50)),
                    _Value(l10n.latencyP95, ms(t.p95)),
                    _Value(l10n.deviationJobCount, '${t.jobCount}'),
                    _Value(
                      l10n.deviationReadyRate,
                      rate == null
                          ? '-'
                          : l10n.deviationReadyValue(
                              (rate * 100).round(),
                              t.neededCount,
                            ),
                    ),
                  ],
                );
              },
            ),
            _Header(l10n.engineTitle),
            const _EngineSection(),
            _Header(l10n.importBenchmark),
            const _BenchmarkSection(),
            _Header(l10n.databaseTitle),
            const _DatabaseSection(),
            _Header(l10n.syncTitle),
            const _SyncSection(),
            _Header(l10n.logsTitle),
            const _LogsSection(),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const new(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
    child: Text(text, style: Theme.of(context).textTheme.titleMedium),
  );
}

class _Value extends StatelessWidget {
  const new(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) =>
      ListTile(dense: true, title: Text(label), trailing: Text(value));
}

/// Engine: binary, variant, version, options, calibration, last jobs.
class _EngineSection extends ConsumerWidget {
  const new();

  static String _job(EngineJobRecord j) =>
      '${j.kind} ${j.duration.inMilliseconds} ms${j.ok ? '' : ' (failed)'}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider).value ?? const AppSettings();
    final status = ref.watch(engineStatusProvider).value;
    final binary = ref.watch(engineBinaryProvider);
    final calibration = ref.watch(calibrationProvider).value;
    final options = engineOptions(settings);
    final jobs = ref.read(engineServiceProvider).recentJobs;
    final na = l10n.notAvailable;
    return Column(
      key: const Key('diagnostics-engine'),
      children: [
        _Value(l10n.engineBinary, switch (binary) {
          AsyncData(:final value) => value?.path ?? l10n.engineMissing,
          AsyncError() => l10n.engineMissing,
          _ => '…',
        }),
        _Value(l10n.engineVariant, settings.engineVariant ?? na),
        _Value(l10n.engineVersion, status?.name ?? na),
        _Value(l10n.engineState, status?.state.name ?? na),
        _Value(l10n.engineThreads, '${options['Threads']}'),
        _Value(l10n.engineHash, '${options['Hash']} MB'),
        _Value(
          l10n.calibrationNps,
          calibration == null ? na : '${calibration.nps}',
        ),
        _Value(
          l10n.calibrationDepth2s,
          calibration == null ? na : '${calibration.depthAt2s}',
        ),
        _Value(
          l10n.calibrationDepth1s,
          calibration == null
              ? na
              : '${calibration.medianDepthAt1s} '
                    '(${calibration.depthsAt1s.join(', ')})',
        ),
        _Value(
          l10n.engineRecentJobs,
          jobs.isEmpty
              ? na
              : [for (final j in jobs.reversed) _job(j)].join('\n'),
        ),
      ],
    );
  }
}

/// Sync: device id, last result, the Drive files (P12 task 7).
class _SyncSection extends ConsumerStatefulWidget {
  const new();

  @override
  ConsumerState<_SyncSection> createState() => _SyncSectionState();
}

class _SyncSectionState extends ConsumerState<_SyncSection> {
  List<DriveFile>? _files;
  String? _error;

  Future<void> _list() async {
    try {
      final drive = await ref.read(driveConnectorProvider)();
      final files = await drive.list();
      if (mounted) setState(() => _files = files);
    } on Object catch (e) {
      if (mounted) setState(() => _error = '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = ref.watch(syncControllerProvider);
    final device = ref.watch(deviceIdProvider).value ?? '';
    final files = _files;
    return Column(
      key: const Key('diagnostics-sync'),
      children: [
        _Value(l10n.deviceIdLabel, device),
        _Value(l10n.syncPhaseLabel, status.phase.name),
        if (status.message case final m?) _Value(l10n.syncMessageLabel, m),
        if (status.enabled)
          TextButton(onPressed: _list, child: Text(l10n.listDriveFiles)),
        if (_error case final e?) _Value(l10n.syncMessageLabel, e),
        if (files != null)
          for (final f in files)
            _Value(f.name, '${((f.size ?? 0) / 1024).toStringAsFixed(1)} KB'),
      ],
    );
  }
}

/// "Export logs" (P13 task 7): the rotating log files, oldest first, saved as
/// one text file.
class _LogsSection extends ConsumerWidget {
  const new();

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final sink = ref.read(logSinkProvider);
    if (sink == null || sink.files.isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.logsUnavailable)));
      return;
    }
    try {
      final text = await sink.readAll();
      final date = DateTime.now().toIso8601String().substring(0, 10);
      final saved = await ref
          .read(fileServiceProvider)
          .saveText(
            fileName: 'repertoire-trainer-logs-$date.txt',
            text: text,
            extension: 'txt',
          );
      if (saved != null) {
        messenger.showSnackBar(SnackBar(content: Text(l10n.logsExported)));
      }
    } on Object catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.logsExportFailed(describeError(e)))),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => Align(
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: OutlinedButton.icon(
        key: const Key('export-logs'),
        onPressed: () => _export(context, ref),
        icon: const Icon(Icons.description_outlined),
        label: Text(AppLocalizations.of(context).exportLogs),
      ),
    ),
  );
}

/// Import benchmark (10-testing §5): 1,000 synthetic lines into a temporary
/// repertoire.
class _BenchmarkSection extends ConsumerStatefulWidget {
  const new();

  @override
  ConsumerState<_BenchmarkSection> createState() => _BenchmarkSectionState();
}

class _BenchmarkSectionState extends ConsumerState<_BenchmarkSection> {
  bool _running = false;
  ImportBenchmarkResult? _result;
  String? _error;

  Future<void> _run() async {
    setState(() {
      _running = true;
      _error = null;
    });
    // No sync while the temporary repertoire exists.
    final gate = ref.read(syncGateProvider)..busy = true;
    try {
      final result = await runImportBenchmark(
        runner: ref.read(importRunnerProvider),
        repertoires: ref.read(repertoireRepositoryProvider),
      );
      if (mounted) setState(() => _result = result);
    } on Object catch (e, st) {
      final message = reportError('Import benchmark failed', e, st);
      if (mounted) setState(() => _error = message);
    } finally {
      gate.busy = false;
      if (mounted) setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final r = _result;
    return Column(
      key: const Key('diagnostics-benchmark'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          dense: true,
          subtitle: Text(l10n.importBenchmarkHint),
          title: Text(
            _running
                ? l10n.importBenchmarkRunning
                : r != null
                ? l10n.importBenchmarkResult(
                    r.lines,
                    r.total.inMilliseconds,
                    r.import.inMilliseconds,
                    r.store.inMilliseconds,
                  )
                : _error != null
                ? l10n.loadError(_error!)
                : l10n.notAvailable,
            key: const Key('benchmark-result'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: OutlinedButton(
            key: const Key('run-benchmark'),
            onPressed: _running ? null : _run,
            child: Text(l10n.importBenchmark),
          ),
        ),
      ],
    );
  }
}

/// Database: file size, rows per table, last derivation.
class _DatabaseSection extends ConsumerWidget {
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final info = ref.watch(databaseInfoProvider);
    return Column(
      key: const Key('diagnostics-database'),
      children: [
        ...switch (info) {
          AsyncValue(value: final i?) => [
            _Value(l10n.databaseFileSize, switch (i.fileBytes) {
              final b? => '${(b / 1024).toStringAsFixed(0)} KB',
              null => l10n.notAvailable,
            }),
            for (final MapEntry(:key, :value) in i.rowCounts.entries)
              _Value(key, '$value'),
          ],
          AsyncValue(:final error?) => [
            _Value(l10n.databaseTitle, describeError(error)),
          ],
          _ => [const LinearProgressIndicator()],
        },
        ListenableBuilder(
          listenable: DerivationTimings.instance,
          builder: (context, _) {
            final t = DerivationTimings.instance;
            return _Value(l10n.databaseLastDerivation, switch (t.last) {
              final d? =>
                '${l10n.msValue('${d.inMilliseconds}')} '
                    '(${t.lastKind})',
              null => l10n.notAvailable,
            });
          },
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: OutlinedButton(
              key: const Key('refresh-database'),
              onPressed: () => ref.invalidate(databaseInfoProvider),
              child: Text(l10n.refresh),
            ),
          ),
        ),
      ],
    );
  }
}
