import 'dart:async';

import 'package:uci_engine/src/parser.dart';
import 'package:uci_engine/src/transport.dart';

/// The engine stopped answering or exited.
final class EngineFailure implements Exception {
  /// Creates the failure.
  const new(this.message);

  /// What happened.
  final String message;

  @override
  String toString() => 'EngineFailure: $message';
}

/// How long a search runs.
sealed class SearchLimit {
  const new();
}

/// `go movetime <ms>`.
final class MoveTime extends SearchLimit {
  /// Creates the limit.
  const new(this.duration);

  /// Search time.
  final Duration duration;
}

/// `go infinite` (until the search is stopped).
final class Infinite extends SearchLimit {
  /// Creates the limit.
  const new();
}

/// `go depth <plies>`: a fixed-depth search (reproducible with one thread
/// and a cleared hash; Game Review).
final class Depth extends SearchLimit {
  /// Searches to [plies].
  const new(this.plies);

  /// Depth in plies.
  final int plies;
}

/// One search to run.
final class SearchRequest {
  /// Creates the request.
  const new({
    required this.fen,
    required this.limit,
    this.multiPv = 1,
    this.searchMoves = const [],
  });

  /// Position.
  final String fen;

  /// Time limit.
  final SearchLimit limit;

  /// Number of principal variations.
  final int multiPv;

  /// Restrict the search to these moves (UCI); empty for all moves.
  final List<String> searchMoves;

  /// The `go` command.
  String get goCommand {
    final parts = ['go'];
    switch (limit) {
      case MoveTime(:final duration):
        parts.addAll(['movetime', '${duration.inMilliseconds}']);
      case Infinite():
        parts.add('infinite');
      case Depth(:final plies):
        parts.addAll(['depth', '$plies']);
    }
    if (searchMoves.isNotEmpty) parts.addAll(['searchmoves', ...searchMoves]);
    return parts.join(' ');
  }
}

/// A running search: [infos] until [done] completes with the best move.
final class UciSearch {
  new _(this._engine);

  final UciEngine _engine;
  final _infos = StreamController<SearchInfo>.broadcast(sync: true);
  final _done = Completer<BestMove>();

  /// Parsed `info` lines with a score.
  Stream<SearchInfo> get infos => _infos.stream;

  /// Completes with `bestmove` (or an [EngineFailure]).
  Future<BestMove> get done => _done.future;

  /// Whether the search has finished.
  bool get isDone => _done.isCompleted;

  /// Sends `stop` and waits for `bestmove` (1 s; then the engine is
  /// considered hung and killed).
  Future<BestMove> stop() => _engine._stop(this);

  void _finish(BestMove best) {
    if (_done.isCompleted) return;
    _done.complete(best);
    unawaited(_infos.close());
  }

  void _fail(Object error) {
    if (_done.isCompleted) return;
    _done.completeError(error);
    unawaited(_infos.close());
  }
}

/// A UCI engine over a [UciTransport] (docs/plan/05-engine.md §4): one
/// search at a time.
final class UciEngine {
  /// Wraps a transport; call [start] next.
  new(this._transport, {this.handshakeTimeout = const Duration(seconds: 5)}) {
    _sub = _transport.lines.listen(_onLine, onDone: _onClosed);
    unawaited(
      _transport.exitCode.then((code) {
        if (!_quitting) _onClosed();
      }),
    );
  }

  final UciTransport _transport;

  /// Timeout for `uciok` and `readyok`.
  final Duration handshakeTimeout;

  late final StreamSubscription<String> _sub;
  final _waiters = <(bool Function(String), Completer<String>)>[];
  UciSearch? _search;
  bool _readyForSearch = false;
  bool _closed = false;
  bool _quitting = false;
  final _id = <String, String>{};

  /// `id name` from the handshake.
  String? get name => _id['name'];

  /// Whether the process has exited.
  bool get isClosed => _closed;

