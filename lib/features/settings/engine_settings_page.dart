import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repertoire_trainer/app/version.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/core/engine/engine_providers.dart';
import 'package:repertoire_trainer/core/settings/app_settings.dart';
import 'package:repertoire_trainer/l10n/gen/app_localizations.dart';
import 'package:uci_engine/uci_engine.dart';

/// Hash sizes offered (MB).
const hashChoices = [16, 32, 64, 128, 256, 512, 1024];

/// Play-on strengths (UCI_Elo; 0 = full strength).
const playOnChoices = [1500, 2000, 2500, 0];

/// "Stockfish 18 ready · 4 threads · 0.71 Mnps" or the error
/// (01-product-spec §10).
String engineStatusLine(
  AppLocalizations l10n, {
  required EngineStatus status,
  required int threads,
  CalibrationResult? calibration,
  String? variant,
}) {
  final name =
      status.name ?? 'Stockfish ${stockfishTag.replaceFirst('sf_', '')}';
  final details = [
    l10n.engineThreadsCount(threads),
    if (calibration != null)
      l10n.engineMnps((calibration.nps / 1e6).toStringAsFixed(2)),
    ?variant,
  ];
  final state = switch (status.state) {
    EngineState.ready || EngineState.searching => l10n.engineReady,
    EngineState.stopped => l10n.engineNotRunning,
    EngineState.starting => l10n.engineStarting,
    EngineState.error => l10n.engineError(status.message ?? ''),
    EngineState.unavailable => l10n.engineUnavailableStatus(
      status.message ?? '',
    ),
  };
  if (status.state == EngineState.error ||
      status.state == EngineState.unavailable) {
    return '$name: $state';
  }
  return ['$name $state', ...details].join(' · ');
}

/// Settings → Engine (01-product-spec §10).
class EngineSettingsPage extends ConsumerWidget {
  /// Creates the page.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final s = ref.watch(settingsProvider).value ?? const AppSettings();
    final status =
        ref.watch(engineStatusProvider).value ??
        const EngineStatus(EngineState.stopped);
    final calibration = ref.watch(calibrationProvider).value;
    final options = engineOptions(s);
    final autoOptions = engineOptions(const AppSettings());
    final cores = Platform.numberOfProcessors;
    final playOn = playOnChoices.contains(s.playOnElo) ? s.playOnElo : 2500;
    void update(AppSettings Function(AppSettings) change) =>
        unawaited(ref.read(settingsRepositoryProvider).update(change));

    return ListView(
      key: const Key('engine-settings'),
      children: [
        ListTile(
          key: const Key('engine-status'),
          leading: Icon(
            status.isAvailable ? Icons.memory : Icons.error_outline,
            color: status.isAvailable
                ? null
                : Theme.of(context).colorScheme.error,
          ),
          title: Text(
            engineStatusLine(
              l10n,
              status: status,
              threads: options['Threads']! as int,
              calibration: calibration,
              variant: s.engineVariant,
            ),
          ),
        ),
        ListTile(
          title: Text(l10n.comparableThreshold),
          trailing: Text(
            l10n.pawnsValue((s.comparableThresholdCp / 100).toStringAsFixed(2)),
          ),
        ),
        Slider(
          key: const Key('comparable-threshold'),
          value: s.comparableThresholdCp.toDouble(),
          min: 10,
          max: 100,
          divisions: 18,
          label: (s.comparableThresholdCp / 100).toStringAsFixed(2),
          onChanged: (v) =>
              update((s) => s.copyWith(comparableThresholdCp: v.round())),
        ),
        ListTile(
          title: Text(l10n.checkSearchTime),
          trailing: Text(
            l10n.secondsValue((s.checkSearchMs / 1000).toStringAsFixed(1)),
          ),
        ),
        Slider(
          key: const Key('check-search-time'),
          value: s.checkSearchMs.toDouble(),
          min: 500,
          max: 3000,
          divisions: 25,
          label: (s.checkSearchMs / 1000).toStringAsFixed(1),
          onChanged: (v) =>
              update((s) => s.copyWith(checkSearchMs: (v / 100).round() * 100)),
        ),
        ListTile(
          title: Text(l10n.engineThreads),
          trailing: DropdownButton<int?>(
            key: const Key('engine-threads'),
            value: s.engineThreads,
            onChanged: (v) => update((s) => s.copyWith(engineThreads: v)),
            items: [
              DropdownMenuItem(
                child: Text(l10n.autoValue('${autoOptions['Threads']}')),
              ),
              for (var n = 1; n <= cores; n++)
                DropdownMenuItem(value: n, child: Text('$n')),
            ],
          ),
        ),
        ListTile(
          title: Text(l10n.engineHash),
          trailing: DropdownButton<int?>(
            key: const Key('engine-hash'),
            value: hashChoices.contains(s.engineHashMb) ? s.engineHashMb : null,
            onChanged: (v) => update((s) => s.copyWith(engineHashMb: v)),
            items: [
              DropdownMenuItem(
                child: Text(l10n.autoValue('${autoOptions['Hash']} MB')),
              ),
              for (final mb in hashChoices)
                DropdownMenuItem(value: mb, child: Text('$mb MB')),
            ],
          ),
        ),
        ListTile(title: Text(l10n.playOnStrength)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SegmentedButton<int>(
            key: const Key('play-on-strength'),
            segments: [
              for (final elo in playOnChoices)
                ButtonSegment(
                  value: elo,
                  label: Text(elo == 0 ? l10n.fullStrength : '$elo'),
                ),
            ],
            selected: {playOn},
            onSelectionChanged: (v) =>
                update((s) => s.copyWith(playOnElo: v.single)),
          ),
        ),
        const SizedBox(height: 8),
        _CalibrationTile(available: status.isAvailable),
        if (calibration != null && calibration.medianDepthAt1s < 12)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              l10n.slowDeviceNote,
              key: const Key('slow-device-note'),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: OutlinedButton.icon(
            key: const Key('restart-engine'),
            icon: const Icon(Icons.restart_alt),
            label: Text(l10n.restartEngine),
            onPressed: () =>
                unawaited(ref.read(engineServiceProvider).restart()),
          ),
        ),
      ],
    );
  }
}

class _CalibrationTile extends ConsumerStatefulWidget {
  const new({required this.available});

  final bool available;

  @override
  ConsumerState<_CalibrationTile> createState() => _CalibrationTileState();
}

class _CalibrationTileState extends ConsumerState<_CalibrationTile> {
  bool _running = false;

  Future<void> _run() async {
    setState(() => _running = true);
    await ref.read(calibrationProvider.notifier).run();
    if (mounted) setState(() => _running = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final calibration = ref.watch(calibrationProvider).value;
    return ListTile(
      title: Text(l10n.calibration),
      subtitle: Text(
        calibration == null
            ? l10n.notCalibrated
            : l10n.calibrationValue(
                (calibration.nps / 1e6).toStringAsFixed(2),
                calibration.medianDepthAt1s,
              ),
        key: const Key('calibration-value'),
      ),
      trailing: _running
          ? const SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : TextButton(
              key: const Key('run-calibration'),
              onPressed: widget.available ? _run : null,
              child: Text(l10n.runCalibration),
            ),
    );
  }
}
