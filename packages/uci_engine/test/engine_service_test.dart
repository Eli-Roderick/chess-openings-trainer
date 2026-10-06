import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:test/test.dart';
import 'package:uci_engine/uci_engine.dart';

import 'fake_stockfish.dart';

const _fen = 'rnbqkbnr/pppp1ppp/8/4p3/4P3/5N2/PPPP1PPP/RNBQKB1R b KQkq - 1 2';

/// Runs [body] in fake time with a service on a [FakeStockfish].
void withService(
  void Function(FakeAsync async, EngineService service, FakeStockfish sf)
  body, {
  FakeStockfish? stockfish,
}) {
  fakeAsync((async) {
    final sf = stockfish ?? FakeStockfish();
    final service = EngineService(
      launch: sf.launch,
      options: () => const {'Threads': 2, 'Hash': 64},
    );
    body(async, service, sf);
    unawaited(service.dispose());
    async.flushMicrotasks();
  });
}

T result<T>(
  FakeAsync async,
  Future<T> future, {
  Duration max = const Duration(seconds: 10),
}) {
  T? value;
  Object? error;
  var done = false;
  // Completion is polled below while fake time advances.
  // ignore: discarded_futures
  future.then(
    (v) {
      value = v;
      done = true;
    },
    onError: (Object e) {
      error = e;
      done = true;
    },
  );
  var waited = Duration.zero;
  while (!done && waited < max) {
    async.elapse(const Duration(milliseconds: 50));
    waited += const Duration(milliseconds: 50);
  }
  if (!done) fail('future did not complete within $max');
  if (error != null) Error.throwWithStackTrace(error!, StackTrace.current);
  return value as T;
}

