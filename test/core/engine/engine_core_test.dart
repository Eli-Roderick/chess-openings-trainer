import 'package:chess_core/chess_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repertoire_trainer/core/db/app_database.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/core/engine/binary_locator.dart';
import 'package:repertoire_trainer/core/engine/engine_judge.dart';
import 'package:repertoire_trainer/core/engine/engine_providers.dart';
import 'package:repertoire_trainer/core/settings/app_settings.dart';
import 'package:uci_engine/uci_engine.dart';

import 'fake_engine.dart';

const _fen = 'rnbqkbnr/pppp1ppp/8/4p3/4P3/5N2/PPPP1PPP/RNBQKB1R b KQkq - 1 2';

void main() {
  group('binary locator', () {
    test('Android: libstockfish.so in nativeLibraryDir', () async {
      final locator = BinaryLocator(
        platform: TargetPlatform.android,
        nativeLibraryDir: () async => '/data/app/x/lib/arm64',
        exists: (p) => p == '/data/app/x/lib/arm64/libstockfish.so',
      );
      expect(await locator.candidates(), [
        const EngineBinary('/data/app/x/lib/arm64/libstockfish.so'),
      ]);
    });

    test('Android: nothing when the channel has no directory', () async {
      final locator = BinaryLocator(
        platform: TargetPlatform.android,
        nativeLibraryDir: () async => null,
        exists: (_) => true,
      );
      expect(await locator.candidates(), isEmpty);
    });

    test('Windows: avx2 then sse41 next to the executable', () async {
      final all = BinaryLocator(
        platform: TargetPlatform.windows,
        resolvedExecutable: '/app/repertoire_trainer.exe',
        exists: (_) => true,
      );
      expect(await all.candidates(), [
        const EngineBinary('/app/engine/stockfish-avx2.exe', variant: 'avx2'),
        const EngineBinary('/app/engine/stockfish-sse41.exe', variant: 'sse41'),
      ]);
      final sseOnly = BinaryLocator(
        platform: TargetPlatform.windows,
        resolvedExecutable: '/app/repertoire_trainer.exe',
        exists: (p) => p.endsWith('sse41.exe'),
      );
      expect((await sseOnly.candidates()).single.variant, 'sse41');
    });

    test('Linux: bundle first, then engine/linux in the working directory '
        'or a parent', () async {
      final bundled = BinaryLocator(
        platform: TargetPlatform.linux,
        resolvedExecutable: '/opt/rt/repertoire_trainer',
        currentDirectory: '/home/eli/repo/packages/x',
        exists: (_) => true,
      );
      expect(
        (await bundled.candidates()).first.path,
        '/opt/rt/engine/stockfish',
      );
      final dev = BinaryLocator(
        platform: TargetPlatform.linux,
        resolvedExecutable: '/tmp/build/repertoire_trainer',
        currentDirectory: '/home/eli/repo/packages/x',
        exists: (p) => p == '/home/eli/repo/engine/linux/stockfish',
      );
      expect(
        (await dev.candidates()).single.path,
        '/home/eli/repo/engine/linux/stockfish',
      );
    });

    test('other platforms have none', () async {
      final locator = BinaryLocator(
        platform: TargetPlatform.iOS,
        exists: (_) => true,
      );
      expect(await locator.candidates(), isEmpty);
    });
  });

  group('engine options (05 §3)', () {
    test('auto threads and hash per platform', () {
      final android = engineOptions(
        const AppSettings(),
        platform: TargetPlatform.android,
        cores: 8,
      );
      expect((android['Threads'], android['Hash']), (4, 64));
      expect(
        engineOptions(
          const AppSettings(),
          platform: TargetPlatform.android,
          cores: 2,
        )['Threads'],
        1,
      );
      final desktop = engineOptions(
        const AppSettings(),
        platform: TargetPlatform.windows,
        cores: 24,
      );
      expect((desktop['Threads'], desktop['Hash']), (8, 256));
      expect(
        engineOptions(
          const AppSettings(),
          platform: TargetPlatform.linux,
          cores: 1,
        )['Threads'],
        1,
      );
    });

    test('settings override, threads at most the core count', () {
      final o = engineOptions(
        const AppSettings(engineThreads: 12, engineHashMb: 512),
        platform: TargetPlatform.windows,
        cores: 6,
      );
      expect((o['Threads'], o['Hash']), (6, 512));
    });
  });

  group('binary probe', () {
    late AppDatabase db;
    setUp(() => db = AppDatabase.memory());
    tearDown(() => db.close());

    ProviderContainer container(Future<UciTransport> Function(String) start) {
      final c = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          binaryLocatorProvider.overrideWithValue(
            BinaryLocator(
              platform: TargetPlatform.windows,
              resolvedExecutable: '/app/rt.exe',
              exists: (_) => true,
            ),
          ),
          transportStarterProvider.overrideWithValue(start),
        ],
      );
      addTearDown(c.dispose);
      return c;
    }

    test('avx2 that dies falls back to sse41, remembered', () async {
      final engine = FakeEngine();
      final tried = <String>[];
      final c = container((path) async {
        tried.add(path);
        if (path.contains('avx2')) {
          final t = FakeTransport()..exit(132); // illegal instruction
          return t;
        }
        return await engine.launch(path);
      });
      final binary = await c.read(engineBinaryProvider.future);
      expect(binary!.variant, 'sse41');
      expect(tried, [
        '/app/engine/stockfish-avx2.exe',
        '/app/engine/stockfish-sse41.exe',
      ]);
      final settings = await c.read(settingsRepositoryProvider).load();
      expect(settings.engineVariant, 'sse41');
    });

    test('the remembered variant is tried first', () async {
      await SettingsRepositoryTestHelper.setVariant(db, 'sse41');
      final engine = FakeEngine();
      final tried = <String>[];
      final c = container((path) async {
        tried.add(path);
        return await engine.launch(path);
      });
      expect((await c.read(engineBinaryProvider.future))!.variant, 'sse41');
      expect(tried, ['/app/engine/stockfish-sse41.exe']);
    });
  });

  group('engine judge (04 §7)', () {
    late EngineService service;
    late FakeEngine engine;
    var settings = const AppSettings(checkSearchMs: 500);

    setUp(() {
      engine = FakeEngine(scores: {'b8c6': 20, 'g8f6': 0, 'f7f6': -80});
      settings = const AppSettings(checkSearchMs: 500);
      service = EngineService(launch: () => engine.launch(''));
    });
    tearDown(() => service.dispose());

    EngineJudge judge() => EngineJudge(service, () => settings);

    test('comparable within the threshold, not beyond', () async {
      final ok = await judge().checkComparable(
        fen: _fen,
        userUci: 'g8f6',
        accepted: ['b8c6'],
      );
      expect((ok.comparable, ok.lossCp, ok.status), (true, 20, CheckStatus.ok));
      final bad = await judge().checkComparable(
        fen: _fen,
        userUci: 'f7f6',
        accepted: ['b8c6'],
      );
      expect((bad.comparable, bad.lossCp), (false, 100));
      expect(engine.commands, contains('go infinite searchmoves b8c6 f7f6'));
    });

    test(
      'threshold from the settings; better than book is comparable',
      () async {
        settings = settings.copyWith(comparableThresholdCp: 10);
        final r = await judge().checkComparable(
          fen: _fen,
          userUci: 'g8f6',
          accepted: ['b8c6'],
        );
        expect(r.comparable, isFalse);
        final better = await judge().checkComparable(
          fen: _fen,
          userUci: 'b8c6',
          accepted: ['g8f6'],
        );
        expect((better.comparable, better.lossCp), (true, -20));
      },
    );

    test(
      'unavailable engine: not comparable, status engineUnavailable',
      () async {
        final dead = EngineService(
          launch: () async => throw StateError('no binary'),
        );
        addTearDown(dead.dispose);
        final r = await EngineJudge(
          dead,
          () => settings,
        ).checkComparable(fen: _fen, userUci: 'g8f6', accepted: ['b8c6']);
        expect(r.status, CheckStatus.engineUnavailable);
        expect(r.comparable, isFalse);
        expect(
          await EngineJudge(
            dead,
            () => settings,
          ).deviationCandidates(fen: _fen),
          isEmpty,
        );
      },
    );

    test(
      'deviation candidates exclude book moves and the 100 cp tail',
      () async {
        engine.scores = {'b8c6': 20, 'g8f6': 0, 'd7d6': -10, 'f7f6': -90};
        final c = await judge().deviationCandidates(fen: _fen, book: {'b8c6'});
        expect([for (final m in c) m.uci], ['g8f6', 'd7d6']);
      },
    );

    test(
      'reply judgement: best move passes, a 60 cp worse move fails',
      () async {
        engine.scores = {'b8c6': 20, 'g8f6': 0, 'f7f6': -40};
        final best = await judge().judgeReply(fen: _fen, replyUci: 'b8c6');
        expect((best!.passed, best.lossCp), (true, 0));
        final ok = await judge().judgeReply(fen: _fen, replyUci: 'g8f6');
        expect((ok!.passed, ok.lossCp), (true, 20));
        final bad = await judge().judgeReply(fen: _fen, replyUci: 'f7f6');
        expect((bad!.passed, bad.lossCp), (false, 60));
      },
    );
  });
}

/// Writes the remembered engine variant directly.
abstract final class SettingsRepositoryTestHelper {
  static Future<void> setVariant(AppDatabase db, String variant) async {
    final c = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    await c
        .read(settingsRepositoryProvider)
        .update((s) => s.copyWith(engineVariant: variant));
    c.dispose();
  }
}
