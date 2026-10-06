import 'dart:convert';
import 'dart:io' as io;
import 'dart:math';

import 'package:chess_core/chess_core.dart';
import 'package:test/test.dart';

final class _Gzip implements GzipCodec {
  const new();

  @override
  List<int> encode(List<int> bytes) => io.gzip.encode(bytes);

  @override
  List<int> decode(List<int> bytes) => io.gzip.decode(bytes);
}

const _codec = SyncCodec(_Gzip());

RepertoireRecord _rep(
  String id, {
  int at = 1,
  String by = 'a',
  String name = 'R',
  String hash = 'h1',
  bool deleted = false,
}) => RepertoireRecord(
  id: id,
  name: name,
  color: 'w',
  pgn: '1. e4 *',
  pgnHash: hash,
  createdAt: 0,
  updatedAt: at,
  updatedBy: by,
  deleted: deleted,
);

RunRecord _run(String id, String rep) => RunRecord(
  id: id,
  repertoireId: rep,
  lineKey: 'k',
  ucis: 'e2e4',
  mode: RunMode.srs,
  startPly: 0,
  wrongMoveMode: WrongMoveMode.retry,
  startedAt: 1,
  finishedAt: 2,
  localDay: '2026-10-06',
  completed: true,
  deviated: false,
  gradedCount: 1,
  creditSum: 0.5,
  hintCount: 0,
  deviceId: 'dev',
  grades: const [
    MoveGrade(
      ply: 1,
      expected: 'e2e4',
      accepted: 'e2e4',
      firstAttempt: 'd2d4',
      result: GradeResult.comparable,
      credit: 0.5,
      attempts: 1,
      hintLevel: 0,
      checkCp: 12,
      checkStatus: CheckStatus.ok,
    ),
  ],
  deviation: const DeviationEvent(
    ply: 2,
    bestUci: 'e7e5',
    passed: true,
    deviationUci: 'c7c5',
    replyUci: 'g1f3',
    lossCp: 0,
  ),
);

List<int> _gz(String text) => io.gzip.encode(utf8.encode(text));

