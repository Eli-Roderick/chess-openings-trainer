import 'dart:io' as io;

import 'package:chess_core/chess_core.dart';
import 'package:dartchess/dartchess.dart' show Side;
import 'package:flutter_test/flutter_test.dart';
import 'package:repertoire_trainer/core/db/repositories/repertoire_repository.dart';

import 'db_test_helpers.dart';

String fixture(String name) =>
    io.File('packages/chess_core/test/fixtures/$name').readAsStringSync();

Future<String> warmUpId(TestDb t) {
  final pgn = fixture('one_line.pgn');
  return t.repertoires.create(
    name: 'warm-up',
    color: Side.white,
    pgn: pgn,
    result: importPgn(pgn, Side.white),
  );
}

void main() {
  late TestDb t;
  setUp(() => t = TestDb());
  tearDown(() => t.close());

  Future<String> createDemo({String name = 'Italian'}) {
    final pgn = fixture('demo_italian_white.pgn');
    return t.repertoires.create(
      name: name,
      color: Side.white,
      pgn: pgn,
      result: importPgn(pgn, Side.white),
    );
  }

  test('create then loadTree equals the imported tree', () async {
    final pgn = fixture('lichess_study_export.pgn');
    final imported = importPgn(pgn, Side.white).tree!;
    final id = await t.repertoires.create(
      name: '  Study  ',
      color: Side.white,
      pgn: pgn,
      result: importPgn(pgn, Side.white),
    );
    t.repertoires.invalidateForTest(id);
    final loaded = await t.repertoires.loadTree(id);
    expect(loaded.toRows().nodes, imported.toRows().nodes);
    expect(loaded.toRows().lines, imported.toRows().lines);
    expect(loaded.description, imported.description);
    expect(loaded.userSide, Side.white);
    // Shapes and comments survive.
    expect(
      loaded.nodes.firstWhere((n) => n.san == 'Bc4').comment!.shapes,
      hasLength(2),
    );

    final row = (await t.repertoires.get(id))!;
    expect(row.name, 'Study');
    expect(row.color, 'w');
    expect(row.pgn, normalizePgnText(pgn));
    expect(row.pgnHash, pgnHashOf(row.pgn));
    expect(row.createdAt, t.clock.now().millisecondsSinceEpoch);
    expect(row.updatedBy, await t.sync.deviceId());
    expect(row.deleted, isFalse);
    expect(await t.repertoires.allIds(), [id]);
    expect(await t.repertoires.get('nope'), isNull);
    expect(() => t.repertoires.loadTree('nope'), throwsStateError);
  });

  test('create writes empty derived stats for every line', () async {
    final id = await createDemo();
    final stats = await t.stats.lineStats(id);
    expect(stats, hasLength(12));
    expect(stats.every((s) => s.runCount == 0 && !s.archived), isTrue);
    final refs = await t.repertoires.lineRefs(id);
    expect([for (final r in refs) r.ordinal], List.generate(12, (i) => i));
  });

  test('create rejects an import with errors', () async {
    expect(
      () => t.repertoires.create(
        name: 'x',
        color: Side.white,
        pgn: '1. e4 &',
        result: importPgn('1. e4 &', Side.white),
      ),
      throwsArgumentError,
    );
  });

  test('a failure mid-transaction rolls everything back', () async {
    final failing = TestDb(
      debugHook: (stage) {
        if (stage == 'create:tree') throw StateError('boom');
      },
    );
    addTearDown(failing.close);
    final pgn = fixture('one_line.pgn');
    await expectLater(
      failing.repertoires.create(
        name: 'x',
        color: Side.white,
        pgn: pgn,
        result: importPgn(pgn, Side.white),
      ),
      throwsStateError,
    );
    expect(await failing.repertoires.allIds(), isEmpty);
    expect(await failing.db.select(failing.db.nodes).get(), isEmpty);
    expect(await failing.db.select(failing.db.lines).get(), isEmpty);
  });

  test(
    're-import replaces nodes and lines, keeps runs, returns the diff',
    () async {
      final v1 = fixture('reimport_v1.pgn');
      final id = await t.repertoires.create(
        name: 'R',
        color: Side.white,
        pgn: v1,
        result: importPgn(v1, Side.white),
      );
      final before = await t.repertoires.loadTree(id);
      t.clock.advance(const Duration(minutes: 5));
      final v2 = fixture('reimport_v2.pgn');
      final diff = await t.repertoires.reimport(
        id,
        pgn: v2,
        result: importPgn(v2, Side.white),
      );
      expect(diff.unchanged, hasLength(1));
      expect(diff.extended, hasLength(1));
      expect(diff.removed, hasLength(1));
      expect(diff.added, hasLength(1));
      final after = await t.repertoires.loadTree(id);
      expect(identical(before, after), isFalse);
      expect(
        after.toRows().nodes,
        importPgn(v2, Side.white).tree!.toRows().nodes,
      );
      final row = (await t.repertoires.get(id))!;
      expect(row.updatedAt, row.createdAt + 300000);
      expect(row.pgn, v2);
    },
  );

  test('a failed re-import leaves the old version', () async {
    late TestDb failing;
    failing = TestDb(
      debugHook: (stage) {
        if (stage == 'reimport:deleted') throw StateError('boom');
      },
    );
    addTearDown(failing.close);
    final v1 = fixture('reimport_v1.pgn');
    final id = await failing.repertoires.create(
      name: 'R',
      color: Side.white,
      pgn: v1,
      result: importPgn(v1, Side.white),
    );
    final v2 = fixture('reimport_v2.pgn');
    await expectLater(
      failing.repertoires.reimport(
        id,
        pgn: v2,
        result: importPgn(v2, Side.white),
      ),
      throwsStateError,
    );
    failing.repertoires.invalidateForTest(id);
    final tree = await failing.repertoires.loadTree(id);
    expect(tree.lines, hasLength(3));
    expect((await failing.repertoires.get(id))!.pgn, v1);
  });

  group('summaries', () {
    test('soft delete hides, undo restores; rename', () async {
      final a = await createDemo(name: 'A');
      t.clock.advance(const Duration(seconds: 1));
      final b = await createDemo(name: 'B');
      final stream = t.repertoires.watchSummaries(today: '2026-10-06');
      expect([for (final s in await stream.first) s.name], ['B', 'A']);
      await t.repertoires.softDelete(b);
      expect([for (final s in await stream.first) s.id], [a]);
      await t.repertoires.undoDelete(b);
      await t.repertoires.rename(a, ' Renamed ');
      final list = await stream.first;
      expect([for (final s in list) s.name], ['B', 'Renamed']);
      final s = list.last;
      expect(s.lineCount, 12);
      expect(s.accuracy, isNull);
      expect(s.dueCount, 0);
      expect(s.weakCount, 0);
      expect(s.lastTrainedAt, isNull);
      expect(s.color, Side.white);
      expect(s, list.last);
      expect(s.hashCode, list.last.hashCode);
      expect(s.toString(), contains('Renamed'));
    });
  });

  group('cache', () {
    test('LRU of 3 keyed by id and hash', () {
      final cache = RepertoireCache();
      final tree = importPgn('1. e4 *', Side.white).tree!;
      for (final id in ['a', 'b', 'c']) {
        cache.put(id, 'h', tree);
      }
      expect(cache.get('a', 'h'), same(tree)); // a is now most recent
      cache.put('d', 'h', tree); // evicts b
      expect(cache.length, 3);
      expect(cache.get('b', 'h'), isNull);
      expect(cache.get('a', 'other-hash'), isNull);
      expect(cache.get('a', 'h'), isNull); // dropped by the hash miss
      cache.invalidate('c');
      expect(cache.get('c', 'h'), isNull);
    });

    test('loadTree is served from the cache until re-import', () async {
      final id = await createDemo();
      final first = await t.repertoires.loadTree(id);
      expect(await t.repertoires.loadTree(id), same(first));
    });
  });

  group('performance (1,000-line synthetic repertoire)', () {
    final pgn = generateSyntheticPgn(lines: 1000, depth: 16, seed: 5);
    final result = importPgn(pgn, Side.white);

    // One small import first: release builds are AOT-compiled, so JIT and
    // first-statement warm-up should not count.
    Future<void> warmUp() => createDemo(name: 'warm-up');

    test('inserting the nodes takes < 300 ms', () async {
      await warmUp();
      final sw = Stopwatch()..start();
      await t.repertoires.create(
        name: 'big',
        color: Side.white,
        pgn: pgn,
        result: result,
      );
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(300));
    });

    test('loadTree takes < 150 ms', () async {
      await t.repertoires.loadTree(await warmUpId(t));
      final id = await t.repertoires.create(
        name: 'big',
        color: Side.white,
        pgn: pgn,
        result: result,
      );
      t.repertoires.invalidateForTest(id);
      final sw = Stopwatch()..start();
      final tree = await t.repertoires.loadTree(id);
      sw.stop();
      expect(tree.lines, hasLength(1000));
      expect(sw.elapsedMilliseconds, lessThan(150));
    });
  });
}
