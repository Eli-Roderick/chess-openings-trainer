import 'package:chess_core/chess_core.dart';
import 'package:dartchess/dartchess.dart';
import 'package:test/test.dart';

void main() {
  final white = importPgn(
    '1. e4 e5 (1... c6 2. d4) 2. Nc3 Nf6 3. f4 *',
    Side.white,
  ).tree!;
  final short = importPgn('1. e4 e5 *', Side.white).tree!;

  test('the user leaves', () {
    final l = linkGame(white, ['e2e4', 'e7e5', 'g1f3']);
    expect(l.leftBy, LeftBy.user);
    expect(l.ply, 2);
    expect(l.played, 'g1f3');
    expect(l.expected.map((n) => n.san), ['Nc3']);
  });

  test('the opponent leaves, including at move 1 for Black', () {
    final l = linkGame(white, ['e2e4', 'c7c5']);
    expect(l.leftBy, LeftBy.opponent);
    expect(l.expected.map((n) => n.san), ['e5', 'c6']);
    final black = importPgn('1. e4 c5 *', Side.black).tree!;
    expect(linkGame(black, ['d2d4']).leftBy, LeftBy.opponent);
    expect(linkGame(black, ['d2d4']).ply, 0);
  });

  test('repertoire end and game end', () {
    expect(
      linkGame(white, ['e2e4', 'e7e5', 'b1c3', 'g8f6', 'f2f4', 'e5f4']).leftBy,
      LeftBy.repertoireEnd,
    );
    final end = linkGame(white, ['e2e4', 'c7c6']);
    expect(end.leftBy, LeftBy.gameEnd);
    expect(end.played, isNull);
  });

  test('bestLink picks the longest match', () {
    final ucis = ['e2e4', 'e7e5', 'b1c3'];
    expect(bestLink([short, white], ucis)!.$1, same(white));
    expect(bestLink([], ucis), isNull);
  });
}
