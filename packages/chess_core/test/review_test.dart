import 'package:chess_core/chess_core.dart';
import 'package:dartchess/dartchess.dart';
import 'package:test/test.dart';

PositionAnalysis a(int cp, [List<String> pv = const [], EvalScore? second]) =>
    PositionAnalysis(
      score: EvalScore(cp: cp),
      pv: pv,
      second: second,
    );

PositionAnalysis m(int mate, [List<String> pv = const []]) => PositionAnalysis(
  score: EvalScore(mate: mate),
  pv: pv,
);

Position fen(String f) => Chess.fromSetup(Setup.parseFen(f));

void main() {
  group('win chance', () {
    test('curve, clamps and mates', () {
      expect(winChance(const EvalScore(cp: 0)), 0.5);
      expect(winChance(const EvalScore(cp: 100)), closeTo(0.591, 1e-3));
      expect(
        winChance(const EvalScore(cp: 5000)),
        winChance(const EvalScore(cp: 1000)),
      );
      expect(winChance(const EvalScore(mate: 3)), 1);
      expect(winChance(const EvalScore(mate: -1)), 0);
      expect(
        const EvalScore(cp: 100).forSide(forWhite: false),
        closeTo(0.409, 1e-3),
      );
    });

    test('EvalScore helpers', () {
      expect(const EvalScore(mate: 2).cappedCp, 1000);
      expect(const EvalScore(mate: -2).cappedCp, -1000);
      expect(const EvalScore(cp: -4000).cappedCp, -1000);
      expect(const EvalScore.mated(whiteMated: true).white, 0);
      expect(const EvalScore.mated(whiteMated: false).white, 1);
      expect(const EvalScore.drawn().white, 0.5);
      expect(const EvalScore(mate: -3).mateFor(white: false), isTrue);
      expect(const EvalScore(cp: 3).mateFor(white: true), isFalse);
      expect(const EvalScore(cp: 3), const EvalScore(cp: 3));
      expect(const EvalScore(cp: 3).hashCode, const EvalScore(cp: 3).hashCode);
      expect('${const EvalScore(mate: 2)} ${const EvalScore(cp: 5)}', 'M2 5cp');
    });
  });

  group('board facts', () {
    test('static exchange evaluation', () {
      // Black knight e5, attacked by the d4 pawn, defended by the d6 pawn.
      final p = fen('4k3/8/3p4/4n3/3P4/8/8/4K3 w - - 0 1');
      expect(see(p.board, Square.e5, Side.white), 2);
      // Undefended: the whole knight.
      final q = fen('4k3/8/8/4n3/3P4/8/8/4K3 w - - 0 1');
      expect(see(q.board, Square.e5, Side.white), 3);
      // A queen taking a defended pawn loses.
      final r = fen('4k3/8/3p4/4p3/8/8/8/4K2Q w - - 0 1');
      expect(see(r.board, Square.e5, Side.white), lessThanOrEqualTo(0));
      expect(see(r.board, Square.e4, Side.white), 0);
      expect(material(p.board, Side.black), 4);
      expect(material(p.board, Side.black, piecesOnly: true), 3);
    });

    test('forced, check, captures, recapture, flight, hanging piece', () {
      final g = ReviewedGame.of([
        'e2e4', 'f7f5', 'd1h5', 'g7g6', // g6 is the only move
        'h5g6', 'h7g6', // queen takes, pawn recaptures
      ]);
      expect(g.facts[3].forced, isTrue);
      expect(g.facts[3].inCheck, isTrue);
      expect(g.facts[4].capture, isTrue);
      expect(g.facts[4].easyCapture, isFalse);
      expect(g.facts[4].hangingValue, 9);
      expect(g.facts[5].recapture, isTrue);
      expect(g.facts[5].easyCapture, isTrue);
      final h = ReviewedGame.of(['e2e4', 'd7d5', 'e4d5', 'g8f6', 'f1b5']);
      expect(h.facts[2].capture, isTrue);
      expect(h.facts[2].recapture, isFalse);
      // Bb5+ is check and hangs nothing.
      expect(h.facts[4].hangingValue, 0);
      final flee = ReviewedGame.of(['e2e4', 'g8f6', 'e4e5', 'f6d5']);
      expect(flee.facts[3].fleesCheaperAttacker, isTrue);
      expect(() => ReviewedGame.of(['e2e5']), throwsArgumentError);
      expect(() => flee.review([a(0)]), throwsArgumentError);
      expect(() => flee.secondPassCandidates([a(0)]), throwsArgumentError);
    });

    test('en passant counts as a capture; castling is normalized', () {
      final g = ReviewedGame.of([
        'e2e4',
        'a7a6',
        'e4e5',
        'd7d5',
        'e5d6',
        'a6a5',
        'g1f3',
        'a5a4',
        'f1e2',
        'a4a3',
        'e1g1',
      ]);
      expect(g.facts[4].capture, isTrue);
      expect(g.facts[4].capturedValue, 1);
      expect(g.positions.last.board.kingOf(Side.white), Square.g1);
    });

    test('engine-line sacrifice needs two pawns and piece material', () {
      final g = ReviewedGame.of(['e2e4', 'e7e5', 'f1a6']);
      expect(g.facts[2].sacrificesPiece(), isTrue);
      expect(pvSacrifice(g.positions[2], g.positions[3], ['b7a6']), isTrue);
      expect(pvSacrifice(g.positions[2], g.positions[3], ['g8f6']), isFalse);
      expect(pvSacrifice(g.positions[2], g.positions[3], ['zz']), isFalse);
    });

    test('a piece that was already attacked is not newly given up', () {
      // 3.Nc3 attacks the queen on d5; 3...Nf6 defends it but ignores the
      // threat: the queen is not a sacrifice made by Nf6.
      final g = ReviewedGame.of([
        'e2e4', 'd7d5', 'e4d5', 'd8d5', 'b1c3', 'g8f6', //
      ]);
      expect(g.facts[5].hangingValue, 0);
      expect(g.facts[5].sacrificesPiece(), isFalse);
    });

    test('engine lines are settled by exchange at both ends', () {
      final g = ReviewedGame.of(['e2e4', 'e7e5', 'f1a6']);
      // The line stops right after Black took the bishop and a pawn is
      // not enough: bishop (3) for nothing is down 3 and counts...
      expect(pvSacrifice(g.positions[2], g.positions[3], ['b7a6']), isTrue);
      // ...but when White can win it straight back it does not.
      final h = ReviewedGame.of(['e2e4', 'd7d5', 'e4d5', 'g8f6', 'd5d6']);
      // 5.d6 hangs the pawn only; the exchange that follows keeps the
      // material even, and the pv ends mid-capture.
      expect(
        pvSacrifice(h.positions[4], h.positions[5], ['c7d6', 'd1d6']),
        isFalse,
      );
    });

    test('lines with castling are followed', () {
      final g = ReviewedGame.of([
        'e2e4', 'e7e5', 'g1f3', 'b8c6', 'f1c4', 'g8f6', 'e1g1', //
      ]);
      // Black takes e4; White castled earlier in the line shape: the pv
      // plays e1g1 as the engine prints it.
      expect(
        pvSacrifice(g.positions[6], g.positions[7], ['f6e4', 'f1e1']),
        isFalse,
      );
      expect(bestCapture(g.positions[7].board, Side.black), 1);
    });
  });

  group('classification', () {
    test('book, forced and the expected-points bands', () {
      final g = ReviewedGame.of([
        'e2e4',
        'e7e5',
        'g1f3',
        'b8c6',
        'f1c4',
        'f8c5',
        'b1c3',
        'g8f6',
      ]);
      final r = g.review(
        [
          a(30, ['e2e4']),
          a(30),
          a(30, ['g1f3']),
          a(30, ['g8f6']), // Nc6 is not the engine's move...
          a(40), // ...and loses ~0.01: Excellent
          a(40, ['g8f6']),
          a(110, ['b1c3']), // ...Bc5 loses ~0.07: Inaccuracy
          a(110, ['d7d6']),
          a(330), // ...Nf6 loses ~0.17: Mistake
        ],
        book: {1, 2},
      );
      expect(r.labels, [
        MoveLabel.book,
        MoveLabel.book,
        MoveLabel.best,
        MoveLabel.excellent,
        MoveLabel.best,
        MoveLabel.inaccuracy,
        MoveLabel.best,
        MoveLabel.mistake,
      ]);
      expect(r.losses.first, isNull);
      expect(r.losses[2], 0);
      expect(r.whiteAccuracy, greaterThan(99));
      expect(r.blackAccuracy, lessThan(r.whiteAccuracy!));
      expect(r.whitePerformance, greaterThan(2900));
      expect(r.blackPerformance, lessThan(r.whitePerformance!));
    });

    test('Good and Blunder bands; unanalysed plies stay null', () {
      final g = ReviewedGame.of(['e2e4', 'e7e5', 'g1f3', 'd7d6']);
      final r = g.review([a(0), a(-40), a(-40), a(-800), null]);
      expect(r.labels, [
        MoveLabel.good,
        MoveLabel.best, // equal or better than the line: loss 0
        MoveLabel.blunder,
        null,
      ]);
      expect(r.blackAccuracy, isNotNull);
    });

    test('forced move', () {
      final g = ReviewedGame.of(['e2e4', 'f7f5', 'd1h5', 'g7g6']);
      final r = g.review([a(30), a(40), a(150), m(5), a(400)]);
      expect(r.labels.last, MoveLabel.forced);
    });

    test('allowing a quick mate is a Blunder unless already lost', () {
      final g = ReviewedGame.of(['f2f3', 'e7e5', 'g2g4']);
      final r = g.review([a(0), a(-80), a(-100), m(-1)]);
      expect(r.labels.last, MoveLabel.blunder);
      final lost = g.review([a(0), a(-80), a(-700), m(-1)]);
      expect(lost.labels.last, isNot(MoveLabel.miss));
    });

    test('Brilliant: a near-best piece sacrifice, not already winning', () {
      final g = ReviewedGame.of(['e2e4', 'e7e5', 'f1a6']);
      final analyses = [
        a(30),
        a(30),
        a(30, ['f1a6'], const EvalScore(cp: 20)),
        a(30, ['b7a6']),
      ];
      final r = g.review(analyses);
      expect(r.labels.last, MoveLabel.brilliant);
      expect(
        g.secondPassCandidates([
          a(30),
          a(30),
          a(30, ['f1a6']),
          a(30, ['b7a6']),
        ]),
        [2],
      );
      // Without the second pass it is provisional, from the best line.
      expect(
        g
            .review([
              a(30),
              a(30),
              a(30, ['f1a6']),
              a(30, ['b7a6']),
            ], secondPass: false)
            .labels
            .last,
        MoveLabel.brilliant,
      );
      // Not when the alternative was already overwhelming.
      final winning = g.review([
        a(30),
        a(30),
        a(30, ['f1a6'], const EvalScore(cp: 1000)),
        a(30, ['b7a6']),
      ]);
      expect(winning.labels.last, MoveLabel.best);
      // Not when it leaves the mover worse.
      final bad = g.review([
        a(30),
        a(30),
        a(-200, ['f1a6']),
        a(-200),
      ]);
      expect(bad.labels.last, isNot(MoveLabel.brilliant));
    });

    test('Great: the only good move; needs the second pass', () {
      final g = ReviewedGame.of(['e2e4', 'e7e5', 'g1f3']);
      final second = a(40, ['g1f3'], const EvalScore(cp: -200));
      final r = g.review([a(30), a(30), second, a(40)]);
      expect(r.labels.last, MoveLabel.great);
      expect(
        g.review([a(30), a(30), second, a(40)], secondPass: false).labels.last,
        MoveLabel.best,
      );
      // A 300 cp gap counts even when both are winning in expected points.
      final cp = g.review([
        a(30),
        a(30),
        a(700, ['g1f3'], const EvalScore(cp: 350)),
        a(700),
      ]);
      expect(cp.labels.last, MoveLabel.great);
      // The only move that keeps a forced mate.
      final mate = g.review([
        a(30),
        a(30),
        const PositionAnalysis(
          score: EvalScore(mate: 4),
          pv: ['g1f3'],
          second: EvalScore(cp: 500),
        ),
        m(3),
      ]);
      expect(mate.labels.last, MoveLabel.great);
      // Experimental swing rule.
      final swing = g.review([
        a(30),
        a(30),
        a(30, ['g1f3'], const EvalScore(cp: -10)),
        a(100),
      ], config: const ReviewConfig(greatSwing: true, greatGap: 0.05));
      expect(swing.labels.last, MoveLabel.great);
      expect(
        g.secondPassCandidates(
          [
            a(30),
            a(30),
            a(30, ['g1f3']),
            a(40),
          ],
          book: {3},
        ),
        isEmpty,
      );
    });

    test('Miss: failing to punish the opponent', () {
      final g = ReviewedGame.of(['e2e4', 'e7e5', 'd1h5', 'g8f6']);
      // Qh5 drops 0.2; ...Nf6 throws it back to the earlier level.
      final r = g.review([
        a(30),
        a(30, ['g1f3']),
        a(30, ['b8c6']),
        a(-150, ['b8c6']),
        a(10),
      ]);
      expect(r.labels[2], MoveLabel.mistake);
      expect(r.labels[3], MoveLabel.miss);
      // Throwing away a forced mate.
      final mate = g.review([
        a(30),
        a(30),
        a(30),
        const PositionAnalysis(score: EvalScore(mate: -3), pv: ['b8c6']),
        a(-150),
      ]);
      expect(mate.labels[3], MoveLabel.miss);
    });

    test('terminal positions', () {
      final g = ReviewedGame.of(['f2f3', 'e7e5', 'g2g4', 'd8h4']);
      expect(g.isTerminal(4), isTrue);
      expect(g.isTerminal(3), isFalse);
      expect(g.terminalScore(4).white, 0);
      expect(g.length, 4);
      expect(g.fen(0), kInitialFEN);
      final r = g.review([
        a(0),
        a(-80),
        a(-100),
        m(-1, ['d8h4']),
        PositionAnalysis(score: g.terminalScore(4)),
      ]);
      expect(r.labels.last, MoveLabel.best);
    });
  });

  test('ratingFromAccuracy follows the anchors and rises with accuracy', () {
    expect(ratingFromAccuracy(63), 800);
    expect(ratingFromAccuracy(90), 2250);
    expect(ratingFromAccuracy(100), 3200);
    expect(ratingFromAccuracy(0), 100);
    expect(ratingFromAccuracy(72), inInclusiveRange(1000, 1300));
    var last = 0;
    for (var a = 0.0; a <= 100; a += 2.5) {
      final r = ratingFromAccuracy(a);
      expect(r, greaterThanOrEqualTo(last));
      last = r;
    }
  });
}
