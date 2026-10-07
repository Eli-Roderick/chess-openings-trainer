import 'dart:async';

import 'package:uci_engine/uci_engine.dart';

/// A scripted Stockfish for app tests: answers the handshake, reports one
/// depth per [step] for the searched moves (scores from [scores], side to
/// move), stops on `stop`, ends `movetime` searches on time.
final class FakeEngine {
  new({
    Map<String, int>? scores,
    this.step = const Duration(milliseconds: 10),
    this.nps = 1500000,
    this.depthCap = 99,
  }) : scores =
           scores ??
           const {'e2e4': 30, 'd2d4': 25, 'g1f3': 20, 'c2c4': 15, 'b1c3': 0};

  /// Centipawn score of each move.
  Map<String, int> scores;

  /// Time per depth.
  final Duration step;

  /// Reported nps.
  final int nps;

  /// Depth stops growing here (a slow device).
  int depthCap;

  /// Every transport started.
  final transports = <FakeTransport>[];

  /// The current transport.
  FakeTransport get current => transports.last;

  /// All commands across transports.
  List<String> get commands => [for (final t in transports) ...t.commands];

  /// Starts a transport (path ignored).
  Future<UciTransport> launch(String path) async {
    final t = FakeTransport(onCommand: _onCommand);
    transports.add(t);
    return t;
  }

  Timer? _ticker;
  Timer? _deadline;
  var _moves = <String>[];
  var _multiPv = 1;
  var _depth = 0;
  int? _targetDepth;

  /// Every `go` command's position (the last `position fen`).
  final searchedFens = <String>[];
  String? _fen;

  void _onCommand(FakeTransport t, String c) {
    if (c == 'uci') {
      t
        ..emit('id name Stockfish 18')
        ..emit('uciok');
    } else if (c == 'isready') {
      t.emit('readyok');
    } else if (c.startsWith('setoption name MultiPV value ')) {
      _multiPv = int.parse(c.split(' ').last);
    } else if (c.startsWith('position fen ')) {
      _fen = c.substring('position fen '.length);
    } else if (c.startsWith('go')) {
      if (_fen != null) searchedFens.add(_fen!);
      final parts = c.split(' ');
      final sm = parts.indexOf('searchmoves');
      _moves = sm >= 0 ? parts.sublist(sm + 1) : scores.keys.toList();
      _depth = 0;
      _ticker = Timer.periodic(step, (_) => _tick(t));
      final d = parts.indexOf('depth');
      _targetDepth = d >= 0 ? int.parse(parts[d + 1]) : null;
      final mt = parts.indexOf('movetime');
      if (mt >= 0) {
        _deadline = Timer(
          Duration(milliseconds: int.parse(parts[mt + 1])),
          () => _finish(t),
        );
      }
    } else if (c == 'stop') {
      _finish(t);
    } else if (c == 'quit') {
      _ticker?.cancel();
      _deadline?.cancel();
      t.exit();
    }
  }

  void _tick(FakeTransport t) {
    if (_depth >= depthCap) return;
    _depth++;
    final ranked = [..._moves]
      ..sort((a, b) => (scores[b] ?? 0).compareTo(scores[a] ?? 0));
    for (var i = 0; i < _multiPv && i < ranked.length; i++) {
      final m = ranked[i];
      t.emit(
        'info depth $_depth multipv ${i + 1} score cp ${scores[m] ?? 0} '
        'nodes ${_depth * 1000} nps $nps pv $m e7e5 g1f3',
      );
    }
    if (_targetDepth != null && _depth >= _targetDepth!) _finish(t);
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
}
