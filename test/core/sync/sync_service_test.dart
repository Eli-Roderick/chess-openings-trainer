import 'dart:io' as io;
import 'dart:typed_data';

import 'package:chess_core/chess_core.dart';
import 'package:dartchess/dartchess.dart' show Side;
import 'package:flutter_test/flutter_test.dart';
import 'package:repertoire_trainer/core/db/merge_applier.dart';
import 'package:repertoire_trainer/core/sync/drive_transport.dart';
import 'package:repertoire_trainer/core/sync/sync_service.dart';

import '../../run_fixtures.dart';
import '../db/db_test_helpers.dart';
import 'fake_drive.dart';

const _pgn = '1. e4 e5 2. Nf3 (2. Bc4) *';
const _pgn2 = '1. e4 e5 2. Nf3 Nc6 (2... d6) *';

/// A simulated device: its own database and id, the shared Drive.
final class _Device {
  new(this.name, this.drive) : t = TestDb(idPrefix: name);

  final String name;
  final FakeDriveTransport drive;
  final TestDb t;
  final waits = <Duration>[];
  int refreshes = 0;

  late final service = SyncService(
    connect: () async => drive,
    refreshAuth: () async => refreshes++,
    applier: MergeApplier(
      db: t.db,
      repertoires: t.repertoires,
      runs: t.runs,
      stats: t.service,
      buildTree: (r) async =>
          importPgn(r.pgn, r.color == 'b' ? Side.black : Side.white).tree,
      clock: t.clock,
    ),
    repertoires: t.repertoires,
    runs: t.runs,
    state: t.sync,
    deviceId: t.sync.deviceId,
    clock: t.clock,
    deviceName: name,
    wait: (d) async => waits.add(d),
  );

  Future<String> me() => t.sync.deviceId();

  Future<String> create(String name, [String pgn = _pgn]) =>
      t.repertoires.create(
        name: name,
        color: Side.white,
        pgn: pgn,
        result: importPgn(pgn, Side.white),
      );

  var _runs = 0;

  Future<void> train(String rep, {List<double> credits = const [1, 1]}) async {
    final line = (await t.repertoires.lineRefs(rep)).first;
    t.clock.advance(const Duration(minutes: 1));
    await t.service.recordRun(
      fixtureRun(
        rep,
        id: '$name-run-${++_runs}',
        key: line.key,
        ucis: line.ucis,
        day: '2026-10-06',
        credits: credits,
        at: t.clock.now().millisecondsSinceEpoch,
      ).copyWith(deviceId: await me()),
    );
  }

  /// Everything that must converge: records, runs, derived stats.
  Future<String> snapshot() async {
    final reps = await t.repertoires.records();
    return [
      reps,
      [for (final r in await t.runs.allRuns()) r.id],
      [for (final r in reps) await t.stats.lineStats(r.id)],
    ].toString();
  }
}

