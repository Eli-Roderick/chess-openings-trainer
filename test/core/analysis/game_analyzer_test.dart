import 'package:chess_core/chess_core.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:repertoire_trainer/core/analysis/game_analyzer.dart';
import 'package:repertoire_trainer/core/db/app_database.dart';
import 'package:repertoire_trainer/core/db/repositories/games_repository.dart';

import '../engine/fake_engine.dart';

const _ucis = [
  'e2e4', 'e7e5', 'g1f3', 'b8c6', 'f1c4', 'g8f6', 'f3g5', 'd7d5', //
  'e4d5', 'f6d5', 'g5f7', 'e8f7',
];

void main() {
  late AppDatabase db;
  late GamesRepository repo;
  final launched = <FakeEngine>[];

  setUp(() {
    db = AppDatabase.memory();
    repo = GamesRepository(db);
    launched.clear();
  });
  tearDown(() => db.close());

  GameAnalyzer analyzer({int workers = 1}) => GameAnalyzer(
    launch: () {
      final e = FakeEngine(step: const Duration(milliseconds: 1));
      launched.add(e);
      return e.launch('sf');
    },
    store: repo,
    workers: workers,
    clock: FakeClock(DateTime(2026, 10, 7)),
  );

  test(
    'Quick then Standard: every position stored, labels and summary',
    () async {
      final a = analyzer(workers: 2);
      final events = await a
          .analyse(
            const AnalysisRequest(gameId: 'g', ucis: _ucis, book: {1, 2}),
          )
          .toList();
      expect(events.where((e) => e.complete).map((e) => e.profile), [
        AnalysisProfile.quick,
        AnalysisProfile.standard,
      ]);
      // Book plies 1-2: positions 0 and 1 touch no judged move.
      final quick = await repo.positions('g', AnalysisProfile.quick.index);
      final scored = [
        for (final r in quick)
          if (r.cp != null || r.mate != null) r.ply,
      ];
      expect(scored, [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]);
      expect(quick.every((r) => r.ply == 0 || r.label != null), isTrue);
      expect(quick.firstWhere((r) => r.ply == 1).label, MoveLabel.book.index);
      final summary = await repo.review('g', AnalysisProfile.standard.index);
      expect(summary!.complete, isTrue);
      expect(summary.engine, 'Stockfish 18');
      expect(summary.whiteAccuracy, isNotNull);
      // Every search ran at the profile's depth, one thread, hash cleared.
      final commands = [for (final e in launched) ...e.commands];
      expect(commands, contains('go depth 12'));
      expect(commands, contains('go depth 18'));
      expect(commands, contains('setoption name Threads value 1'));
      expect(
        commands.where((c) => c == 'ucinewgame').length,
        greaterThanOrEqualTo(22),
      );
      await a.dispose();
    },
  );

  test('re-opening a complete game costs no engine call', () async {
    final a = analyzer();
    await a
        .analyse(const AnalysisRequest(gameId: 'g', ucis: _ucis))
        .drain<void>();
    final before = [for (final e in launched) ...e.commands]
        .where((c) => c.startsWith('go'))
        .length;
    final again = await a
        .analyse(const AnalysisRequest(gameId: 'g', ucis: _ucis))
        .toList();
    expect(again.every((e) => e.complete), isTrue);
    final after = [for (final e in launched) ...e.commands]
        .where((c) => c.startsWith('go'))
        .length;
    expect(after, before);
  });

  test(
    'resumes after an interruption; labels do not depend on workers',
    () async {
      final a = analyzer();
      // Stop after a few positions (the app was killed).
      var seen = 0;
      final sub = a
          .analyse(
            const AnalysisRequest(
              gameId: 'g',
              ucis: _ucis,
              profiles: [AnalysisProfile.quick],
            ),
          )
          .listen((_) => seen++);
      while (seen < 4) {
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }
      await sub.cancel();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final partial = (await repo.positions('g', 0)).length;
      expect(partial, greaterThan(0));
      expect(partial, lessThan(_ucis.length + 1));
      final b = analyzer(workers: 3);
      await b
          .analyse(
            const AnalysisRequest(
              gameId: 'g',
              ucis: _ucis,
              profiles: [AnalysisProfile.quick],
            ),
          )
          .drain<void>();
      final one = analyzer();
      await one
          .analyse(
            const AnalysisRequest(
              gameId: 'h',
              ucis: _ucis,
              profiles: [AnalysisProfile.quick],
            ),
          )
          .drain<void>();
      final resumed = [for (final r in await repo.positions('g', 0)) r.label];
      final fresh = [for (final r in await repo.positions('h', 0)) r.label];
      expect(resumed, fresh);
      expect((await repo.review('g', 0))!.complete, isTrue);
    },
  );

  test('hold pauses the job until released', () async {
    final a = analyzer();
    final release = a.hold();
    expect(a.held, isTrue);
    var done = false;
    final job = a
        .analyse(
          const AnalysisRequest(
            gameId: 'g',
            ucis: _ucis,
            profiles: [AnalysisProfile.quick],
          ),
        )
        .drain<void>()
        .then((_) => done = true);
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(done, isFalse);
    expect(await repo.review('g', 0), isNotNull);
    expect((await repo.review('g', 0))!.complete, isFalse);
    release();
    release(); // idempotent
    await job;
    expect(done, isTrue);
    expect(a.held, isFalse);
  });

  test('a changed engine invalidates stored results', () async {
    final a = analyzer();
    await a
        .analyse(
          const AnalysisRequest(
            gameId: 'g',
            ucis: _ucis,
            profiles: [AnalysisProfile.quick],
          ),
        )
        .drain<void>();
    await repo.saveReview(
      (await repo.review(
        'g',
        0,
      ))!.toCompanion(true).copyWith(engine: const Value('Stockfish 17')),
    );
    final events = await a
        .analyse(
          const AnalysisRequest(
            gameId: 'g',
            ucis: _ucis,
            profiles: [AnalysisProfile.quick],
          ),
        )
        .toList();
    expect(events.first.done, lessThan(events.first.total));
    expect((await repo.review('g', 0))!.engine, 'Stockfish 18');
  });

  test('defaultWorkers', () {
    expect(defaultWorkers(1), 1);
    expect(defaultWorkers(4), 2);
    expect(defaultWorkers(16), 4);
  });
}
