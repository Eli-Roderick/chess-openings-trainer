import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repertoire_trainer/app/layout/adaptive_layout.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/core/diagnostics/frame_stats.dart';
import 'package:repertoire_trainer/core/diagnostics/startup_timings.dart';
import 'package:repertoire_trainer/core/engine/engine_providers.dart';
import 'package:repertoire_trainer/core/settings/app_settings.dart';
import 'package:repertoire_trainer/l10n/gen/app_localizations.dart';
import 'package:uci_engine/uci_engine.dart';

/// Hidden Diagnostics (docs/plan/10-testing-and-quality.md §6): startup
/// timings, frames and the engine; drill latency, database, sync and logs
/// in later phases.
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
                  _Value(l10n.framesCount, '${frames.count}'),
                  _Value(l10n.framesJanky, '${frames.janky}'),
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
            _Header(l10n.engineTitle),
            const _EngineSection(),
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
