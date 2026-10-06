import 'package:chess_core/chess_core.dart';
import 'package:test/test.dart';

PgnSyntaxError onlyError(String pgn) {
  final r = readPgn(pgn);
  expect(r.errors, hasLength(1), reason: '$pgn -> ${r.errors}');
  return r.errors.single;
}

void main() {
  group('reads', () {
    test('headers with escapes, comments, NAGs and glyphs', () {
      final r = readPgn(
        '[Event "A \\"quoted\\" \\\\ event"]\n'
        '[Site "x"]\n\n'
        '{pre} 1. e4! {c1} {c2} \$14 e5?! 2. Nf3 *\n',
      );
      expect(r.errors, isEmpty);
      final g = r.games.single;
      expect(g.headers['Event'], r'A "quoted" \ event');
      expect(g.preComments, ['pre']);
      final e4 = g.root.children.single;
      expect(e4.san, 'e4');
      expect(e4.comments, ['c1', 'c2']);
      expect(e4.nags, [1, 14]);
      expect(e4.children.single.nags, [6]);
      expect(e4.children.single.children.single.sanPath, ['e4', 'e5', 'Nf3']);
      expect(e4.children.single.children.single.ply, 3);
    });

    test('variations, start comments and move numbers in all forms', () {
      final r = readPgn('1.e4 e5 (1...c5 2.Nf3) ({x} 1… e6) 2. Nf3 2... Nc6 *');
      expect(r.errors, isEmpty);
      final e4 = r.games.single.root.children.single;
      expect([for (final c in e4.children) c.san], ['e5', 'c5', 'e6']);
      expect(e4.children[2].beforeComments, ['x']);
      expect(e4.children[0].children.single.children.single.san, 'Nc6');
    });

    test('zero castling, null move tokens, ; comments and % lines', () {
      final r = readPgn(
        '% escape line\n1. 0-0 ; rest of line\n1... -- 2. Z0 0-0-0 *',
      );
      expect(r.errors, isEmpty);
      final first = r.games.single.root.children.single;
      expect(first.san, 'O-O');
      expect(first.comments, [' rest of line']);
      final second = first.children.single;
      expect(second.san, '--');
      expect(second.children.single.san, '--');
      expect(second.children.single.children.single.san, 'O-O-O');
    });

    test('several games, with and without result tokens', () {
      final r = readPgn(
        '[Event "1"]\n1. e4 *\n[Event "2"]\n1. d4\n[Event "3"]\n1. c4 1-0\n'
        '1. Nf3 0-1 1. g3 1/2-1/2',
      );
      expect(r.errors, isEmpty);
      expect(
        [for (final g in r.games) g.root.children.single.san],
        ['e4', 'd4', 'c4', 'Nf3', 'g3'],
      );
      expect([for (final g in r.games) g.index], [0, 1, 2, 3, 4]);
      expect(r.gameCount, 5);
    });

    test('a comment line starting with "[%" does not split a game', () {
      final r = readPgn('1. e4 {[%why a]\n [%plan b]} e5 *');
      expect(r.errors, isEmpty);
      expect(r.games, hasLength(1));
    });

    test('promotion forms', () {
      final r = readPgn('1. e8=Q e8Q exd8=n+ *');
      expect(r.errors, isEmpty);
      final a = r.games.single.root.children.single;
      expect(a.san, 'e8=Q');
      expect(a.children.single.san, 'e8Q');
      expect(a.children.single.children.single.san, 'exd8=n+');
    });

    test('empty input has no games', () {
      expect(readPgn('').gameCount, 0);
      expect(readPgn('  \n\n').gameCount, 0);
    });
  });

  group('syntax errors (E-PARSE)', () {
    test('unexpected token, with the path of the last move', () {
      final e = onlyError('1. e4 e5 2. Nf3 & Nc6 *');
      expect(e.detail, "unexpected '&'");
      expect(e.sanPath, ['e4', 'e5', 'Nf3']);
      expect(e.gameIndex, 0);
    });

    test('unterminated comment', () {
      expect(onlyError('1. e4 {never closed').detail, 'unterminated comment');
    });

    test("unmatched ')'", () {
      expect(onlyError('1. e4 ) e5 *').detail, "unmatched ')'");
    });

    test('unclosed variation at end of input and before a header', () {
      expect(onlyError('1. e4 (1. d4').detail, 'unclosed variation');
      expect(
        onlyError('1. e4 (1. d4\n[Event "x"]\n').detail,
        'unclosed variation',
      );
    });

    test('variation before any move', () {
      expect(onlyError('(1. d4) 1. e4 *').detail, 'variation before any move');
    });

    test('result inside a variation', () {
      expect(onlyError('1. e4 (1. d4 *) *').detail, 'result inside variation');
    });

    test('malformed NAG, glyph and tag pair', () {
      expect(onlyError(r'1. e4 $x *').detail, r'malformed NAG after $');
      expect(onlyError('1. e4 !!! *').detail, "unknown annotation '!!!'");
      expect(
        onlyError('[Event unquoted]\n1. e4 *').detail,
        'malformed tag pair',
      );
    });

    test("'[' in the middle of a line", () {
      expect(onlyError('1. e4 [Event "x"]').detail, "unexpected '['");
    });

    test('lone dash', () {
      expect(onlyError('1. e4 - *').detail, "unexpected '-'");
    });

    test('reading resumes at the next game', () {
      final r = readPgn(
        '[Event "a"]\n1. e4 *\n\n[Event "b"]\n1. e4 & *\n\n'
        '[Event "c"]\n1. d4 *',
      );
      expect(r.errors.single.gameIndex, 1);
      expect([for (final g in r.games) g.index], [0, 2]);
      expect(r.errors.single.toString(), contains('game 1'));
    });

    test('an error with no move yet reports the start', () {
      expect(onlyError('& 1. e4').sanPath, isEmpty);
    });
  });
}
