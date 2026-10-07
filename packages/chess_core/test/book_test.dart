import 'package:chess_core/chess_core.dart';
import 'package:dartchess/dartchess.dart' show Side;
import 'package:test/test.dart';

const _tsv =
    "C20\tKing's Pawn Game\te2e4 e7e5\n"
    'C25\tVienna Game\te2e4 e7e5 b1c3\n'
    'C26\tVienna Game: Falkbeer Variation\te2e4 e7e5 b1c3 g8f6\n'
    'bad line\n'
    'X00\tBroken\te2e5\n';

void main() {
  test('OpeningBook: exact names win, passing positions get a name', () {
    final book = OpeningBook.parse(_tsv);
    expect(book.size, 4);
    final fens = fensOf(['e2e4', 'e7e5', 'b1c3', 'g8f6', 'f1c4']);
    expect(book.at(fens[0])!.name, "King's Pawn Game");
    expect(book.at(fens[1])!.eco, 'C20');
    expect(book.at(fens[2])!.name, 'Vienna Game');
    expect(book.at(fens[3])!.name, 'Vienna Game: Falkbeer Variation');
    expect(book.at(fens[4]), isNull);
    expect(openingOf(fens, book)!.eco, 'C26');
    expect(openingOf(fens.take(0).toList(), book), isNull);
    expect(positionKey(fens[0]).split(' '), hasLength(4));
  });

  test('bookPlies: table or repertoire, contiguous from the start', () {
    final book = OpeningBook.parse(_tsv);
    final ucis = ['e2e4', 'e7e5', 'b1c3', 'b8c6', 'f1c4', 'g8f6'];
    final fens = fensOf(ucis);
    expect(bookPlies(ucis, fens, table: book), {1, 2, 3});
    final tree = importPgn('1. e4 e5 2. Nc3 Nc6 3. Bc4 *', Side.white).tree!;
    expect(bookPlies(ucis, fens, table: book, roots: [tree.root]), {
      1,
      2,
      3,
      4,
      5,
    });
    expect(bookPlies(['d2d4'], fensOf(['d2d4']), table: book), isEmpty);
    expect(bookPlies(ucis, fens), isEmpty);
  });
}