void main() {
  test('start: handshake, options, ready; lazy', () {
    withService((async, service, sf) {
      expect(sf.transports, isEmpty);
      result(async, service.warmUp());
      expect(sf.current.commands, [
        'uci',
        'setoption name Threads value 2',
        'setoption name Hash value 64',
        'isready',
      ]);
      expect(service.status.state, EngineState.ready);
      expect(service.status.name, 'Stockfish 18');
    });
  });

  test('handshake timeout makes the job fail and the engine error', () {
    fakeAsync((async) {
      final service = EngineService(launch: () async => FakeTransport());
      expect(
        () => result(async, service.scoreMoves(_fen, ['b8c6'])),
        throwsA(isA<EngineUnavailable>()),
      );
      expect(service.status.state, EngineState.unavailable);
      unawaited(service.dispose());
      async.flushMicrotasks();
    });
  });

  test('comparable check: one searchmoves search, scores per move, stops '
      'after the minimum time once every move has depth 12', () {
    withService(
      stockfish: FakeStockfish(
        scores: const {'b8c6': 20, 'g8f6': 5, 'f7f6': -80},
      ),
      (async, service, sf) {
        final r = result(
          async,
          service.scoreMoves(_fen, ['b8c6', 'g8f6', 'f7f6']),
        );
        expect(sf.goes.single, 'go infinite searchmoves b8c6 g8f6 f7f6');
        expect(sf.current.commands, contains('setoption name MultiPV value 3'));
        expect(sf.current.commands, contains('position fen $_fen'));
        expect(r.scores, {
          'b8c6': const EngineScore.cp(20),
          'g8f6': const EngineScore.cp(5),
          'f7f6': const EngineScore.cp(-80),
        });
        // Depth 12 arrives at 1.2 s (100 ms per depth).
        expect(r.depth, 12);
        expect(r.elapsed, lessThan(const Duration(milliseconds: 1400)));
        expect(sf.current.commands.last, 'stop');
      },
    );
  });

  test('comparable check stops at the maximum time on a slow engine', () {
    withService(
      stockfish: FakeStockfish(step: const Duration(milliseconds: 400)),
      (async, service, sf) {
        final r = result(async, service.scoreMoves(_fen, ['e2e4', 'd2d4']));
        expect(
          r.elapsed,
          greaterThanOrEqualTo(const Duration(seconds: 2, milliseconds: 500)),
        );
        expect(r.elapsed, lessThan(const Duration(seconds: 3)));
        expect(r.depth, lessThan(12));
        expect(r.scores.keys, unorderedEquals(['e2e4', 'd2d4']));
      },
    );
  });

  test('a longer minimum time scales the maximum (2.5x)', () {
    withService(
      stockfish: FakeStockfish(step: const Duration(milliseconds: 1000)),
      (async, service, sf) {
        final r = result(
          async,
          service.scoreMoves(_fen, [
            'e2e4',
          ], minTime: const Duration(seconds: 2)),
          max: const Duration(seconds: 20),
        );
        expect(r.elapsed, greaterThanOrEqualTo(const Duration(seconds: 5)));
        expect(r.elapsed, lessThan(const Duration(milliseconds: 5600)));
      },
    );
  });

  test('stale output before readyok is not attributed to the next job', () {
    withService((async, service, sf) {
      result(async, service.warmUp());
      sf.staleOnPosition = [
        'info depth 30 multipv 1 score cp 999 pv b8c6',
        'bestmove b8c6',
      ];
      final r = result(async, service.scoreMoves(_fen, ['b8c6']));
      expect(r.scores['b8c6'], const EngineScore.cp(0));
    });
  });

  test('high-priority jobs preempt low ones, which are re-queued', () {
    withService((async, service, sf) {
      final low = service.topLines(_fen, movetime: const Duration(seconds: 2));
      async.elapse(const Duration(milliseconds: 300));
      final high = service.scoreMoves(_fen, ['e2e4']);
      final highResult = result(async, high);
      expect(highResult.scores, contains('e2e4'));
      final lowResult = result(async, low);
      expect(lowResult, hasLength(5));
      expect(lowResult.first.move, 'e2e4');
      expect(sf.goes, [
        'go movetime 2000',
        'go infinite searchmoves e2e4',
        'go movetime 2000',
      ]);
    });
  });

  test('cancelled low jobs complete with EngineJobCancelled', () {
    withService((async, service, sf) {
      final token = EngineCancelToken();
      final low = service.topLines(_fen, cancel: token);
      async.elapse(const Duration(milliseconds: 200));
      token.cancel();
      expect(() => result(async, low), throwsA(isA<EngineJobCancelled>()));
    });
  });

  test('crash: restarts once and retries; a second crash within 60 s '
      'makes the engine unavailable until restart', () {
    withService((async, service, sf) {
      final first = service.topLines(_fen);
      async.elapse(const Duration(milliseconds: 300));
      sf.crash();
      final lines = result(async, first);
      expect(lines, isNotEmpty);
      expect(sf.transports, hasLength(2));

      async.elapse(const Duration(seconds: 10));
      final second = service.topLines(_fen);
      async.elapse(const Duration(milliseconds: 300));
      sf.crash();
      expect(() => result(async, second), throwsA(isA<EngineUnavailable>()));
      expect(service.status.state, EngineState.unavailable);
      expect(
        () => result(async, service.scoreMoves(_fen, ['e2e4'])),
        throwsA(isA<EngineUnavailable>()),
      );

      result(async, service.restart());
      expect(service.status.state, EngineState.ready);
      expect(
        result(async, service.scoreMoves(_fen, ['e2e4'])).scores,
        isNotEmpty,
      );
    });
  });

  test('crashes more than 60 s apart restart each time', () {
    withService((async, service, sf) {
      result(async, service.warmUp());
      sf.crash();
      async.flushMicrotasks();
      expect(service.status.state, EngineState.error);
      async.elapse(const Duration(seconds: 61));
      result(async, service.warmUp());
      sf.crash();
      async.flushMicrotasks();
      expect(service.status.state, EngineState.error);
      expect(result(async, service.topLines(_fen)), isNotEmpty);
    });
  });

  test('lifecycle: pause stops the search, quits after 60 s, resume and a '
      'job restart it', () {
    withService((async, service, sf) {
      final analysis = <AnalysisUpdate>[];
      final sub = service.analyse(_fen).listen(analysis.add);
      async.elapse(const Duration(milliseconds: 500));
      service.pause();
      async.elapse(const Duration(milliseconds: 100));
      expect(sf.current.commands.last, 'stop');
      final count = analysis.length;
      async.elapse(const Duration(seconds: 30));
      expect(analysis.length, count);
      expect(sf.current.exited, isFalse);
      async.elapse(const Duration(seconds: 31));
      expect(sf.current.commands.last, 'quit');
      expect(sf.current.exited, isTrue);
      expect(service.status.state, EngineState.stopped);

      service.resume();
      async.elapse(const Duration(milliseconds: 600));
      expect(sf.transports, hasLength(2));
      expect(analysis.length, greaterThan(count));
      unawaited(sub.cancel());
      async.flushMicrotasks();
    });
  });

  test('resume before 60 s keeps the process', () {
    withService((async, service, sf) {
      result(async, service.warmUp());
      service.pause();
      async.elapse(const Duration(seconds: 30));
      service.resume();
      async.elapse(const Duration(seconds: 60));
      expect(sf.current.exited, isFalse);
      expect(sf.transports, hasLength(1));
    });
  });

  test('analysis: throttled to 10 per second, White POV, cancel stops', () {
    withService(
      stockfish: FakeStockfish(step: const Duration(milliseconds: 20)),
      (async, service, sf) {
        final updates = <AnalysisUpdate>[];
        final sub = service.analyse(_fen, multiPv: 2).listen(updates.add);
        async.elapse(const Duration(seconds: 1));
        expect(updates.length, inInclusiveRange(9, 11));
        expect(updates.last.lines, hasLength(2));
        // Black to move: e2e4 is scored 30 for the side to move.
        expect(updates.last.lines.first.score, const EngineScore.cp(-30));
        expect(updates.last.depth, greaterThan(updates.first.depth));
        expect(updates.last.nps, 1000000);
        unawaited(sub.cancel());
        async.elapse(const Duration(milliseconds: 100));
        expect(sf.current.commands.last, 'stop');
        final n = updates.length;
        async.elapse(const Duration(seconds: 1));
        expect(updates, hasLength(n));
        expect(service.status.state, EngineState.ready);
      },
    );
  });

  test('play-on: strength limited, then reset', () {
    withService((async, service, sf) {
      final move = result(async, service.playMove(_fen, elo: 2000));
      expect(move, 'e2e4');
      final c = sf.current.commands;
      expect(c, contains('setoption name UCI_LimitStrength value true'));
      expect(c, contains('setoption name UCI_Elo value 2000'));
      expect(c.last, 'setoption name UCI_LimitStrength value false');
      expect(sf.goes.last, 'go movetime 600');
      result(async, service.playMove(_fen));
      expect(
        sf.current.commands,
        isNot(contains('setoption name UCI_Elo value null')),
      );
    });
  });

  test('best line for reply judgement', () {
    withService((async, service, sf) {
      final best = result(async, service.bestLine(_fen))!;
      expect(best.move, 'e2e4');
      expect(best.score, const EngineScore.cp(30));
      expect(best.depth, greaterThanOrEqualTo(12));
    });
  });

  test('an engine that ignores stop is killed and restarted', () {
    withService(stockfish: FakeStockfish()..answerStop = false, (
      async,
      service,
      sf,
    ) {
      final job = service.scoreMoves(_fen, ['e2e4']);
      // First attempt hangs on stop; the retry hangs too.
      expect(() => result(async, job), throwsA(isA<EngineUnavailable>()));
      expect(sf.transports.length, 2);
      expect(sf.transports.first.exited, isTrue);
    });
  });

  test('calibration', () {
    withService((async, service, sf) {
      final r = result(
        async,
        service.calibrate(),
        max: const Duration(seconds: 20),
      );
      expect(r.nps, 1000000);
      expect(r.depthAt2s, inInclusiveRange(19, 20));
      expect(r.depthsAt1s, hasLength(5));
      expect(r.medianDepthAt1s, inInclusiveRange(9, 10));
      expect(sf.goes, [
        'go movetime 2000',
        for (var i = 0; i < 5; i++) 'go movetime 1000',
      ]);
    });
  });

  test('20 sequential checks reuse one process', () {
    withService((async, service, sf) {
      for (var i = 0; i < 20; i++) {
        result(async, service.scoreMoves(_fen, ['e2e4', 'd2d4']));
      }
      expect(sf.transports, hasLength(1));
      expect(sf.goes, hasLength(20));
      expect(service.recentJobs, hasLength(20));
      expect(
        service.recentJobs.every((j) => j.kind == 'check' && j.ok),
        isTrue,
      );
      result(async, service.topLines(_fen));
      expect(service.recentJobs, hasLength(20));
      expect(service.recentJobs.last.kind, 'candidates');
    });
  });
}
