import 'dart:io' as io;

import 'package:chess_core/chess_core.dart';
import 'package:dartchess/dartchess.dart' show Side;
import 'package:flutter_test/flutter_test.dart';

import 'db_test_helpers.dart';

String fixture(String name) =>
    io.File('packages/chess_core/test/fixtures/$name').readAsStringSync();

/// A finished run on line [l] with the given credits.
RunRecord runOn(
  String repertoireId,
  LineRef l, {
  required String id,
  required int finishedAt,
  List<double> credits = const [1, 1],
  RunMode mode = RunMode.random,
  String day = '2026-10-06',
  bool completed = true,
  String? ucis,
  DeviationEvent? deviation,
}) => RunRecord(
  id: id,
  repertoireId: repertoireId,
  lineKey: l.key,
  ucis: ucis ?? l.ucis,
  mode: mode,
  startPly: 0,
  wrongMoveMode: WrongMoveMode.retry,
  startedAt: finishedAt - 100,
  finishedAt: finishedAt,
  localDay: day,
  completed: completed,
  deviated: false,
  gradedCount: credits.length,
  creditSum: credits.fold(0, (a, b) => a + b),
  hintCount: 0,
  deviceId: 'dev',
  grades: [
    for (final (i, c) in credits.indexed)
      MoveGrade(
        ply: 2 * i + 1,
        expected: 'e2e4',
        accepted: 'e2e4 d2d4',
        firstAttempt: c == 1 ? 'e2e4' : 'g2g3',
        result: c == 1 ? GradeResult.correct : GradeResult.wrong,
        credit: c,
        attempts: c == 1 ? 1 : 2,
        hintLevel: 0,
        checkStatus: c == 1 ? null : CheckStatus.ok,
        checkCp: c == 1 ? null : 120,
      ),
  ],
  deviation: deviation,
);