void main() {
  group('codec', () {
    test('meta round trip', () {
      final meta = MetaFile(
        deviceId: 'dev',
        deviceName: 'Phone',
        appVersion: '0.1.0',
        writtenAt: 5,
        repertoires: [_rep('a'), _rep('b', deleted: true)],
      );
      final back = _codec.decodeMeta(_codec.encodeMeta(meta));
      expect(back.repertoires, meta.repertoires);
      expect(
        (back.deviceId, back.deviceName, back.appVersion, back.writtenAt),
        ('dev', 'Phone', '0.1.0', 5),
      );
    });

    test('run log round trip (JSONL)', () {
      final runs = [_run('1', 'a'), _run('2', 'b')];
      final bytes = _codec.encodeRunLog(runs);
      expect(
        utf8
            .decode(io.gzip.decode(bytes))
            .split('\n')
            .where((l) => l.isNotEmpty),
        hasLength(2),
      );
      expect(_codec.decodeRunLog(bytes), runs);
      expect(_codec.decodeRunLog(_codec.encodeRunLog(const [])), isEmpty);
    });

    test('backup round trip with settings', () {
      final backup = BackupFile(
        exportedAt: 9,
        appVersion: '0.1.0',
        deviceId: 'dev',
        repertoires: [_rep('a')],
        runs: [_run('1', 'a')],
        settings: const {'themeMode': 'dark'},
      );
      final back = _codec.decodeBackup(_codec.encodeBackup(backup));
      expect(back.repertoires, backup.repertoires);
      expect(back.runs, backup.runs);
      expect(back.settings, backup.settings);
      expect((back.exportedAt, back.deviceId), (9, 'dev'));
    });

    test('backup with the runs given as JSON text', () {
      final runs = [_run('1', 'a'), _run('2', 'a')];
      final header = BackupFile(
        exportedAt: 9,
        appVersion: '0.1.0',
        deviceId: 'dev',
        repertoires: [_rep('a')],
        runs: const [],
        settings: const {'x': 1},
      );
      final bytes = _codec.encodeBackupWithRuns(
        header,
        jsonEncode([for (final r in runs) r.toJson()]),
      );
      final full = _codec.decodeBackup(bytes);
      expect(full.runs, runs);
      expect(full.repertoires, header.repertoires);
    });

    test(
      'typed errors: corrupt gzip, not JSON, wrong format, newer schema',
      () {
        expect(
          () => _codec.decodeBackup([1, 2, 3]),
          throwsA(isA<CorruptFile>()),
        );
        expect(
          () => _codec.decodeBackup(_gz('{not json')),
          throwsA(isA<CorruptFile>()),
        );
        expect(
          () => _codec.decodeBackup(_gz('[1]')),
          throwsA(isA<WrongFormat>()),
        );
        final meta = _codec.encodeMeta(
          const MetaFile(
            deviceId: 'd',
            deviceName: 'n',
            appVersion: 'v',
            writtenAt: 0,
            repertoires: [],
          ),
        );
        expect(
          () => _codec.decodeBackup(meta),
          throwsA(
            isA<WrongFormat>().having((e) => e.found, 'found', metaFormat),
          ),
        );
        expect(
          () => _codec.decodeMeta(
            _gz('{"format":"rt-sync-meta","schema":2,"repertoires":[]}'),
          ),
          throwsA(isA<NewerSchema>().having((e) => e.schema, 'schema', 2)),
        );
        expect(
          () => _codec.decodeMeta(_gz('{"format":"rt-sync-meta","schema":1}')),
          throwsA(isA<CorruptFile>()),
        );
        expect(
          () => _codec.decodeMeta(
            _gz(
              '{"format":"rt-sync-meta","schema":1,"deviceId":"d",'
              '"deviceName":"n","appVersion":"v","writtenAt":0,'
              '"repertoires":[{"id":1}]}',
            ),
          ),
          throwsA(isA<CorruptFile>()),
        );
        final newer = jsonEncode({..._run('1', 'a').toJson(), 'schema': 3});
        expect(
          () => _codec.decodeRunLog(_gz('$newer\n')),
          throwsA(isA<NewerSchema>()),
        );
        expect(
          () => _codec.decodeRunLog(_gz('{"id":\n')),
          throwsA(isA<CorruptFile>()),
        );
      },
    );
  });

  group('merge', () {
    test('newest updatedAt wins, then larger updatedBy', () {
      expect(newerRecord(_rep('a', at: 2), _rep('a', at: 3)).updatedAt, 3);
      expect(
        newerRecord(_rep('a', by: 'x'), _rep('a', by: 'y')).updatedBy,
        'y',
      );
      final m = mergeRepertoires(
        [_rep('a'), _rep('b')],
        [_rep('a', at: 5, name: 'New'), _rep('c')],
      );
      expect(m.winners['a']!.name, 'New');
      expect(m.changedIds, {'a', 'c'});
    });

    test('tombstones: a newer delete wins; an older rename loses to it', () {
      final local = [_rep('a', at: 10, deleted: true)];
      final staleRename = _rep('a', at: 5, name: 'Renamed', by: 'z');
      final m = mergeRepertoires(local, [staleRename]);
      expect(m.winners['a']!.deleted, isTrue);
      expect(m.changedIds, isEmpty);
      final before = {'a': _rep('a')};
      final del = mergeRepertoires(before.values, [
        _rep('a', at: 7, deleted: true),
      ]);
      final effects = mergeEffects(before, del, newRuns: {'a'});
      expect(effects.deleteRepertoires, {'a'});
      expect(effects.rederive, isEmpty);
    });

    test('effects: new and changed PGN rebuild; undelete rebuilds', () {
      final before = {
        'a': _rep('a'),
        'b': _rep('b'),
        'c': _rep('c', deleted: true),
      };
      final m = mergeRepertoires(before.values, [
        _rep('a', at: 2, hash: 'h2'),
        _rep('b', at: 2, name: 'Only renamed'),
        _rep('c', at: 2),
        _rep('d'),
      ]);
      final e = mergeEffects(before, m, newRuns: {'b'});
      expect(e.rebuildTrees, {'a', 'c', 'd'});
      expect(e.deleteRepertoires, isEmpty);
      expect(e.rederive, {'a', 'b', 'c', 'd'});
    });

    test('runs: union by id, runs of deleted repertoires skipped, unknown '
        'repertoires kept', () {
      final runs = [
        _run('1', 'a'),
        _run('2', 'gone'),
        _run('3', 'new'),
        _run('1', 'a'),
      ];
      final keep = runsToInsert(
        runs,
        knownIds: {'0'},
        deletedRepertoires: {'gone'},
      );
      expect([for (final r in keep) r.id], ['1', '3']);
      expect(runsToInsert(runs, knownIds: {'1', '3'}, deletedRepertoires: {}), [
        runs[1],
      ]);
    });

    test('properties over random record sets (500 seeded iterations): '
        'commutative, associative, idempotent, order-independent', () {
      final rng = Random(42);
      List<RepertoireRecord> randomSet() => [
        for (var i = 0; i < rng.nextInt(6); i++)
          _rep(
            'r${rng.nextInt(4)}',
            at: rng.nextInt(4),
            by: ['a', 'b', 'c'][rng.nextInt(3)],
            name: 'n${rng.nextInt(3)}',
            hash: 'h${rng.nextInt(2)}',
            deleted: rng.nextInt(4) == 0,
          ),
      ];
      Map<String, RepertoireRecord> merge(
        Iterable<RepertoireRecord> a,
        Iterable<RepertoireRecord> b,
      ) => mergeRepertoires(a, b).winners;
      for (var i = 0; i < 500; i++) {
        final a = randomSet();
        final b = randomSet();
        final c = randomSet();
        final ab = merge(merge(const [], a).values, b);
        final ba = merge(merge(const [], b).values, a);
        expect(ab, ba, reason: 'commutative #$i');
        expect(
          merge(ab.values, c),
          merge(
            merge(const [], a).values,
            merge(merge(const [], b).values, c).values,
          ),
          reason: 'associative #$i',
        );
        expect(merge(ab.values, ab.values), ab, reason: 'idempotent #$i');
        expect(merge(ab.values, a), ab, reason: 'idempotent re-apply #$i');
        final shuffled = [...a, ...b, ...c]..shuffle(rng);
        expect(
          merge(const [], shuffled),
          merge(ab.values, c),
          reason: 'order #$i',
        );
      }
    });
  });
}
