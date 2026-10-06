import 'package:test/test.dart';
import 'package:uci_engine/uci_engine.dart';

void main() {
  test('info with cp, multipv and pv', () {
    final i = parseInfo(
      'info depth 14 seldepth 20 multipv 2 score cp -35 nodes 123456 '
      'nps 987654 hashfull 10 tbhits 0 time 125 pv e7e5 g1f3 b8c6',
    )!;
    expect(i.depth, 14);
    expect(i.selDepth, 20);
    expect(i.multiPv, 2);
    expect(i.score, const EngineScore.cp(-35));
    expect(i.bound, isFalse);
    expect(i.nodes, 123456);
    expect(i.nps, 987654);
    expect(i.timeMs, 125);
    expect(i.pv, ['e7e5', 'g1f3', 'b8c6']);
  });

  test('mate and bounds', () {
    expect(
      parseInfo('info depth 30 score mate -3 pv h7h8')!.score,
      const EngineScore.mate(-3),
    );
    expect(
      parseInfo('info depth 9 score cp 12 lowerbound pv e2e4')!.bound,
      isTrue,
    );
    expect(
      parseInfo('info depth 9 score cp 12 upperbound pv e2e4')!.bound,
      isTrue,
    );
    expect(const EngineScore.mate(2).negated, const EngineScore.mate(-2));
    expect(const EngineScore.cp(5).negated, const EngineScore.cp(-5));
  });

  test('lines without a score or pv are ignored', () {
    expect(parseInfo('info depth 5 currmove e2e4 currmovenumber 1'), isNull);
    expect(parseInfo('info string NNUE evaluation using nn.nnue'), isNull);
    expect(parseInfo('info depth 1 score cp 10'), isNull);
    expect(parseInfo('bestmove e2e4'), isNull);
    expect(parseInfo('info depth 1 score wdl 1 2 pv e2e4'), isNull);
  });

  test('bestmove', () {
    expect(parseBestMove('bestmove e2e4 ponder e7e5')!.move, 'e2e4');
    expect(parseBestMove('bestmove e2e4 ponder e7e5')!.ponder, 'e7e5');
    expect(parseBestMove('bestmove (none)')!.move, isNull);
    expect(parseBestMove('info depth 1'), isNull);
  });

  test('go commands', () {
    expect(
      const SearchRequest(
        fen: 'x',
        limit: Infinite(),
        searchMoves: ['b8c6', 'g8f6'],
      ).goCommand,
      'go infinite searchmoves b8c6 g8f6',
    );
    expect(
      const SearchRequest(
        fen: 'x',
        limit: MoveTime(Duration(milliseconds: 800)),
      ).goCommand,
      'go movetime 800',
    );
  });

  test('side to move from FEN', () {
    expect(whiteToMove('8/8/8/8/8/8/8/K6k w - - 0 1'), isTrue);
    expect(whiteToMove('8/8/8/8/8/8/8/K6k b - - 0 1'), isFalse);
  });

  test('calibration result median', () {
    const r = CalibrationResult(
      nps: 1,
      depthAt2s: 20,
      depthsAt1s: [14, 11, 18, 12, 16],
    );
    expect(r.medianDepthAt1s, 14);
  });
}
