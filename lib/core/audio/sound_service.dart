import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:logging/logging.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/core/settings/app_settings.dart';

final _log = Logger('sound');

/// The app's sounds (01-product-spec §7, P05).
enum SoundType {
  /// A quiet move.
  move('move'),

  /// A capture.
  capture('capture'),

  /// A move giving check (lichess's standard set has no separate check
  /// sound; it plays the move sound).
  check('move'),

  /// Castling (the move sound, as on lichess).
  castle('move'),

  /// A wrong move.
  error('error'),

  /// A line was completed.
  lineComplete('line_complete'),

  /// The opponent left the repertoire.
  deviation('deviation'),

  /// A hint was shown.
  hint('hint');

  new(this.file);

  /// File name in `assets/sounds/` without `.ogg`.
  final String file;

  /// The asset key.
  String get asset => 'assets/sounds/$file.ogg';

  /// The sound for a move written in SAN.
  static SoundType forSan(String san) {
    if (san.startsWith('O-O')) return castle;
    if (san.contains('+') || san.contains('#')) return check;
    if (san.contains('x')) return capture;
    return move;
  }
}

/// Plays decoded sounds; the real one is flutter_soloud.
abstract interface class SoundBackend {
  /// Starts the audio engine and decodes [assets].
  Future<void> load(Iterable<String> assets);

  /// Plays a loaded [asset] at [volume] (0-1).
  void play(String asset, double volume);
}

/// [SoundBackend] on flutter_soloud.
final class SoloudBackend implements SoundBackend {
  final _sources = <String, AudioSource>{};

  @override
  Future<void> load(Iterable<String> assets) async {
    final soloud = SoLoud.instance;
    if (!soloud.isInitialized) await soloud.init(bufferSize: 512);
    for (final asset in assets) {
      _sources[asset] ??= await soloud.loadAsset(asset);
    }
  }

  @override
  void play(String asset, double volume) {
    final source = _sources[asset];
    if (source != null) SoLoud.instance.play(source, volume: volume);
  }
}

/// Plays app sounds with the current volume and mute setting. Sounds load
/// once (after the first frame); a failure to start audio (no device, CI)
/// is logged and sounds stay silent.
final class SoundService {
  /// Creates the service.
  new(this._backend, this._settings);

  final SoundBackend _backend;
  final AppSettings Function() _settings;
  Future<void>? _loading;
  bool _ready = false;

  /// Whether sounds are loaded and can play.
  bool get isReady => _ready;

  /// Loads every sound (idempotent).
  Future<void> preload() => _loading ??= () async {
    try {
      await _backend.load({for (final s in SoundType.values) s.asset});
      _ready = true;
    } on Object catch (e, st) {
      _log.warning('Sounds unavailable', e, st);
    }
  }();

  /// Plays [type] unless sounds are off.
  void play(SoundType type) {
    final settings = _settings();
    if (!settings.soundsEnabled || settings.soundVolumePercent == 0) return;
    if (!_ready) {
      unawaited(preload());
      return;
    }
    try {
      _backend.play(type.asset, settings.soundVolumePercent / 100);
    } on Object catch (e) {
      _log.warning('Playing ${type.name} failed', e);
    }
  }
}

/// The sound backend; tests override it.
final soundBackendProvider = Provider<SoundBackend>((ref) => SoloudBackend());

/// The app's sound service.
final soundServiceProvider = Provider<SoundService>(
  (ref) => SoundService(
    ref.watch(soundBackendProvider),
    () => ref.read(settingsProvider).value ?? const AppSettings(),
  ),
);
