import 'package:chess_core/chess_core.dart';
import 'package:dartchess/dartchess.dart' show Side;
import 'package:flutter_test/flutter_test.dart';
import 'package:repertoire_trainer/core/db/recovery_service.dart';
import 'package:repertoire_trainer/core/db/repositories/snapshot_repository.dart';

import '../../run_fixtures.dart';
import 'db_test_helpers.dart';

const _v1 = '1. e4 e5 2. Nf3 (2. Bc4) *';
const _v2 = '1. e4 e5 2. Nf3 Nc6 3. Bb5 *';

void main() {
  late TestDb t;
  late SnapshotRepository snapshots;
  late RecoveryService recovery;
  late String rep;

  setUp(() async {
    t = TestDb();
    snapshots = SnapshotRepository(t.db);
    recovery = RecoveryService(
      db: t.db,
      repertoires: t.repertoires,
      snapshots: snapshots,
      stats: t.service,
      buildTree: (r) async => importPgn(r.pgn, Side.white).tree,
      clock: t.clock,
      deviceId: t.sync.deviceId,
    );
    rep = await t.repertoires.create(
      name: 'Vienna',
      color: Side.white,
      pgn: _v1,
      result: importPgn(_v1, Side.white),
    );
    final line = (await t.repertoires.lineRefs(rep)).first;
    await t.service.recordRun(
      fixtureRun(
        rep,
        id: 'r1',
        key: line.key,
        ucis: line.ucis,
        day: '2026-10-05',
        credits: [1, 1],
      ),
    );
  });

  tearDown(() => t.close());

  Future<String> pgnOf(String id) async => (await t.repertoires.get(id))!.pgn;

  test('re-import saves the replaced version; restoring it brings the old '
      'moves back, keeps runs and saves the version it replaced', () async {
    await t.repertoires.reimport(
      rep,
      pgn: _v2,
      result: importPgn(_v2, Side.white),
    );
    final saved = await snapshots.watchAll().first;
    expect(
      [for (final s in saved) (s.reason, s.record.pgn)],
      [(SnapshotReason.reimport, _v1)],
    );
    t.clock.advance(const Duration(minutes: 1));
    await recovery.restoreVersion(saved.single.id);
    expect(await pgnOf(rep), _v1);
    expect(
      (await t.repertoires.loadTree(rep)).lines.map((l) => l.ucis),
      contains('e2e4 e7e5 f1c4'),
    );
    expect(await t.runs.runsForRepertoire(rep), hasLength(1));
    expect(await t.stats.lineStats(rep), isNotEmpty);
    final after = await snapshots.watchAll().first;
    expect([for (final s in after) s.record.pgn], [_v2, _v1]);
    // Newer than before, so sync spreads it.
    final record = (await t.repertoires.records()).single;
    expect(record.updatedAt, t.clock.now().millisecondsSinceEpoch);
  });

  test('versions are bounded per repertoire and the same PGN is kept '
      'once', () async {
    for (var i = 0; i < maxSnapshotsPerRepertoire + 5; i++) {
      t.clock.advance(const Duration(seconds: 1));
      final pgn = '1. e4 e5 2. Nf3 Nc6 ${i + 3}. Bc4 *';
      await t.repertoires.reimport(
        rep,
        pgn: pgn,
        result: importPgn(pgn, Side.white),
      );
    }
    final record = (await t.repertoires.records()).single;
    await saveSnapshot(
      t.db,
      record,
      SnapshotReason.replaced,
      now: t.clock.now().millisecondsSinceEpoch,
    );
    await saveSnapshot(
      t.db,
      record,
      SnapshotReason.replaced,
      now: t.clock.now().millisecondsSinceEpoch,
    );
    final all = await snapshots.watchAll().first;
    expect(all, hasLength(maxSnapshotsPerRepertoire));
    expect(all.where((s) => s.record.pgnHash == record.pgnHash), hasLength(1));
  });

  test('a locally deleted repertoire is in the trash and comes back with '
      'its stats', () async {
    final stats = await t.stats.lineStats(rep);
    await t.repertoires.softDelete(rep);
    final trash = await snapshots.watchTrash().first;
    expect([for (final e in trash) (e.name, e.hasData)], [('Vienna', true)]);
    await recovery.restoreDeleted(rep);
    expect((await t.repertoires.get(rep))!.deleted, isFalse);
    expect(await t.stats.lineStats(rep), stats);
    expect(await snapshots.watchTrash().first, isEmpty);
  });

  test('a repertoire known only by a saved version is restored from it; '
      'delete forever removes data and versions', () async {
    final record = (await t.repertoires.records()).single;
    await saveSnapshot(t.db, record, SnapshotReason.restore, now: 1);
    await t.repertoires.deleteAll();
    expect(await snapshots.watchTrash().first, [
      TrashEntry(
        repertoireId: rep,
        name: 'Vienna',
        deletedAt: 1,
        hasData: false,
      ),
    ]);
    await recovery.restoreDeleted(rep);
    expect(await pgnOf(rep), _v1);
    expect(await t.repertoires.lineRefs(rep), isNotEmpty);

    await t.repertoires.softDelete(rep);
    await recovery.deleteForever(rep);
    expect(await t.repertoires.lineRefs(rep), isEmpty);
    expect(await snapshots.watchAll().first, isEmpty);
    expect(await snapshots.watchTrash().first, isEmpty);
    // The tombstone stays for sync.
    expect((await t.repertoires.get(rep))!.deleted, isTrue);
  });

  test(
    'a rejected version or one that does not import is not restored',
    () async {
      final record = (await t.repertoires.records()).single;
      await saveSnapshot(
        t.db,
        record.copyWith(pgn: '1. e4 e5 2. Ke3 *', pgnHash: 'bad'),
        SnapshotReason.rejected,
        now: 1,
      );
      await saveSnapshot(
        t.db,
        record.copyWith(pgn: '1. e4 e5 2. Ke3 *', pgnHash: 'bad2'),
        SnapshotReason.replaced,
        now: 2,
      );
      final [broken, rejected] = await snapshots.watchAll().first;
      expect(
        () => recovery.restoreVersion(rejected.id),
        throwsA(isA<VersionNotRestorable>()),
      );
      expect(
        () => recovery.restoreVersion(broken.id),
        throwsA(isA<VersionNotRestorable>()),
      );
      expect(await pgnOf(rep), _v1);
    },
  );
}
