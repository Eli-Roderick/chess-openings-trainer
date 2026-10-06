import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repertoire_trainer/core/audio/sound_service.dart';
import 'package:repertoire_trainer/core/settings/app_settings.dart';

final class _Backend implements SoundBackend {
  final played = <(String, double)>[];
  bool fail = false;

  @override
  Future<void> load(Iterable<String> assets) async {
    if (fail) throw StateError('no audio device');
  }

  @override
  void play(String asset, double volume) => played.add((asset, volume));
}

void main() {
  test('SAN maps to sounds', () {
    expect(SoundType.forSan('e4'), SoundType.move);
    expect(SoundType.forSan('exd5'), SoundType.capture);
    expect(SoundType.forSan('Bxf7+'), SoundType.check);
    expect(SoundType.forSan('Qh7#'), SoundType.check);
    expect(SoundType.forSan('O-O-O'), SoundType.castle);
  });

  test('plays mapped sounds at the set volume; muted plays nothing', () async {
    final backend = _Backend();
    var settings = const AppSettings(soundVolumePercent: 50);
    final service = SoundService(backend, () => settings);
    await service.preload();
    expect(service.isReady, isTrue);
    service
      ..play(SoundType.capture)
      ..play(SoundType.lineComplete)
      ..play(SoundType.castle);
    expect(backend.played, [
      ('assets/sounds/capture.ogg', 0.5),
      ('assets/sounds/line_complete.ogg', 0.5),
      ('assets/sounds/move.ogg', 0.5),
    ]);
    settings = settings.copyWith(soundsEnabled: false);
    service.play(SoundType.move);
    settings = const AppSettings(soundVolumePercent: 0);
    service.play(SoundType.move);
    expect(backend.played, hasLength(3));
  });

  test('no audio device: stays silent', () async {
    final backend = _Backend()..fail = true;
    final service = SoundService(backend, () => const AppSettings());
    await service.preload();
    expect(service.isReady, isFalse);
    service.play(SoundType.move);
    expect(backend.played, isEmpty);
  });

  test('every sound asset is bundled', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    for (final s in SoundType.values) {
      expect(manifest.listAssets(), contains(s.asset), reason: s.name);
    }
  });
}