void main() {
  late FakeDriveTransport drive;
  late _Device a;
  late _Device b;

  setUp(() {
    drive = FakeDriveTransport();
    a = _Device('a', drive);
    b = _Device('b', drive);
  });

  tearDown(() async {
    await a.t.close();
    await b.t.close();
  });

  test('file names name their device', () {
    expect(metaFileName('dev-1'), 'rt1-dev-1-meta.json.gz');
    expect(deviceOfFile('rt1-dev-1-meta.json.gz'), 'dev-1');
    expect(deviceOfFile('rt1-dev-1-runs-2026-10.jsonl.gz'), 'dev-1');
    expect(deviceOfFile('other.txt'), isNull);
  });

  test('two devices converge; a second sync moves nothing', () async {
    final rep = await a.create('Italian');
    await a.train(rep);
    await a.train(rep, credits: [1, 0]);
    final first = await a.service.sync();
    expect((first.downloaded, first.uploaded), (0, 2));

    final pulled = await b.service.sync();
    expect(pulled.downloaded, 2);
    expect(pulled.merge.insertedRuns, 2);
    await b.train(rep);
    await b.service.sync();
    await a.service.sync();
    await b.service.sync();
    expect(await b.snapshot(), await a.snapshot());

    drive.reset();
    final quiet = await a.service.sync();
    await b.service.sync();
    expect((quiet.downloaded, quiet.uploaded), (0, 0));
    expect(drive.transfers, 0);
    // Runs are never duplicated.
    expect((await a.t.runs.allRuns()).length, 3);
  });

  test('rename conflict: the newest wins on both devices', () async {
    final rep = await a.create('Italian');
    await a.service.sync();
    await b.service.sync();
    a.t.clock.advance(const Duration(minutes: 1));
    await a.t.repertoires.rename(rep, 'Older name');
    b.t.clock.advance(const Duration(minutes: 2));
    await b.t.repertoires.rename(rep, 'Newer name');
    await a.service.sync();
    final fromB = await b.service.sync();
    expect(fromB.updatedFromOtherDevice, isEmpty);
    final fromA = await a.service.sync();
    expect(fromA.updatedFromOtherDevice, ['Newer name']);
    for (final d in [a, b]) {
      expect((await d.t.repertoires.get(rep))!.name, 'Newer name');
    }
  });

  test('a delete propagates and drops the runs; a re-import propagates its '
      'tree', () async {
    final keep = await a.create('Keep');
    final drop = await a.create('Drop');
    await a.train(drop);
    await a.service.sync();
    await b.service.sync();
    expect(await b.t.runs.runsForRepertoire(drop), hasLength(1));
    a.t.clock.advance(const Duration(minutes: 1));
    await a.t.repertoires.softDelete(drop);
    await a.t.repertoires.reimport(
      keep,
      pgn: _pgn2,
      result: importPgn(_pgn2, Side.white),
    );
    await a.service.sync();
    await b.service.sync();
    expect((await b.t.repertoires.get(drop))!.deleted, isTrue);
    expect(await b.t.runs.runsForRepertoire(drop), isEmpty);
    final tree = await b.t.repertoires.loadTree(keep);
    expect(tree.lines.map((l) => l.ucis), contains('e2e4 e7e5 g1f3 d7d6'));
  });

  test('a newer-schema file is skipped with a warning; sync goes on', () async {
    final rep = await a.create('Italian');
    await a.service.sync();
    await drive.create(
      'rt1-future-meta.json.gz',
      Uint8List.fromList(
        io.gzip.encode(
          '{"format":"rt-sync-meta","schema":9,"repertoires":[]}'.codeUnits,
        ),
      ),
    );
    await drive.create(
      'rt1-broken-meta.json.gz',
      Uint8List.fromList([1, 2, 3]),
    );
    final r = await b.service.sync();
    expect([
      for (final w in r.warnings) (w.deviceId, w.newerSchema),
    ], unorderedEquals([('future', true), ('broken', false)]));
    expect(await b.t.repertoires.get(rep), isNotNull);
  });

  test(
    'rate limits back off 2, 4, 8 s, then fail until the next trigger',
    () async {
      await a.create('Italian');
      var limited = 2;
      drive.onCall = (op) {
        if (op == 'list' && limited-- > 0) throw const SyncRateLimited('quota');
      };
      await a.service.sync();
      expect(a.waits, [const Duration(seconds: 2), const Duration(seconds: 4)]);
      drive.onCall = (op) {
        if (op == 'list') throw const SyncRateLimited('quota');
      };
      a.waits.clear();
      await expectLater(a.service.sync(), throwsA(isA<SyncRateLimited>()));
      expect(a.waits, [
        const Duration(seconds: 2),
        const Duration(seconds: 4),
        const Duration(seconds: 8),
      ]);
    },
  );

  test('a 401 refreshes once and retries the whole sync', () async {
    await a.create('Italian');
    var fail = true;
    drive.onCall = (op) {
      if (op == 'list' && fail) {
        fail = false;
        throw const SyncAuthExpired('401');
      }
    };
    final r = await a.service.sync();
    expect((a.refreshes, r.uploaded), (1, 1));
  });

  test(
    'a failure at any step loses nothing: the next sync converges',
    () async {
      final rep = await a.create('Italian');
      await a.train(rep);
      await a.service.sync();
      await b.create('Other', _pgn2);
      final bRep = (await b.t.repertoires.records()).single.id;
      await b.train(bRep);
      for (final step in ['list', 'download', 'create', 'update']) {
        // Every call of this kind fails once, at each position in turn.
        for (var nth = 1; nth <= 3; nth++) {
          var count = 0;
          drive.onCall = (op) {
            if (op == step && ++count == nth) throw const SyncOffline('down');
          };
          final before = await b.snapshot();
          try {
            await b.service.sync();
          } on SyncOffline {
            // The database is unchanged or consistently advanced: every
            // run that is stored has its grades and derived stats.
            final runs = await b.t.runs.allRuns();
            expect(runs.every((r) => r.grades.length == r.gradedCount), isTrue);
            expect(await b.snapshot(), isNot(isEmpty), reason: before);
          }
          drive.onCall = null;
        }
      }
      await b.service.sync();
      await a.service.sync();
      await b.service.sync();
      expect(await b.snapshot(), await a.snapshot());
      expect((await a.t.runs.allRuns()).length, 2);
    },
  );

  test('concurrent calls share one sync', () async {
    await a.create('Italian');
    final f1 = a.service.sync();
    final f2 = a.service.sync();
    expect(identical(await f1, await f2), isTrue);
    expect(drive.calls.where((c) => c == 'list'), hasLength(1));
  });

  test('delete cloud data removes every sync file', () async {
    await a.create('Italian');
    await a.service.sync();
    await b.service.sync();
    expect(drive.files, isNotEmpty);
    expect(await a.service.deleteCloudData(), 2);
    expect(drive.files, isEmpty);
    // The next sync uploads the meta again.
    expect((await a.service.sync()).uploaded, 1);
  });
}