  /// Completes when the process exits.
  Future<int> get exitCode => _transport.exitCode;

  void _onLine(String line) {
    for (final w in [..._waiters]) {
      if (w.$1(line)) {
        _waiters.remove(w);
        w.$2.complete(line);
      }
    }
    if (line.startsWith('id ')) {
      final rest = line.substring(3);
      final space = rest.indexOf(' ');
      if (space > 0) _id[rest.substring(0, space)] = rest.substring(space + 1);
    }
    final search = _search;
    if (search == null || !_readyForSearch) return;
    final info = parseInfo(line);
    if (info != null) {
      search._infos.add(info);
      return;
    }
    final best = parseBestMove(line);
    if (best != null) {
      _search = null;
      search._finish(best);
    }
  }

  void _onClosed() {
    if (_closed) return;
    _closed = true;
    const failure = EngineFailure('engine exited');
    for (final w in _waiters) {
      w.$2.completeError(failure);
    }
    _waiters.clear();
    _search?._fail(failure);
    _search = null;
  }

  Future<String> _await(
    bool Function(String) test,
    Duration timeout,
    String what,
  ) {
    if (_closed) return Future.error(const EngineFailure('engine exited'));
    final c = Completer<String>();
    final entry = (test, c);
    _waiters.add(entry);
    return c.future.timeout(
      timeout,
      onTimeout: () {
        _waiters.remove(entry);
        throw EngineFailure('no $what within ${timeout.inMilliseconds} ms');
      },
    );
  }

  void _send(String command) {
    if (_closed) throw const EngineFailure('engine exited');
    _transport.send(command);
  }

  /// `uci` → `uciok`, the [options], then `isready` → `readyok`.
  Future<void> start({Map<String, Object> options = const {}}) async {
    final ok = _await((l) => l.trim() == 'uciok', handshakeTimeout, 'uciok');
    _send('uci');
    await ok;
    options.forEach(setOption);
    await isReady();
  }

  /// `setoption name <name> value <value>`.
  void setOption(String name, Object value) =>
      _send('setoption name $name value $value');

  /// `isready` → `readyok`.
  Future<void> isReady() {
    final ready = _await(
      (l) => l.trim() == 'readyok',
      handshakeTimeout,
      'readyok',
    );
    _send('isready');
    return ready;
  }

  /// `ucinewgame` + `isready`.
  Future<void> newGame() {
    _send('ucinewgame');
    return isReady();
  }

  /// Starts [request]. Lines from an earlier search are discarded: the
  /// position is set and `isready` answered before `go` is sent.
  Future<UciSearch> search(SearchRequest request) async {
    if (_search != null) throw StateError('a search is running');
    final search = _search = UciSearch._(this);
    _readyForSearch = false;
    try {
      setOption('MultiPV', request.multiPv);
      _send('position fen ${request.fen}');
      await isReady();
    } on Object catch (e) {
      _search = null;
      search._fail(e);
      rethrow;
    }
    _readyForSearch = true;
    _send(request.goCommand);
    return search;
  }

  Future<BestMove> _stop(UciSearch search) async {
    if (search.isDone) return await search.done;
    _send('stop');
    try {
      return await search.done.timeout(const Duration(seconds: 1));
    } on TimeoutException {
      _search = null;
      search._fail(const EngineFailure('no bestmove after stop'));
      await _transport.kill();
      throw const EngineFailure('no bestmove after stop');
    }
  }

  /// `quit`; kills the process if it has not exited after 500 ms.
  Future<void> dispose() async {
    if (_closed) return;
    _quitting = true;
    _search?._fail(const EngineFailure('engine quit'));
    _search = null;
    try {
      _transport.send('quit');
      await _transport.exitCode.timeout(const Duration(milliseconds: 500));
    } on TimeoutException {
      await _transport.kill();
    }
    _onClosed();
    // The output stream has ended; cancelling it can wait forever.
    unawaited(_sub.cancel());
  }
}
