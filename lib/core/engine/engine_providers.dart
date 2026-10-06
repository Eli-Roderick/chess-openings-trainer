import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/core/engine/binary_locator.dart';
import 'package:repertoire_trainer/core/settings/app_settings.dart';
import 'package:uci_engine/uci_engine.dart';

final _log = Logger('engine');

/// Engine options (docs/plan/05-engine.md §3): Threads and Hash per
/// platform unless the settings override them.
Map<String, Object> engineOptions(
  AppSettings settings, {
  TargetPlatform? platform,
  int? cores,
}) {
  final android = (platform ?? defaultTargetPlatform) == TargetPlatform.android;
  final n = cores ?? Platform.numberOfProcessors;
  final threads = android ? (n - 1).clamp(1, 4) : (n ~/ 2).clamp(1, 8);
  return {
    'Threads': (settings.engineThreads ?? threads).clamp(1, n),
    'Hash': settings.engineHashMb ?? (android ? 64 : 256),
    'UCI_ShowWDL': false,
  };
}

/// Finds the binary.
final binaryLocatorProvider = Provider<BinaryLocator>((ref) => BinaryLocator());

/// Starts a transport for a binary path; integration tests wrap it.
final transportStarterProvider =
    Provider<Future<UciTransport> Function(String)>(
      (ref) =>
          (path) => ProcessTransport.start(path, onStderr: _log.warning),
    );

/// The binary to run, or null if none is installed. With several
/// candidates (Windows avx2, sse41) each is probed: the first that answers
/// `uciok` within 3 s wins and its variant is remembered in the settings.
final engineBinaryProvider = FutureProvider<EngineBinary?>((ref) async {
  final candidates = await ref.watch(binaryLocatorProvider).candidates();
  if (candidates.length <= 1) return candidates.firstOrNull;
  final settings = await ref.read(settingsRepositoryProvider).load();
  final ordered = [
    ...candidates.where((c) => c.variant == settings.engineVariant),
    ...candidates.where((c) => c.variant != settings.engineVariant),
  ];
  final start = ref.read(transportStarterProvider);
  for (final candidate in ordered) {
    try {
      final engine = UciEngine(
        await start(candidate.path),
        handshakeTimeout: const Duration(seconds: 3),
      );
      try {
        await engine.start();
      } finally {
        await engine.dispose();
      }
      if (candidate.variant != settings.engineVariant) {
        await ref
            .read(settingsRepositoryProvider)
            .update((s) => s.copyWith(engineVariant: candidate.variant));
      }
      return candidate;
    } on Object catch (e) {
      _log.warning('${candidate.path} did not start', e);
    }
  }
  return null;
});

/// The engine service (lazy: no process until the first job or warm-up).
/// Restarts when Threads or Hash change.
final engineServiceProvider = Provider<EngineService>((ref) {
  AppSettings settings() =>
      ref.read(settingsProvider).value ?? const AppSettings();
  final service = EngineService(
    launch: () async {
      final binary = await ref.read(engineBinaryProvider.future);
      if (binary == null) {
        throw const EngineUnavailable('Stockfish binary not found');
      }
      _log.info('Starting ${binary.path}');
      return await ref.read(transportStarterProvider)(binary.path);
    },
    options: () => engineOptions(settings()),
  );
  ref
    ..listen(
      settingsProvider.select(
        (s) => (s.value?.engineThreads, s.value?.engineHashMb),
      ),
      (previous, next) {
        if (previous != next && service.status.state != EngineState.stopped) {
          unawaited(service.restart());
        }
      },
    )
    ..onDispose(() => unawaited(service.dispose()));
  return service;
});

/// Engine status, updated live.
final engineStatusProvider = StreamProvider<EngineStatus>((ref) async* {
  final service = ref.watch(engineServiceProvider);
  yield service.status;
  yield* service.statusChanges;
});

/// Key of the stored calibration in the device-local key/value table.
const calibrationKey = 'engine.calibration';

/// The stored calibration; [CalibrationController.run] runs a new one,
/// [CalibrationController.scheduleAuto] runs it once per install after
/// 10 s idle on Home (docs/plan/05-engine.md §9).
final calibrationProvider =
    AsyncNotifierProvider<CalibrationController, CalibrationResult?>(
      CalibrationController.new,
    );

/// See [calibrationProvider].
final class CalibrationController extends AsyncNotifier<CalibrationResult?> {
  Timer? _auto;
  bool _autoWanted = false;
  bool _running = false;

  /// Delay before the automatic calibration.
  static const autoDelay = Duration(seconds: 10);

  @override
  Future<CalibrationResult?> build() async {
    ref.onDispose(() => _auto?.cancel());
    final json = await ref
        .read(syncStateRepositoryProvider)
        .get(calibrationKey);
    if (json == null) return null;
    try {
      final m = jsonDecode(json) as Map<String, dynamic>;
      return CalibrationResult(
        nps: m['nps'] as int,
        depthAt2s: m['depthAt2s'] as int,
        depthsAt1s: [for (final d in m['depthsAt1s'] as List) d as int],
      );
    } on Object {
      return null;
    }
  }

  /// Whether a calibration is running.
  bool get isRunning => _running;

  /// Calibrates now and stores the result.
  Future<CalibrationResult?> run() async {
    if (_running) return state.value;
    _running = true;
    _auto?.cancel();
    try {
      final r = await ref.read(engineServiceProvider).calibrate();
      await ref
          .read(syncStateRepositoryProvider)
          .set(
            calibrationKey,
            jsonEncode({
              'nps': r.nps,
              'depthAt2s': r.depthAt2s,
              'depthsAt1s': r.depthsAt1s,
            }),
          );
      _log.info(
        'Calibration: ${r.nps} nps, median depth ${r.medianDepthAt1s} at 1 s',
      );
      state = AsyncData(r);
      return r;
    } on Object catch (e) {
      _log.warning('Calibration failed', e);
      return null;
    } finally {
      _running = false;
    }
  }

  /// Calibrates after [autoDelay] of [isIdle] (Home on top) unless a
  /// calibration is stored or [cancelAuto] is called (Home disposed). If
  /// Home is covered when the delay ends, it waits another [autoDelay].
  Future<void> scheduleAuto({required bool Function() isIdle}) async {
    _autoWanted = true;
    final stored = await future;
    if (!_autoWanted || stored != null || _running || _auto != null) return;
    void arm() {
      _auto = Timer(autoDelay, () {
        _auto = null;
        if (!_autoWanted) return;
        if (isIdle()) {
          unawaited(run());
        } else {
          arm();
        }
      });
    }

    arm();
  }

  /// Cancels a scheduled automatic calibration.
  void cancelAuto() {
    _autoWanted = false;
    _auto?.cancel();
    _auto = null;
  }
}
