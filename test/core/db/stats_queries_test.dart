import 'dart:io' as io;

import 'package:chess_core/chess_core.dart';
import 'package:dartchess/dartchess.dart' show Side;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:repertoire_trainer/core/db/app_database.dart';
import 'package:repertoire_trainer/core/db/repositories/run_repository.dart';
import 'package:repertoire_trainer/core/db/stats_queries.dart';
import 'package:repertoire_trainer/features/stats/stats_data.dart';

import '../../run_fixtures.dart';
import 'db_test_helpers.dart';

void main() {
  const pgn = '1. e4 e5 2. Nf3 (2. Bc4) *';
  late TestDb t;
  late StatsQueries q;
  late String rep;
  late RepertoireTree tree;
  late LineRef a;
  late LineRef b;
  late List<RunRecord> all;

  setUp(() async {
    t = TestDb();
    q = StatsQueries(t.db);
    rep = await t.repertoires.create(
      name: 'R',
      color: Side.white,
      pgn: pgn,
      result: importPgn(pgn, Side.white),
    );
    tree = await t.repertoires.loadTree(rep);
    final refs = await t.repertoires.lineRefs(rep);
    a = refs.firstWhere((l) => l.ucis.contains('g1f3'));
    b = refs.firstWhere((l) => l.ucis.contains('f1c4'));
    all = [
      fixtureRun(
        rep,
        id: 'r1',
        key: a.key,
        ucis: a.ucis,
        day: '2026-10-01',
        credits: [1, 0],
        at: 1,
      ),
      fixtureRun(
        rep,
        id: 'r2',
        key: a.key,
        ucis: a.ucis,
        day: '2026-10-01',
        credits: [1, 1],
        at: 2,
      ),
      fixtureRun(
        rep,
        id: 'r3',
        key: b.key,
        ucis: b.ucis,
        day: '2026-10-03',
        credits: [0, 1],
        at: 3,
      ),
      // An old line that was extended: inherited by both current lines.
      fixtureRun(
        rep,
        id: 'r4',
        key: 'gone',
        ucis: 'e2e4 e7e5',
        day: '2026-10-03',
        credits: [1],
        at: 4,
      ),
      // Removed by a re-import: archived.
      fixtureRun(
        rep,
        id: 'r5',
        key: 'old',
        ucis: 'd2d4 d7d5',
        day: '2026-10-04',
        credits: [1],
        at: 5,
      ),
      fixtureRun(
        rep,
        id: 'r6',
        key: a.key,
        ucis: a.ucis,
        day: '2026-10-04',
        credits: [0],
        completed: false,
        at: 6,
      ),
      fixtureRun(
        rep,
        id: 'r7',
        key: a.key,
        ucis: a.ucis,
        day: '2026-10-05',
        credits: [1, 1],
        at: 7,
        deviation: const DeviationEvent(
          ply: 6,
          bestUci: 'f8c5',
          passed: false,
          deviationUci: 'b8c6',
          replyUci: 'h2h3',
          lossCp: 80,
        ),
      ),
    ];
    for (final r in all) {
      await t.service.recordRun(r);
    }
  });

  tearDown(() => t.close());

  test('daily aggregates match the pure daily accuracy', () async {
    final daily = await q.daily(rep);
    expect(
      [for (final d in daily) (d.day, d.creditSum, d.gradedSum, d.runCount)],
      [
        ('2026-10-01', 3.0, 4, 2),
        ('2026-10-03', 2.0, 3, 2),
        ('2026-10-04', 1.0, 1, 1),
        ('2026-10-05', 2.0, 2, 1),
      ],
    );
    expect({for (final d in daily) d.day: d.accuracy}, dailyAccuracy(all));
    expect(await q.completedRuns(rep), 6);
  });

  test('most missed: plies mapped to tree nodes, min attempts', () async {
    final rows = await q.plyMisses(rep);
    // e4 counts over the Nf3 line, the Bc4 line and the old prefix (the
    // archived d4 is not in the tree); Bc4 was never missed.
    final top = mostMissed(tree, rows);
    expect(
      [for (final m in top) (m.node.san, m.misses, m.attempts)],
      [('Nf3', 1, 3), ('e4', 1, 5)],
    );
    final four = mostMissed(tree, rows, minAttempts: 4);
    expect([for (final m in four) m.node.san], ['e4']);
  });

  test('deviation replies', () async {
    final d = await q.deviations(rep);
    expect((d.count, d.passed, d.rate), (1, 0, 0.0));
    expect(d.recent.single.lineKey, a.key);
    expect(d.recent.single.event.replyUci, 'h2h3');
  });

  test('line history: direct, inherited and archived attribution', () async {
    final index = LineIndex(await t.repertoires.lineRefs(rep));
    final ofA = lineHistory(index, a.key, await t.runs.runsAlong(rep, a.ucis));
    expect([for (final r in ofA) r.id], ['r1', 'r2', 'r4', 'r6', 'r7']);
    expect(ofA.first.grades, hasLength(2));
    final ofB = lineHistory(index, b.key, await t.runs.runsAlong(rep, b.ucis));
    expect([for (final r in ofB) r.id], ['r3', 'r4']);
    final old = lineHistory(index, 'old', await t.runs.runsForKey(rep, 'old'));
    expect([for (final r in old) r.id], ['r5']);
    // The extended line's own key is not archived: its runs moved on.
    final gone = lineHistory(
      index,
      'gone',
      await t.runs.runsForKey(rep, 'gone'),
    );
    expect(gone, isEmpty);
    expect(await q.ucisByKey(rep), containsPair('old', 'd2d4 d7d5'));
    expect(ucisLabel('d2d4 d7d5'), '1.d4 d5');
    expect(ucisLabel('e2e4 e7e5 g1f3 b8c6 f1b5'), '…1...e5 2.Nf3 Nc6 3.Bb5');
  });

  test('training days update live', () async {
    final seen = <Set<String>>[];
    final sub = t.runs.watchTrainingDays().listen(seen.add);
    await pumpEventQueue();
    await t.runs.insertRun(
      fixtureRun(
        rep,
        id: 'r8',
        key: a.key,
        ucis: a.ucis,
        day: '2026-10-06',
        credits: [1],
        at: 8,
      ),
    );
    await pumpEventQueue();
    await sub.cancel();
    expect(seen.first, {
      '2026-10-01',
      '2026-10-03',
      '2026-10-04',
      '2026-10-05',
    });
    expect(seen.last, contains('2026-10-06'));
  });

  test('ply_stats: kept by recordRun, rebuilt from the grades', () async {
    final incremental = await q.plyMisses(rep);
    await t.service.rebuildRepertoire(rep);
    final rebuilt = await q.plyMisses(rep);
    String key(PlyMisses m) => '${m.ucis}|${m.ply}|${m.attempts}|${m.misses}';
    expect(rebuilt.map(key).toSet(), incremental.map(key).toSet());
    // The abandoned run is not counted.
    final nf3 = rebuilt.firstWhere((m) => m.ucis == a.ucis && m.ply == 3);
    expect((nf3.attempts, nf3.misses), (3, 1));
  });

  test('migration 1 → 2 creates and fills ply_stats', () async {
    final dir = await io.Directory.systemTemp.createTemp('rt_mig_');
    final file = io.File(p.join(dir.path, 'db.sqlite'));
    final v2 = AppDatabase(NativeDatabase(file));
    final repo = DriftRunRepository(v2);
    for (final r in all) {
      await repo.insertRun(r.copyWith(repertoireId: 'x'));
    }
    // Back to the version 1 schema.
    await v2.customStatement('DROP TABLE ply_stats');
    await v2.customStatement('DROP INDEX runs_daily_stats');
    await v2.customStatement('DROP INDEX runs_key_ucis');
    await v2.customStatement('PRAGMA user_version = 1');
    await v2.close();
    final upgraded = AppDatabase(NativeDatabase(file));
    final misses = await StatsQueries(upgraded).plyMisses('x');
    final nf3 = misses.firstWhere((m) => m.ucis == a.ucis && m.ply == 3);
    expect((nf3.attempts, nf3.misses), (3, 1));
    expect(await StatsQueries(upgraded).completedRuns('x'), 6);
    await upgraded.close();
    await dir.delete(recursive: true);
  });
}
