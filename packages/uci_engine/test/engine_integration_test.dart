@Tags(['engine'])
library;

import 'dart:async';
import 'dart:io';

import 'package:test/test.dart';
import 'package:uci_engine/uci_engine.dart';

/// `engine/linux/stockfish`, relative to the repository root.
String _binary() {
  var dir = Directory.current;
  while (true) {
    final f = File('${dir.path}/engine/linux/stockfish');
    if (f.existsSync()) return f.path;
    if (dir.parent.path == dir.path) {
      throw StateError(
        'run `dart run tool/fetch_engines.dart --platform linux`',
      );
    }
    dir = dir.parent;
  }
}

/// After 1.e4 e5 2.Nf3, Black to move.
const _italianFen =
    'rnbqkbnr/pppp1ppp/8/4p3/4P3/5N2/PPPP1PPP/RNBQKB1R b KQkq - 1 2';

int _cp(EngineScore s) =>
    s.cp ?? (s.mate! > 0 ? 100000 - s.mate! : -100000 - s.mate!);

void main() {
  late EngineService service;
  final launched = <ProcessTransport>[];

  setUp(() {
    launched.clear();
    service = EngineService(
      launch: () async {
        final t = await ProcessTransport.start(_binary());
        launched.add(t);
        return t;
      },
      options: () => const {'Threads': 2, 'Hash': 64},
    );
  });

  tearDown(() => service.dispose());

  test('start and quit', () async {
    await service.warmUp();
    expect(service.status.state, EngineState.ready);
    expect(service.status.name, startsWith('Stockfish 18'));
    await service.dispose();
    expect(await launched.single.exitCode, 0);
  });

  test('comparable check returns within 2.5 s with depth 12 (warm engine); '
      'realistic scores are logged', () async {
    await service.warmUp();
    final watch = Stopwatch()..start();
    final r = await service.scoreMoves(_italianFen, ['b8c6', 'g8f6', 'f7f6']);
    watch.stop();
    final book = _cp(r.scores['b8c6']!);
    // Logged, not asserted: 2...Nf6 is 1-17 cp worse than 2...Nc6 at
    // depth 12-16 on sf_18, too close to the 30 cp threshold to assert.
    // ignore: avoid_print
    print(
      'Nc6 $book, Nf6 ${_cp(r.scores['g8f6']!)}, '
      'f6 ${_cp(r.scores['f7f6']!)} at depth ${r.depth} in '
      '${watch.elapsedMilliseconds} ms',
    );
    expect(watch.elapsed, lessThan(const Duration(milliseconds: 2500)));
    expect(r.depth, greaterThanOrEqualTo(12));
    // 2...f6 loses 93-166 cp in measured runs (also under CPU load): far
    // from comparable at 30 cp. Asserted at twice the threshold.
    expect(book - _cp(r.scores['f7f6']!), greaterThan(60));
  });

  test('comparable: equal moves in a dead draw score the same', () async {
    // K+N vs K: every move draws, so both knight moves score 0.
    const fen = '4k3/8/8/8/8/8/8/1N2K3 w - - 0 1';
    final r = await service.scoreMoves(fen, ['b1c3', 'b1a3']);
    expect(r.scores['b1c3'], const EngineScore.cp(0));
    expect(r.scores['b1a3'], const EngineScore.cp(0));
  });

  test('mate scores', () async {
    // Scholar's mate: 4.Qxf7#.
    const fen =
        'r1bqkb1r/pppp1ppp/2n2n2/4p2Q/2B1P3/8/PPPP1PPP/RNB1K1NR w KQkq - 4 4';
    final r = await service.scoreMoves(fen, ['h5f7', 'd2d3']);
    expect(r.scores['h5f7'], const EngineScore.mate(1));
    expect(_cp(r.scores['h5f7']!) - _cp(r.scores['d2d3']!), greaterThan(90000));
  });

  test('top lines: 5 distinct moves', () async {
    final lines = await service.topLines(_italianFen);
    expect(lines, hasLength(5));
    expect(lines.map((l) => l.move).toSet(), hasLength(5));
    expect(_cp(lines.first.score), greaterThanOrEqualTo(_cp(lines.last.score)));
  });

  test('play-on returns a move at limited strength', () async {
    final move = await service.playMove(_italianFen, elo: 1500);
    expect(move, matches(RegExp(r'^[a-h][1-8][a-h][1-8][qrbn]?$')));
  });

  test('analysis reports increasing depth and stops on cancel', () async {
    final depths = <int>[];
    final first = Completer<void>();
    final sub = service.analyse(_italianFen, multiPv: 2).listen((u) {
      depths.add(u.depth);
      expect(u.lines, hasLength(2));
      expect(u.lines.first.move, isNot(u.lines.last.move));
      if (!first.isCompleted) first.complete();
    });
    await first.future;
    await Future<void>.delayed(const Duration(seconds: 3));
    await sub.cancel();
    // Part of the test log.
    // ignore: avoid_print
    print('Analysis depths: $depths');
    expect(depths.length, greaterThanOrEqualTo(2));
    expect(depths.last, greaterThan(depths.first));
    for (var i = 1; i < depths.length; i++) {
      expect(depths[i], greaterThanOrEqualTo(depths[i - 1]));
    }
    final n = depths.length;
    await Future<void>.delayed(const Duration(seconds: 1));
    expect(depths, hasLength(n));
    // The engine is free again.
    final r = await service.scoreMoves(_italianFen, ['b8c6']);
    expect(r.scores, contains('b8c6'));
  });

  test('20 sequential checks on one process', () async {
    for (var i = 0; i < 20; i++) {
      final r = await service.scoreMoves(
        _italianFen,
        ['b8c6', 'g8f6'],
        minTime: const Duration(milliseconds: 100),
        minDepth: 8,
      );
      expect(r.scores, hasLength(2));
    }
    expect(launched, hasLength(1));
  });

  test('calibration', () async {
    final r = await service.calibrate();
    // Part of the test log.
    // ignore: avoid_print
    print(
      'Calibration: ${r.nps} nps, depth ${r.depthAt2s} at 2 s, '
      'median depth ${r.medianDepthAt1s} at 1 s (${r.depthsAt1s})',
    );
    expect(r.nps, greaterThan(10000));
    expect(r.depthsAt1s, hasLength(5));
  });
}
