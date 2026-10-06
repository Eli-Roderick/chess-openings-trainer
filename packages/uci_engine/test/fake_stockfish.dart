import 'dart:async';

import 'package:uci_engine/uci_engine.dart';

/// A scripted Stockfish on a [FakeTransport]: answers the handshake,
/// streams one `info` per PV every [step] with growing depth, answers
/// `stop` and `movetime` with `bestmove`.
final class FakeStockfish {
  new({
    Map<String, int>? scores,
    this.step = const Duration(milliseconds: 100),
    this.answerStop = true,
    this.nps = 1000000,
  }) : scores =
           scores ??
           const {'e2e4': 30, 'd2d4': 25, 'g1f3': 20, 'c2c4': 15, 'b1c3': 0};

  /// Centipawn score of each move (side to move).
  final Map<String, int> scores;

  /// Time per depth.
  final Duration step;

  /// Whether `stop` produces `bestmove` (false: a hung engine).
  bool answerStop;

  /// Reported nps.
  final int nps;

  /// Every transport launched.
  final transports = <FakeTransport>[];

  /// Lines emitted before `readyok` of the next search (stale output).
  List<String> staleOnPosition = [];

  /// `go` commands received, across launches.
  final goes = <String>[];

  /// Launcher for [EngineService].
  Future<UciTransport> launch() async {
    final t = FakeTransport(onCommand: _onCommand);
    transports.add(t);
    return t;
  }

  /// The current transport.
  FakeTransport get current => transports.last;

  Timer? _ticker;
  Timer? _deadline;
  List<String> _moves = const [];
  int _multiPv = 1;
  int _depth = 0;

  void _onCommand(FakeTransport t, String c) {
    if (c == 'uci') {
      t
        ..emit('id name Stockfish 18')
        ..emit('id author the Stockfish developers')
        ..emit('option name Threads type spin default 1 min 1 max 1024')
        ..emit('uciok');
    } else if (c == 'isready') {
      staleOnPosition.forEach(t.emit);
      staleOnPosition = [];
      t.emit('readyok');
    } else if (c.startsWith('setoption name MultiPV value ')) {
      _multiPv = int.parse(c.split(' ').last);
    } else if (c.startsWith('go')) {
      goes.add(c);
      final parts = c.split(' ');
      final sm = parts.indexOf('searchmoves');
      _moves = sm >= 0 ? parts.sublist(sm + 1) : scores.keys.toList();
      _depth = 0;
      _ticker = Timer.periodic(step, (_) => _tick(t));
      final mt = parts.indexOf('movetime');
      if (mt >= 0) {
        _deadline = Timer(
          Duration(milliseconds: int.parse(parts[mt + 1])),
          () => _finish(t),
        );
      }
    } else if (c == 'stop') {
      if (answerStop) _finish(t);
    } else if (c == 'quit') {
      _ticker?.cancel();
      _deadline?.cancel();
      t.exit();
    }
  }

  void _tick(FakeTransport t) {
    _depth++;
    final ranked = [..._moves]
      ..sort((a, b) => (scores[b] ?? 0).compareTo(scores[a] ?? 0));
    for (var i = 0; i < _multiPv && i < ranked.length; i++) {
      final m = ranked[i];
      t
        ..emit(
          'info depth $_depth seldepth ${_depth + 4} multipv ${i + 1} '
          'score cp ${scores[m] ?? 0} lowerbound nodes 1 nps $nps pv $m',
        )
        ..emit(
          'info depth $_depth seldepth ${_depth + 4} multipv ${i + 1} '
          'score cp ${scores[m] ?? 0} nodes ${_depth * 1000} nps $nps '
          'time ${_depth * 100} pv $m e7e5',
        );
    }
  }

  void _finish(FakeTransport t) {
    _ticker?.cancel();
    _deadline?.cancel();
    if (_ticker == null) return;
    _ticker = null;
    final ranked = [..._moves]
      ..sort((a, b) => (scores[b] ?? 0).compareTo(scores[a] ?? 0));
    t.emit('bestmove ${ranked.isEmpty ? '(none)' : ranked.first}');
  }

  /// Simulates a crash of the current process.
  void crash() {
    _ticker?.cancel();
    _deadline?.cancel();
    _ticker = null;
    current.exit(139);
  }
}
