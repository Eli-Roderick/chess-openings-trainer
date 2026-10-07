import 'package:chess_core/chess_core.dart';
import 'package:test/test.dart';

const _chessCom = '''
[Event "Live Chess"]
[Site "Chess.com"]
[White "a"]
[Black "b"]
[Result "1-0"]
[ECO "B12"]
[ECOUrl "https://www.chess.com/openings/Caro-Kann-Defense-Advance-Variation-3...c5"]

1. e4 {[%clk 0:02:59.9]} 1... c6 {[%clk 0:02:58]} 2. d4 {[%clk 0:02:57.1]}
2... d5 {[%clk 0:02:55.5]} 3. e5 {[%clk 1:00:00]} 3... c5 {[%clk 0:02:50]}
4. dxc5 {[%clk 0:02:40]} 1-0
''';

void main() {
  test('chess.com PGN: moves, clocks, ECO and opening from ECOUrl', () {
    final g = parsePlayedGame(_chessCom)!;
    expect(g.ucis, ['e2e4', 'c7c6', 'd2d4', 'd7d5', 'e4e5', 'c6c5', 'd4c5']);
    expect(g.sans.last, 'dxc5');
    expect(g.clocks, [1799, 1780, 1771, 1755, 36000, 1700, 1600]);
    expect(g.eco, 'B12');
    expect(g.opening, 'Caro-Kann Defense Advance Variation');
  });

  test('missing clocks give null; Opening tag wins over ECOUrl', () {
    final g = parsePlayedGame(
      '[Opening "Vienna Game"]\n[ECO "?"]\n\n'
      '1. e4 {[%clk 0:01:00]} e5 2. Nc3 *',
    )!;
    expect(g.clocks, isNull);
    expect(g.eco, isNull);
    expect(g.opening, 'Vienna Game');
  });

  test('castling and promotion are written in UCI', () {
    final g = parsePlayedGame('1. e4 e5 2. Nf3 Nc6 3. Bc4 Bc5 4. O-O *')!;
    expect(g.ucis.last, 'e1g1');
    expect(g.sans.last, 'O-O');
  });

  test('rejects illegal moves, variants, set-up positions, empty input', () {
    expect(parsePlayedGame('1. e4 e5 2. Ke3 *'), isNull);
    expect(parsePlayedGame('[Variant "Chess960"]\n\n1. e4 *'), isNull);
    expect(
      parsePlayedGame('[FEN "8/8/8/8/8/8/8/K6k w - - 0 1"]\n\n1. Kb1 *'),
      isNull,
    );
    expect(parsePlayedGame(''), isNull);
    expect(parsePlayedGame('[Variant "Standard"]\n\n*')!.ucis, isEmpty);
  });

  test('openingFromEcoUrl', () {
    expect(openingFromEcoUrl(null), isNull);
    expect(openingFromEcoUrl('https://www.chess.com/openings/'), isNull);
    expect(openingFromEcoUrl('https://www.chess.com/openings/1.e4'), isNull);
    expect(
      openingFromEcoUrl(
        'https://www.chess.com/openings/Nimzo-Indian-Defense-Classical',
      ),
      'Nimzo-Indian Defense Classical',
    );
  });
}
