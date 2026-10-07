import 'dart:convert';
import 'dart:typed_data';

import 'package:chess_core/chess_core.dart';
import 'package:dartchess/dartchess.dart' show Side;
import 'package:flutter_test/flutter_test.dart';
import 'package:repertoire_trainer/core/db/backup_queries.dart';
import 'package:repertoire_trainer/core/db/merge_applier.dart';
import 'package:repertoire_trainer/core/db/repositories/snapshot_repository.dart';
import 'package:repertoire_trainer/core/db/stats_queries.dart';
import 'package:repertoire_trainer/core/settings/app_settings.dart';
import 'package:repertoire_trainer/features/backup/backup_service.dart';

import '../../run_fixtures.dart';
import 'db_test_helpers.dart';

MergeApplier _applier(
  TestDb t, {
  void Function(String stage)? hook,
  TreeBuilder? buildTree,
}) => MergeApplier(
  db: t.db,
  repertoires: t.repertoires,
  runs: t.runs,
  stats: t.service,
  buildTree:
      buildTree ??
      (r) async =>
          importPgn(r.pgn, r.color == 'b' ? Side.black : Side.white).tree,
  clock: t.clock,
  debugHook: hook,
);

BackupService _backup(
  TestDb t, {
  void Function(String stage)? hook,
  TreeBuilder? buildTree,
}) => BackupService(
  repertoires: t.repertoires,
  runs: t.runs,
  settings: t.settings,
  applier: _applier(t, hook: hook, buildTree: buildTree),
  queries: BackupQueries(t.db),
  deviceId: t.sync.deviceId,
  clock: t.clock,
);

const _pgn = '1. e4 e5 2. Nf3 (2. Bc4) *';
const _pgn2 = '1. e4 e5 2. Nf3 Nc6 (2... d6) *';

/// Everything a round trip must preserve: records, runs, derived stats.
Future<Object> _snapshot(TestDb t) async {
  final reps = await t.repertoires.records();
  return (
    reps,
    await t.runs.allRuns(),
    [for (final r in reps) await t.stats.lineStats(r.id)],
    [for (final r in reps) await StatsQueries(t.db).plyMisses(r.id)]
        .map(
          (l) => {
            for (final m in l) '${m.ucis}|${m.ply}|${m.attempts}|${m.misses}',
          },
        )
        .toList(),
  ).toString();
}

