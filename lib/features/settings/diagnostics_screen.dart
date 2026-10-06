import 'package:flutter/material.dart';
import 'package:repertoire_trainer/app/layout/adaptive_layout.dart';
import 'package:repertoire_trainer/core/diagnostics/frame_stats.dart';
import 'package:repertoire_trainer/core/diagnostics/startup_timings.dart';
import 'package:repertoire_trainer/l10n/gen/app_localizations.dart';

/// Hidden Diagnostics (docs/plan/10-testing-and-quality.md §6): startup
/// timings and frames now; engine, database, sync and logs in later phases.
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