void main() {
  late TestDb t;
  late String rep;
  late List<LineRef> lines;

  setUp(() async {
    t = TestDb();
    final pgn = fixture('demo_italian_white.pgn');
    rep = await t.repertoires.create(
      name: 'Italian',
      color: Side.white,
      pgn: pgn,
      result: importPgn(pgn, Side.white),
    );
    lines = await t.repertoires.lineRefs(rep);
  });
  tearDown(() => t.close());

  group('RunRepository', () {
    test(
      'insertRun round-trips grades and deviation, bumps lastTrainedAt',
      () async {
        const dev = DeviationEvent(
          ply: 16,
          deviationUci: 'a7a6',
          replyUci: 'f1e1',
          bestUci: 'f1e1',
          lossCp: 0,
          passed: true,
        );
        final run = runOn(
          rep,
          lines.first,
          id: 'r1',
          finishedAt: 5000,
          credits: [1, 0],
          deviation: dev,
        );
        await t.runs.insertRun(run);
        expect(await t.runs.runsForRepertoire(rep), [run]);
        expect((await t.repertoires.get(rep))!.lastTrainedAt, 5000);
        await t.runs.insertRun(runOn(rep, lines[1], id: 'r0', finishedAt: 10));
        // lastTrainedAt never goes back.
        expect((await t.repertoires.get(rep))!.lastTrainedAt, 5000);
      },
    );

    test('a failing insert writes nothing (transaction)', () async {
      final run = runOn(rep, lines.first, id: 'dup', finishedAt: 1);
      await t.runs.insertRun(run);
      await expectLater(
        t.runs.insertRun(
          runOn(rep, lines.first, id: 'dup', finishedAt: 2, credits: [0, 0, 0]),
        ),
        throwsA(anything),
      );
      final runs = await t.runs.runsForRepertoire(rep);
      expect(runs.single.grades, hasLength(2));
    });

    test('runs come back ordered; recent keys newest first', () async {
      await t.runs.insertRun(runOn(rep, lines[0], id: 'b', finishedAt: 300));
      await t.runs.insertRun(runOn(rep, lines[1], id: 'a', finishedAt: 100));
      await t.runs.insertRun(runOn(rep, lines[2], id: 'c', finishedAt: 200));
      expect(
        [for (final r in await t.runs.runsForRepertoire(rep)) r.id],
        ['a', 'c', 'b'],
      );
      expect(await t.runs.recentStartedLineKeys(rep, 2), [
        lines[0].key,
        lines[2].key,
      ]);
      expect(await t.runs.runsForRepertoire('other'), isEmpty);
    });

    test('sync bookkeeping', () async {
      final r1 = runOn(rep, lines[0], id: 'r1', finishedAt: 1);
      final r2 = runOn(rep, lines[1], id: 'r2', finishedAt: 2);
      await t.runs.insertRun(r1);
      await t.runs.insertRun(r2);
      expect([for (final r in await t.runs.unsyncedRuns()) r.id], ['r1', 'r2']);
      await t.runs.markSynced(['r1'], 99);
      expect([for (final r in await t.runs.unsyncedRuns()) r.id], ['r2']);
      final r3 = runOn(rep, lines[2], id: 'r3', finishedAt: 3);
      final inserted = await t.runs.insertIfAbsent([r1, r3, r3], syncedAt: 7);
      expect(inserted, [r3]);
      expect([for (final r in await t.runs.unsyncedRuns()) r.id], ['r2']);
      expect(await t.runs.runsForRepertoire(rep), hasLength(3));
    });

    test('training days count completed runs only', () async {
      await t.runs.insertRun(
        runOn(rep, lines[0], id: 'a', finishedAt: 1, day: '2026-10-01'),
      );
      await t.runs.insertRun(
        runOn(rep, lines[0], id: 'b', finishedAt: 2, day: '2026-10-01'),
      );
      await t.runs.insertRun(
        runOn(
          rep,
          lines[0],
          id: 'c',
          finishedAt: 3,
          day: '2026-10-02',
          completed: false,
        ),
      );
      expect(await t.runs.trainingDays(), {'2026-10-01'});
    });
  });

  group('StatsService', () {
    test('stats after a sequence of runs equal pure derivation', () async {
      final runs = [
        runOn(rep, lines[0], id: '1', finishedAt: 10, credits: [1, 0]),
        runOn(rep, lines[0], id: '2', finishedAt: 20, mode: RunMode.srs),
        runOn(rep, lines[3], id: '3', finishedAt: 30, credits: [0, 0]),
        // Old, shorter line: inherited by every line through it.
        runOn(
          rep,
          lines[0],
          id: '4',
          finishedAt: 40,
          ucis: lines[0].ucis.split(' ').take(6).join(' '),
        ),
        // Archived: no current line matches.
        runOn(rep, lines[0], id: '5', finishedAt: 50, ucis: 'g1f3 d7d5'),
      ];
      for (final r in runs) {
        await t.service.recordRun(r);
      }
      final expected = deriveRepertoire(lines: lines, runs: runs);
      final stored = {
        for (final s in await t.stats.lineStats(rep)) s.lineKey: s,
      };
      expect(stored.length, expected.length);
      for (final s in expected) {
        expect(stored[s.lineKey], s, reason: s.lineKey);
      }
      // Full rebuild gives the same.
      await t.service.rebuildRepertoire(rep);
      final rebuilt = {
        for (final s in await t.stats.lineStats(rep)) s.lineKey: s,
      };
      expect(rebuilt, stored);
    });

    test('big histories derive in an isolate with the same result', () async {
      final inIsolate = TestDb(isolateThreshold: 0);
      addTearDown(inIsolate.close);
      final pgn = fixture('demo_italian_white.pgn');
      final id = await inIsolate.repertoires.create(
        name: 'I',
        color: Side.white,
        pgn: pgn,
        result: importPgn(pgn, Side.white),
      );
      final run = runOn(id, lines[2], id: 'x', finishedAt: 5, credits: [0, 1]);
      await inIsolate.service.recordRun(run);
      await inIsolate.service.rebuildAll();
      final s = (await inIsolate.stats.lineStats(id))
          .firstWhere((s) => s.lineKey == lines[2].key);
      expect(s.accuracy, 0.5);
      expect(s.inWeakPool, isTrue);
    });

    test('watchSummaries emits updated values after a run insert', () async {
      final stream = t.repertoires.watchSummaries(today: '2026-10-06');
      final updates = <(double?, int)>[];
      final sub = stream.listen(
        (l) => updates.add((l.single.accuracy, l.single.weakCount)),
      );
      await pumpEventQueue();
      await t.service.recordRun(
        runOn(rep, lines[0], id: 'w', finishedAt: 99, credits: [0, 1]),
      );
      await pumpEventQueue();
      await sub.cancel();
      expect(updates.first, (null, 0));
      expect(updates.last, (0.5, 1));
      final summary = (await stream.first).single;
      expect(summary.lastTrainedAt, 99);
    });

    test('due counts follow SRS state and the given day', () async {
      await t.service.recordRun(
        runOn(rep, lines[0], id: 's', finishedAt: 1, mode: RunMode.srs),
      );
      Future<int> due(String day) async =>
          (await t.repertoires.watchSummaries(today: day).first)
              .single
              .dueCount;
      expect(await due('2026-10-06'), 0);
      expect(await due('2026-10-07'), 1);
    });

    test('re-import: runs untouched, stats re-attributed', () async {
      final v1 = fixture('reimport_v1.pgn');
      final id = await t.repertoires.create(
        name: 'R',
        color: Side.white,
        pgn: v1,
        result: importPgn(v1, Side.white),
      );
      final old = await t.repertoires.lineRefs(id); // Bb5, Bc4, c5
      final runs = [
        runOn(id, old[0], id: 'u', finishedAt: 1),
        runOn(id, old[1], id: 'e', finishedAt: 2, credits: [1, 0]),
        runOn(id, old[2], id: 'g', finishedAt: 3, credits: [0, 0]),
      ];
      for (final r in runs) {
        await t.service.recordRun(r);
      }
      final v2 = fixture('reimport_v2.pgn');
      await t.repertoires.reimport(
        id,
        pgn: v2,
        result: importPgn(v2, Side.white),
      );
      await t.service.rebuildRepertoire(id);

      expect(await t.runs.runsForRepertoire(id), runs);
      final now = await t.repertoires.lineRefs(id);
      final stats = {for (final s in await t.stats.lineStats(id)) s.lineKey: s};
      expect(stats[now[0].key]!.runCount, 1); // unchanged Bb5
      expect(stats[now[1].key]!.accuracy, 0.5); // Bc4 extended: inherited
      expect(stats[now[1].key]!.srs.phase, SrsPhase.fresh);
      expect(stats[now[2].key]!.runCount, 0); // new e6 line
      expect(stats[old[2].key]!.archived, isTrue); // removed c5 line
      expect(stats[old[2].key]!.accuracy, 0.0);
      expect(stats.containsKey(old[1].key), isFalse);
    });

    test('changing weak thresholds re-derives everything', () async {
      await t.service.recordRun(
        runOn(
          rep,
          lines[0],
          id: 'a',
          finishedAt: 1,
          credits: [1, 1, 1, 1, 0.5],
        ),
      );
      Future<bool> weak() async =>
          (await t.stats.lineStats(rep))
              .firstWhere((s) => s.lineKey == lines[0].key)
              .inWeakPool;
      expect(await weak(), isFalse); // 90 % >= 80 %
      t.service.listenToSettings(t.settings.watch());
      await pumpEventQueue();
      await t.settings.update((s) => s.copyWith(weakEnterBelowPercent: 95));
      for (var i = 0; i < 20 && !await weak(); i++) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
      expect(await weak(), isTrue);
    });
  });
}
