import 'package:chess_core/chess_core.dart';
import 'package:dartchess/dartchess.dart' show Side;
import 'package:test/test.dart';

import 'helpers.dart';

List<LineRef> refs(RepertoireTree t) => [
  for (final l in t.lines)
    LineRef(
      key: l.key,
      ucis: l.ucis,
      ordinal: l.ordinal,
      userMoveCount: l.userMoveCount,
    ),
];

void main() {
  group('re-import diff (03 §5, 01 §13)', () {
    final v1 = importFixture('reimport_v1.pgn').tree!;
    final v2 = importFixture('reimport_v2.pgn').tree!;

    test('unchanged, extended, removed and new lines', () {
      final diff = diffReimport(oldLines: refs(v1), newLines: refs(v2));
      final key = {
        for (final l in [...v1.lines, ...v2.lines]) l.label: l.key,
      };
      expect(diff.unchanged, [key['Re-import v1: …1...e5 2.Nf3 Nc6 3.Bb5']]);
      expect(diff.extended, {
        key['Re-import v1: …1...e5 2.Nf3 Nc6 3.Bc4']: [
          key['Re-import v2: …2...Nc6 3.Bc4 Bc5 4.c3'],
        ],
      });
      expect(diff.removed, [key['Re-import v1: 1.e4 c5 2.Nf3']]);
      expect(diff.added, [key['Re-import v2: 1.e4 e6 2.d4']]);
      expect(diff.commentChanges, 0);
    });

    test('an old line extended into several new lines', () {
      final diff = diffReimport(
        oldLines: const [LineRef(key: 'old', ucis: 'e2e4 e7e5')],
        newLines: const [
          LineRef(key: 'x', ucis: 'e2e4 e7e5 g1f3'),
          LineRef(key: 'y', ucis: 'e2e4 e7e5 f1c4', ordinal: 1),
        ],
      );
      expect(diff.extended, {
        'old': ['x', 'y'],
      });
      expect(diff.added, isEmpty);
    });

    test('comment changes count user moves in both versions only', () {
      final edited = importPgn(
        '1. e4 {[%why Centre, rewritten.]} e5 '
        '(1... c5 2. Nf3 {[%why Develops against the Sicilian.]}) '
        '2. Nf3 {[%why Attacks e5.]} Nc6 3. Bb5 {[%why Spanish.]} '
        '(3. Bc4 {[%why Italian, new words.]}) '
        '3... a6 4. Ba4 {[%why New move.]} *',
        Side.white,
      ).tree!;
      expect(countCommentChanges(v1, edited), 2);
      expect(countCommentChanges(v1, v1), 0);
      final diff = diffReimport(
        oldLines: refs(v1),
        newLines: refs(edited),
        commentChanges: countCommentChanges(v1, edited),
      );
      expect(diff.commentChanges, 2);
      expect(diff.extended.keys, hasLength(1));
    });
  });

  group('engine judgements (§7)', () {
    test('mate conversions', () {
      expect(scoreToCp(cp: -35), -35);
      expect(scoreToCp(mate: 3), 99997);
      expect(scoreToCp(mate: -2), -99998);
      expect(scoreToCp(mate: 1) > scoreToCp(mate: 2), isTrue);
      expect(scoreToCp(mate: -1) < scoreToCp(mate: -2), isTrue);
      expect(scoreToCp, throwsArgumentError);
      expect(() => scoreToCp(cp: 1, mate: 1), throwsArgumentError);
    });

    test('comparable: tie at the threshold, one over, better than book', () {
      ComparableJudgement j(int user) => judgeComparable(
        scores: {'a': 50, 'b': 20, 'u': user},
        accepted: ['a', 'b'],
        userMove: 'u',
      );
      expect(j(20).comparable, isTrue);
      expect(j(20).lossCp, 30);
      expect(j(19).comparable, isFalse);
      expect(j(80).comparable, isTrue);
      expect(j(80).lossCp, -30);
      expect(
        judgeComparable(
          scores: {'a': 50, 'u': 0},
          accepted: ['a'],
          userMove: 'u',
          thresholdCp: 50,
        ).comparable,
        isTrue,
      );
    });

    test('deviation candidates: window, repertoire moves excluded, empty', () {
      final pvs = [
        (uci: 'a', scoreCp: 40),
        (uci: 'b', scoreCp: -60),
        (uci: 'c', scoreCp: -61),
        (uci: 'd', scoreCp: 10),
      ];
      expect(
        [for (final p in deviationCandidates(pvs)) p.uci],
        ['a', 'b', 'd'],
      );
      expect(
        [
          for (final p in deviationCandidates(pvs, repertoireMoves: {'a'}))
            p.uci,
        ],
        ['b', 'd'],
      );
      expect(deviationCandidates(const []), isEmpty);
      expect(pickDeviation(const [], SeededRng(1)), isNull);
    });

    test('deviation pick is weighted towards the best move', () {
      final candidates = [
        (uci: 'best', scoreCp: 0),
        (uci: 'worse', scoreCp: -90),
      ];
      final rng = SeededRng(3);
      var best = 0;
      for (var i = 0; i < 10000; i++) {
        if (pickDeviation(candidates, rng) == 'best') best++;
      }
      // Weights 101 and 11.
      expect(best / 10000, closeTo(101 / 112, 0.02));
    });

    test('reply judgement', () {
      final best = judgeReply(bestUci: 'e2e4', bestCp: 30, replyUci: 'e2e4');
      expect((best.passed, best.lossCp), (true, 0));
      final ok = judgeReply(
        bestUci: 'e2e4',
        bestCp: 30,
        replyUci: 'd2d4',
        replyCp: -20,
      );
      expect((ok.passed, ok.lossCp), (true, 50));
      final bad = judgeReply(
        bestUci: 'e2e4',
        bestCp: 30,
        replyUci: 'd2d4',
        replyCp: -21,
      );
      expect((bad.passed, bad.lossCp), (false, 51));
      expect(
        () => judgeReply(bestUci: 'e2e4', bestCp: 0, replyUci: 'd2d4'),
        throwsArgumentError,
      );
    });
  });
}