void main() {
  late TestDb a;
  late TestDb b;
  late String rep;

  setUp(() async {
    a = TestDb();
    b = TestDb();
    rep = await a.repertoires.create(
      name: 'R',
      color: Side.white,
      pgn: _pgn,
      result: importPgn(_pgn, Side.white),
    );
    final lines = await a.repertoires.lineRefs(rep);
    var at = 0;
    for (final l in lines) {
      for (final credits in [
        [1.0, 0.0],
        [1.0, 1.0],
      ]) {
        await a.service.recordRun(
          fixtureRun(
            rep,
            id: 'run-${at++}',
            key: l.key,
            ucis: l.ucis,
            day: '2026-10-0${at % 5 + 1}',
            credits: credits,
            at: at,
          ),
        );
      }
    }
  });

  tearDown(() async {
    await a.close();
    await b.close();
  });

  test('backup round trip: export → empty device → import (merge) gives '
      'identical repertoires, runs and derived stats', () async {
    await a.settings.update((s) => s.copyWith(themeMode: AppThemeMode.light));
    // Every column kind through the SQL JSON paths: a deviation, a
    // comparable grade with an unavailable engine, nulls.
    final line = (await a.repertoires.lineRefs(rep)).first;
    await a.service.recordRun(
      fixtureRun(
        rep,
        id: 'special',
        key: line.key,
        ucis: line.ucis,
        day: '2026-10-06',
        credits: [1, 1],
        at: 99,
        deviation: const DeviationEvent(
          ply: 6,
          bestUci: 'f8c5',
          passed: false,
          deviationUci: 'b8c6',
          replyUci: 'h2h3',
          lossCp: 75,
        ),
      ).copyWith(
        grades: [
          const MoveGrade(
            ply: 1,
            expected: 'e2e4',
            accepted: 'e2e4',
            firstAttempt: 'd2d4',
            result: GradeResult.comparable,
            credit: 0.5,
            attempts: 1,
            hintLevel: 0,
            checkStatus: CheckStatus.engineUnavailable,
          ),
          const MoveGrade(
            ply: 3,
            expected: 'g1f3',
            accepted: 'g1f3 f1c4',
            firstAttempt: 'g1f3',
            result: GradeResult.correct,
            credit: 1,
            attempts: 1,
            hintLevel: 2,
            checkCp: -40,
            checkStatus: CheckStatus.ok,
          ),
        ],
        creditSum: 1.5,
      ),
    );
    final exported = await _backup(a).export();
    expect(
      exported.fileName,
      'repertoire-trainer-backup-20261006-1200.rtbackup',
    );
    final service = _backup(b);
    final file = await service.read(exported.bytes);
    final report = await service.import(
      file,
      replace: false,
      restoreSettings: true,
    );
    expect(report.insertedRuns, 5);
    expect(report.changedIds, {rep});
    expect(await _snapshot(b), await _snapshot(a));
    expect((await b.settings.load()).themeMode, AppThemeMode.light);
    // Importing again changes nothing.
    final again = await service.import(
      file,
      replace: false,
      restoreSettings: false,
    );
    expect(again.insertedRuns, 0);
    expect(again.changedIds, isEmpty);
    expect(await _snapshot(b), await _snapshot(a));
  });

  test('replace all deletes local data first', () async {
    final other = await b.repertoires.create(
      name: 'Other',
      color: Side.black,
      pgn: _pgn2,
      result: importPgn(_pgn2, Side.black),
    );
    final service = _backup(b);
    final file = await service.read((await _backup(a).export()).bytes);
    await service.import(file, replace: true, restoreSettings: false);
    // Both test devices number their ids alike: the imported repertoire
    // replaced "Other" under the same id.
    expect(other, rep);
    expect([for (final r in await b.repertoires.records()) r.name], ['R']);
    expect(await _snapshot(b), await _snapshot(a));
  });

  test('a changed PGN rebuilds the tree and re-derives like a fresh '
      'derivation; a rename alone does not', () async {
    final local = (await a.repertoires.records()).single;
    final newer = local.copyWith(
      pgn: _pgn2,
      pgnHash: 'other',
      updatedAt: local.updatedAt + 1,
      updatedBy: 'zz',
    );
    final report = await _applier(a).apply(remote: [newer]);
    expect(report.effects.rebuildTrees, {rep});
    final tree = await a.repertoires.loadTree(rep);
    expect(tree.lines.map((l) => l.ucis), contains('e2e4 e7e5 g1f3 d7d6'));
    final fresh = deriveRepertoire(
      lines: await a.repertoires.lineRefs(rep),
      runs: await a.runs.runsForRepertoire(rep),
      settings: (await a.settings.load()).deriveSettings,
    );
    expect(await a.stats.lineStats(rep), unorderedEquals(fresh));

    final renamed = newer.copyWith(
      name: 'Renamed',
      updatedAt: newer.updatedAt + 1,
    );
    final r2 = await _applier(a).apply(remote: [renamed]);
    expect(r2.effects.rebuildTrees, isEmpty);
    expect((await a.repertoires.get(rep))!.name, 'Renamed');
  });

  test('a newer tombstone purges local data; runs of deleted repertoires '
      'are skipped; an older rename does not resurrect it', () async {
    final local = (await a.repertoires.records()).single;
    final tomb = local.copyWith(deleted: true, updatedAt: local.updatedAt + 5);
    final report = await _applier(a).apply(
      remote: [tomb],
      incoming: [
        fixtureRun(
          rep,
          id: 'late',
          key: 'k',
          ucis: 'e2e4',
          day: '2026-10-06',
          credits: [1],
        ),
      ],
    );
    expect(report.effects.deleteRepertoires, {rep});
    expect(report.insertedRuns, 0);
    expect(await a.runs.runsForRepertoire(rep), isEmpty);
    expect(await a.stats.lineStats(rep), isEmpty);
    expect((await a.repertoires.get(rep))!.deleted, isTrue);
    final stale = local.copyWith(
      name: 'Late rename',
      updatedAt: local.updatedAt + 1,
    );
    await _applier(a).apply(remote: [stale]);
    expect((await a.repertoires.get(rep))!.deleted, isTrue);
  });

  test('a new remote repertoire is created with its tree and stats; runs '
      'of unknown repertoires wait for their record', () async {
    const record = RepertoireRecord(
      id: 'new',
      name: 'New',
      color: 'b',
      pgn: _pgn2,
      pgnHash: 'h',
      createdAt: 1,
      updatedAt: 1,
      updatedBy: 'dev2',
    );
    final run = fixtureRun(
      'new',
      id: 'n1',
      key: 'k',
      ucis: 'e2e4 e7e5',
      day: '2026-10-06',
      credits: [1],
    );
    final orphan = fixtureRun(
      'unknown',
      id: 'o1',
      key: 'k',
      ucis: 'e2e4',
      day: '2026-10-06',
      credits: [1],
    );
    final report = await _applier(b)
        .apply(remote: [record], incoming: [run, orphan]);
    expect(report.insertedRuns, 2);
    expect((await b.repertoires.loadTree('new')).lines, isNotEmpty);
    expect(await b.stats.lineStats('new'), isNotEmpty);
    expect(await b.stats.lineStats('unknown'), isEmpty);
  });

  group('Replace all is atomic (audit R1)', () {
    late Object original;
    late RawBackup file;

    setUp(() async {
      final other = await b.repertoires.create(
        name: 'Other',
        color: Side.black,
        pgn: _pgn2,
        result: importPgn(_pgn2, Side.black),
      );
      final line = (await b.repertoires.lineRefs(other)).first;
      await b.service.recordRun(
        fixtureRun(
          other,
          id: 'b-run',
          key: line.key,
          ucis: line.ucis,
          day: '2026-10-05',
          credits: [1, 0],
        ),
      );
      original = await _snapshot(b);
      file = await _backup(b).read((await _backup(a).export()).bytes);
    });

    for (final stage in ['trees', 'snapshots', 'records', 'runs', 'derive']) {
      test('a failure at "$stage" leaves repertoires, runs and stats '
          'as they were', () async {
        final service = _backup(
          b,
          hook: (s) {
            if (s == stage) throw StateError('injected at $s');
          },
        );
        await expectLater(
          service.import(file, replace: true, restoreSettings: false),
          throwsA(isA<StateError>()),
        );
        expect(await _snapshot(b), original);
        expect(await SnapshotRepository(b.db).watchAll().first, isEmpty);
      });
    }

    test('a tree builder that throws, or an incoming PGN that does not '
        'import, stops the restore before anything changes', () async {
      await expectLater(
        _backup(
          b,
          buildTree: (_) => throw StateError('isolate died'),
        ).import(file, replace: true, restoreSettings: false),
        throwsA(isA<RestoreAborted>()),
      );
      await expectLater(
        _backup(
          b,
          buildTree: (_) async => null,
        ).import(file, replace: true, restoreSettings: false),
        throwsA(isA<RestoreAborted>().having((e) => e.names, 'names', ['R'])),
      );
      expect(await _snapshot(b), original);
    });

    test(
      'a successful replace saves the replaced repertoires as versions',
      () async {
        await _backup(b).import(file, replace: true, restoreSettings: false);
        expect(await _snapshot(b), await _snapshot(a));
        final saved = await SnapshotRepository(b.db).watchAll().first;
        expect(
          [for (final s in saved) (s.record.name, s.reason)],
          [('Other', SnapshotReason.restore)],
        );
      },
    );
  });

  group('an incoming PGN that does not import (audit R2)', () {
    test('keeps the local record, PGN and tree together and saves the '
        'rejected version', () async {
      final local = (await a.repertoires.records()).single;
      final treeBefore = await a.repertoires.lineRefs(rep);
      final bad = local.copyWith(
        name: 'Renamed remotely',
        pgn: '1. e4 e5 2. Ke3 *',
        pgnHash: 'bad',
        updatedAt: local.updatedAt + 10,
        updatedBy: 'zz',
      );
      final report = await _applier(a).apply(remote: [bad]);
      expect(report.failedTrees, {rep});
      expect(report.changedIds, isEmpty);
      expect(report.effects.rebuildTrees, isEmpty);
      expect([for (final r in report.rejected) r.pgnHash], ['bad']);
      // Export and training use the same, original version.
      expect((await a.repertoires.records()).single, local);
      expect(await a.repertoires.lineRefs(rep), treeBefore);
      final saved = await SnapshotRepository(a.db).watchAll().first;
      expect(
        [for (final s in saved) (s.reason, s.record.pgn, s.record.name)],
        [(SnapshotReason.rejected, bad.pgn, 'Renamed remotely')],
      );
      // The same rejected version again is not saved twice.
      await _applier(a).apply(remote: [bad]);
      expect(await SnapshotRepository(a.db).watchAll().first, hasLength(1));
    });

    test('a new repertoire that does not import is not added but its '
        'version is kept', () async {
      const record = RepertoireRecord(
        id: 'new',
        name: 'New',
        color: 'w',
        pgn: '1. e4 e5 2. Ke3 *',
        pgnHash: 'bad',
        createdAt: 1,
        updatedAt: 1,
        updatedBy: 'dev2',
      );
      final report = await _applier(b).apply(remote: [record]);
      expect(report.failedTrees, {'new'});
      expect(await b.repertoires.get('new'), isNull);
      final saved = await SnapshotRepository(b.db).watchAll().first;
      expect(saved.single.reason, SnapshotReason.rejected);
      // Rejected versions are not in the trash.
      expect(await SnapshotRepository(b.db).watchTrash().first, isEmpty);
    });
  });

  test('a merge saves the local version a newer PGN replaces and the one a '
      'tombstone deletes (audit R4)', () async {
    final local = (await a.repertoires.records()).single;
    final newer = local.copyWith(
      pgn: _pgn2,
      pgnHash: 'other',
      updatedAt: local.updatedAt + 1,
      updatedBy: 'zz',
    );
    await _applier(a).apply(remote: [newer]);
    final tomb = newer.copyWith(deleted: true, updatedAt: newer.updatedAt + 1);
    await _applier(a).apply(remote: [tomb]);
    final saved = await SnapshotRepository(a.db).watchAll().first;
    expect(
      [for (final s in saved) (s.reason, s.record.pgnHash)],
      [
        (SnapshotReason.deleted, 'other'),
        (SnapshotReason.replaced, local.pgnHash),
      ],
    );
    expect(await SnapshotRepository(a.db).watchTrash().first, [
      TrashEntry(
        repertoireId: rep,
        name: 'R',
        deletedAt: tomb.updatedAt,
        hasData: false,
      ),
    ]);
  });

  test('backup checks: typed errors like the codec', () async {
    final q = BackupQueries(b.db);
    String doc({Object? schema = 1, Object? runs = const <Object>[]}) =>
        jsonEncode({
          'format': backupFormat,
          'schema': schema,
          'exportedAt': 1,
          'appVersion': 'v',
          'deviceId': 'd',
          'repertoires': <Object>[],
          'runs': runs,
        });
    expect(() => q.inspect('{'), throwsA(isA<CorruptFile>()));
    expect(() => q.inspect('[1]'), throwsA(isA<WrongFormat>()));
    expect(
      () => q.inspect('{"format":"rt-sync-meta","schema":1}'),
      throwsA(isA<WrongFormat>().having((e) => e.found, 'found', metaFormat)),
    );
    expect(() => q.inspect(doc(schema: 2)), throwsA(isA<NewerSchema>()));
    expect(() => q.inspect(doc(schema: 'x')), throwsA(isA<CorruptFile>()));
    expect(() => q.inspect(doc(runs: 3)), throwsA(isA<CorruptFile>()));
    expect(
      () => q.inspect(
        doc(
          runs: [
            {'id': 'a', 'schema': 2},
          ],
        ),
      ),
      throwsA(isA<NewerSchema>()),
    );
    expect(
      () => q.inspect(
        doc(
          runs: [
            {'id': 1},
          ],
        ),
      ),
      throwsA(isA<CorruptFile>()),
    );
    final ok = await q.inspect(
      doc(
        runs: [
          {'id': 'a'},
        ],
      ),
    );
    expect((ok.runCount, ok.header.deviceId), (1, 'd'));
    expect(ok.header.settings, isEmpty);
    expect(
      () => _backup(b).read(Uint8List.fromList([1, 2, 3])),
      throwsA(isA<CorruptFile>()),
    );
  });
}
