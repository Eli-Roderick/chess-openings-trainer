import 'dart:async';
import 'dart:collection';

import 'package:clock/clock.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:uci_engine/src/engine.dart';
import 'package:uci_engine/src/parser.dart';
import 'package:uci_engine/src/transport.dart';

/// Engine lifecycle state.
enum EngineState {
  /// No process (not started yet, or quit while in the background).
  stopped,

  /// Starting the process / handshake.
  starting,

  /// Idle and ready.
  ready,

  /// Running a job.
  searching,

  /// Crashed; restarts on the next job.
  error,

  /// Crashed twice within 60 s; needs [EngineService.restart].
  unavailable,
}

/// What the app shows about the engine.
@immutable
final class EngineStatus {
  /// Creates a status.
  const new(this.state, {this.name, this.message});

  /// The state.
  final EngineState state;

  /// `id name` of the engine, once known.
  final String? name;

  /// Error detail.
  final String? message;

  /// Whether jobs can run (now or after a lazy start).
  bool get isAvailable => state != EngineState.unavailable;

  @override
  bool operator ==(Object other) =>
      other is EngineStatus &&
      other.state == state &&
      other.name == name &&
      other.message == message;

  @override
  int get hashCode => Object.hash(state, name, message);

  @override
  String toString() => 'EngineStatus(${state.name}, $name, $message)';
}

/// Jobs fail with this while the engine is unavailable.
final class EngineUnavailable implements Exception {
  /// Creates it.
  const new([this.message = 'engine unavailable']);

  /// Detail.
  final String message;

  @override
  String toString() => 'EngineUnavailable: $message';
}

/// The job was cancelled before it finished.
final class EngineJobCancelled implements Exception {
  /// Creates it.
  const new();
}

/// One principal variation.
@immutable
final class PvLine {
  /// Creates the line.
  const new({required this.score, required this.pv, required this.depth});

  /// Score from the side to move.
  final EngineScore score;

  /// UCI moves.
  final List<String> pv;

  /// Depth of the search that produced it.
  final int depth;

  /// The first move.
  String get move => pv.first;
}

/// Scores of the moves of a restricted search (comparable check).
@immutable
final class MoveScores {
  /// Creates the result.
  const new({required this.scores, required this.depth, required this.elapsed});

  /// Score of each searched move (side to move); a move the engine did not
  /// report is missing.
  final Map<String, EngineScore> scores;

  /// Smallest depth over the moves.
  final int depth;

  /// Search time.
  final Duration elapsed;
}

/// One analysis snapshot (throttled to 10 per second).
@immutable
final class AnalysisUpdate {
  /// Creates it.
  const new({required this.depth, required this.lines, this.nps});

  /// Depth of the first line.
  final int depth;

  /// Lines by MultiPV order; scores from White's point of view.
  final List<PvLine> lines;

  /// Nodes per second.
  final int? nps;
}

/// Calibration numbers (docs/plan/05-engine.md §9).
@immutable
final class CalibrationResult {
  /// Creates it.
  const new({
    required this.nps,
    required this.depthAt2s,
    required this.depthsAt1s,
  });

  /// Nodes per second from the start position, 2 s.
  final int nps;

  /// Depth reached in those 2 s.
  final int depthAt2s;

  /// Depth reached in 1 s on each calibration position.
  final List<int> depthsAt1s;

  /// Median of [depthsAt1s].
  int get medianDepthAt1s {
    final sorted = [...depthsAt1s]..sort();
    return sorted.isEmpty ? 0 : sorted[sorted.length ~/ 2];
  }
}

/// Positions for the depth-at-1-s calibration (common opening positions).
const calibrationFens = [
  'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
  'r1bqkbnr/pppp1ppp/2n5/4p3/2B1P3/5N2/PPPP1PPP/RNBQK2R b KQkq - 3 3',
  'rnbqkb1r/pp2pppp/3p1n2/8/3NP3/8/PPP2PPP/RNBQKB1R w KQkq - 1 5',
  'rnbqkb1r/ppp1pppp/5n2/3p4/2PP4/2N5/PP2PPPP/R1BQKBNR b KQkq - 2 3',
  'rn1qkbnr/pp2pppp/2p5/3pPb2/3P4/8/PPP2PPP/RNBQKBNR w KQkq - 1 4',
];

/// One finished job, for Diagnostics.
@immutable
final class EngineJobRecord {
  /// Creates it.
  const new(this.kind, this.duration, {required this.ok});

  /// Job type.
  final String kind;

  /// Run time (excluding queueing).
  final Duration duration;

  /// False if it failed or was cancelled.
  final bool ok;
}

/// Starts a fresh engine process.
typedef EngineLauncher = Future<UciTransport> Function();

/// Options set after every start (Threads, Hash, ...).
typedef EngineOptions = Map<String, Object> Function();

enum _Priority { high, low }

final class _Preempted implements Exception {
  const new();
}

abstract class _Job<T> {
  new(this.priority, this.kind);

  final _Priority priority;

  /// Job type for the history (check, best, candidates, play, analysis,
  /// calibration).
  final String kind;
  final completer = Completer<T>();
  bool cancelled = false;
  bool preempted = false;
  UciSearch? search;

  Future<T> run(UciEngine engine);

  /// Stops the running search because a higher-priority job arrived.
  void preempt() {
    preempted = true;
    unawaited(search?.stop().then((_) {}, onError: (Object _) {}));
  }

  /// Stops it for good.
  void cancel() {
    cancelled = true;
    unawaited(search?.stop().then((_) {}, onError: (Object _) {}));
  }

  /// Runs [request] until it ends (or [enough] / [maxTime] stop it) and
  /// returns its exact (non-bound) infos in order.
  Future<List<SearchInfo>> searchUntilDone(
    UciEngine engine,
    SearchRequest request, {
    bool Function(List<SearchInfo> infos, Duration elapsed)? enough,
    Duration? checkAt,
    Duration? maxTime,
    void Function(SearchInfo info)? onInfo,
  }) async {
    final infos = <SearchInfo>[];
    final watch = clock.stopwatch()..start();
    final s = search = await engine.search(request);
    var stopping = false;
    void stop() {
      if (stopping) return;
      stopping = true;
      unawaited(s.stop().then((_) {}, onError: (Object _) {}));
    }

    void check() {
      if (enough != null && enough(infos, watch.elapsed)) stop();
    }

    final sub = s.infos.listen((info) {
      if (!info.bound) infos.add(info);
      onInfo?.call(info);
      check();
    });
    final timers = [
      if (checkAt != null) Timer(checkAt, check),
      if (maxTime != null) Timer(maxTime, stop),
    ];
    if (cancelled || preempted) stop();
    try {
      await s.done;
    } finally {
      for (final t in timers) {
        t.cancel();
      }
      // The info stream is closed by now; its cancel future waits on the
      // controller's done future, so it is not awaited.
      unawaited(sub.cancel());
      search = null;
    }
    if (preempted) throw const _Preempted();
    if (cancelled) throw const EngineJobCancelled();
    return infos;
  }
}

/// The deepest exact info for each first move (later lines win at equal
/// depth). A stopped search can leave a MultiPV slot holding an older line
/// whose move has since moved to another slot, so results are keyed by
/// move, not by slot.
Map<String, SearchInfo> deepestByMove(List<SearchInfo> infos) {
  final byMove = <String, SearchInfo>{};
  for (final i in infos) {
    final old = byMove[i.pv.first];
    if (old == null || i.depth >= old.depth) byMove[i.pv.first] = i;
  }
  return byMove;
}

/// The lines of the deepest iteration that reported every MultiPV slot up
/// to the most seen (at most [multiPv]); before any complete iteration,
/// the deepest line per move, best first.
List<SearchInfo> lastCompleteIteration(List<SearchInfo> infos, int multiPv) {
  if (infos.isEmpty) return const [];
  final slots = infos
      .map((i) => i.multiPv)
      .where((m) => m <= multiPv)
      .fold(0, (a, b) => a > b ? a : b);
  final byDepth = <int, Map<int, SearchInfo>>{};
  for (final i in infos) {
    if (i.multiPv <= slots) (byDepth[i.depth] ??= {})[i.multiPv] = i;
  }
  final depths = byDepth.keys.toList()..sort((a, b) => b.compareTo(a));
  for (final d in depths) {
    final row = byDepth[d]!;
    if (row.length == slots) {
      return [for (var m = 1; m <= slots; m++) row[m]!];
    }
  }
  return deepestByMove(infos).values.toList()
    ..sort((a, b) => a.multiPv.compareTo(b.multiPv));
}

final class _FnJob<T> extends _Job<T> {
  new(super.priority, super.kind, this.body);

  final Future<T> Function(_FnJob<T> job, UciEngine engine) body;

  @override
  Future<T> run(UciEngine engine) => body(this, engine);
}

/// The only engine API the app uses (docs/plan/05-engine.md §4): a queue
/// running one search at a time. High-priority jobs (comparable checks,
/// reply judgements, play-on moves) preempt low-priority ones (deviation
/// candidates, analysis, calibration), which are re-queued. Starts the
/// engine lazily; restarts once after a crash; a second crash within 60 s
/// makes it unavailable until [restart].
final class EngineService {
  /// Creates the service.
  new({
    required this._launch,
    EngineOptions? options,
    this.idleQuitAfter = const Duration(seconds: 60),
    this.crashWindow = const Duration(seconds: 60),
    this.analysisInterval = const Duration(milliseconds: 100),
  }) : _options = options ?? (() => const {});

  final EngineLauncher _launch;
  final EngineOptions _options;

  /// Background time after which the process quits.
  final Duration idleQuitAfter;

  /// Two crashes within this window make the engine unavailable.
  final Duration crashWindow;

  /// Minimum time between analysis updates.
  final Duration analysisInterval;

  final _high = Queue<_Job<Object?>>();
  final _low = Queue<_Job<Object?>>();
  final _statusController = StreamController<EngineStatus>.broadcast();
  EngineStatus _status = const EngineStatus(EngineState.stopped);
  UciEngine? _engine;
  Future<UciEngine>? _starting;
  _Job<Object?>? _current;
  bool _pumping = false;
  bool _paused = false;
  bool _disposed = false;
  Timer? _quitTimer;
  DateTime? _lastCrash;

  final _history = Queue<EngineJobRecord>();

  /// The last 20 finished jobs, newest last.
  List<EngineJobRecord> get recentJobs => List.unmodifiable(_history);

  void _record(_Job<Object?> job, Duration took, {required bool ok}) {
    _history.add(EngineJobRecord(job.kind, took, ok: ok));
    while (_history.length > 20) {
      _history.removeFirst();
    }
  }

  /// Current status.
  EngineStatus get status => _status;

  /// Status changes.
  Stream<EngineStatus> get statusChanges => _statusController.stream;

  void _setStatus(EngineStatus s) {
    if (s == _status) return;
    _status = s;
    if (!_statusController.isClosed) _statusController.add(s);
  }

  void _setState(EngineState state, {String? message}) => _setStatus(
    EngineStatus(state, name: _engine?.name ?? _status.name, message: message),
  );

  Future<T> _enqueue<T>(_Job<T> job) {
    if (_disposed) return Future.error(const EngineUnavailable('disposed'));
    if (_status.state == EngineState.unavailable) {
      return Future.error(const EngineUnavailable());
    }
    (job.priority == _Priority.high ? _high : _low).add(job);
    final current = _current;
    if (job.priority == _Priority.high &&
        current != null &&
        current.priority == _Priority.low) {
      current.preempt();
    }
    unawaited(_pump());
    return job.completer.future;
  }

  _Job<Object?>? _next() {
    if (_high.isNotEmpty) return _high.removeFirst();
    if (_low.isNotEmpty) return _low.removeFirst();
    return null;
  }

  Future<void> _pump() async {
    if (_pumping) return;
    _pumping = true;
    try {
      while (!_paused && !_disposed) {
        final job = _next();
        if (job == null) break;
        if (job.cancelled) {
          _fail(job, const EngineJobCancelled());
          continue;
        }
        await _runOne(job);
      }
    } finally {
      _pumping = false;
    }
  }

  Future<void> _runOne(_Job<Object?> job, {bool retried = false}) async {
    UciEngine engine;
    try {
      engine = await _ensureEngine();
    } on Object catch (e) {
      _onCrash('$e');
      if (!retried && _status.state != EngineState.unavailable) {
        await _runOne(job, retried: true);
        return;
      }
      return _fail(job, EngineUnavailable('$e'));
    }
    _current = job;
    job.preempted = false;
    _setState(EngineState.searching);
    final watch = clock.stopwatch()..start();
    var ok = false;
    try {
      final result = await job.run(engine);
      ok = true;
      if (!job.completer.isCompleted) job.completer.complete(result);
    } on _Preempted {
      if (job.cancelled) {
        _fail(job, const EngineJobCancelled());
      } else {
        _low.addFirst(job);
      }
    } on EngineJobCancelled catch (e) {
      _fail(job, e);
    } on EngineFailure catch (e) {
      _onCrash(e.message, crashed: engine);
      if (!retried &&
          !job.cancelled &&
          _status.state != EngineState.unavailable) {
        _current = null;
        await _runOne(job, retried: true);
        return;
      }
      _fail(job, EngineUnavailable(e.message));
    } on Object catch (e, st) {
      if (!job.completer.isCompleted) job.completer.completeError(e, st);
    } finally {
      _record(job, watch.elapsed, ok: ok);
      _current = null;
      if (_engine != null && _status.state == EngineState.searching) {
        _setState(EngineState.ready);
      }
    }
  }

  void _fail(_Job<Object?> job, Object error) {
    if (!job.completer.isCompleted) job.completer.completeError(error);
  }

  /// Records a crash of [crashed] (null: the engine failed to start). A
  /// crash is reported both by the process exit and by the failing job;
  /// only the first report for an engine counts.
  void _onCrash(String message, {UciEngine? crashed}) {
    if (crashed != null && !identical(crashed, _engine)) return;
    final engine = _engine;
    _engine = null;
    _starting = null;
    if (engine != null) unawaited(engine.dispose());
    final now = clock.now();
    final last = _lastCrash;
    _lastCrash = now;
    if (last != null && now.difference(last) < crashWindow) {
      _setStatus(
        EngineStatus(
          EngineState.unavailable,
          name: _status.name,
          message: message,
        ),
      );
      for (final job in [..._high, ..._low]) {
        _fail(job, EngineUnavailable(message));
      }
      _high.clear();
      _low.clear();
    } else {
      _setStatus(
        EngineStatus(EngineState.error, name: _status.name, message: message),
      );
    }
  }

  Future<UciEngine> _ensureEngine() {
    final engine = _engine;
    if (engine != null && !engine.isClosed) return Future.value(engine);
    return _starting ??= _start();
  }

  Future<UciEngine> _start() async {
    _setState(EngineState.starting);
    try {
      final transport = await _launch();
      final engine = UciEngine(transport);
      await engine.start(options: _options());
      _engine = engine;
      unawaited(
        engine.exitCode.then((_) {
          if (!_disposed) _onCrash('engine exited', crashed: engine);
        }),
      );
      _setStatus(EngineStatus(EngineState.ready, name: engine.name));
      return engine;
    } finally {
      _starting = null;
    }
  }

  /// Starts the process now (pre-warm) if it is not running.
  Future<void> warmUp() async {
    if (_status.state == EngineState.unavailable || _disposed) return;
    try {
      await _ensureEngine();
    } on Object catch (e) {
      _onCrash('$e');
    }
  }

  /// Scores [moves] in [fen] with one `searchmoves` search
  /// (docs/plan/05-engine.md §5): runs at least [minTime] and until every
  /// move has depth [minDepth], at most [maxTime]. High priority.
  Future<MoveScores> scoreMoves(
    String fen,
    List<String> moves, {
    Duration minTime = const Duration(seconds: 1),
    Duration? maxTime,
    int minDepth = 12,
  }) {
    final max = maxTime ?? _maxTimeFor(minTime);
    return _enqueue(
      _FnJob<MoveScores>(_Priority.high, 'check', (job, engine) async {
        final watch = clock.stopwatch()..start();
        bool deepEnough(Map<String, SearchInfo> byMove) =>
            moves.every((m) => (byMove[m]?.depth ?? 0) >= minDepth);
        final infos = await job.searchUntilDone(
          engine,
          SearchRequest(
            fen: fen,
            limit: const Infinite(),
            multiPv: moves.length,
            searchMoves: moves,
          ),
          checkAt: minTime,
          maxTime: max,
          enough: (infos, elapsed) =>
              elapsed >= minTime && deepEnough(deepestByMove(infos)),
        );
        final byMove = deepestByMove(infos)
          ..removeWhere((m, _) => !moves.contains(m));
        return MoveScores(
          scores: {for (final e in byMove.entries) e.key: e.value.score},
          depth: byMove.length < moves.length
              ? 0
              : byMove.values
                    .map((i) => i.depth)
                    .reduce((a, b) => a < b ? a : b),
          elapsed: watch.elapsed,
        );
      }),
    );
  }

  /// The best move and its score with the comparable-check budget
  /// (reply judgement, 04-algorithms §7.3). High priority.
  Future<PvLine?> bestLine(
    String fen, {
    Duration minTime = const Duration(seconds: 1),
    Duration? maxTime,
    int minDepth = 12,
  }) {
    final max = maxTime ?? _maxTimeFor(minTime);
    return _enqueue(
      _FnJob<PvLine?>(_Priority.high, 'best', (job, engine) async {
        SearchInfo? first(List<SearchInfo> infos) =>
            infos.lastWhereOrNull((i) => i.multiPv == 1);
        final infos = await job.searchUntilDone(
          engine,
          SearchRequest(fen: fen, limit: const Infinite()),
          checkAt: minTime,
          maxTime: max,
          enough: (infos, elapsed) =>
              elapsed >= minTime && (first(infos)?.depth ?? 0) >= minDepth,
        );
        final best = first(infos);
        return best == null
            ? null
            : PvLine(score: best.score, pv: best.pv, depth: best.depth);
      }),
    );
  }

  /// The top [multiPv] lines after [movetime] (deviation candidates,
  /// 05-engine §6). Low priority; cancel with [cancel] (completes with
  /// [EngineJobCancelled]).
  Future<List<PvLine>> topLines(
    String fen, {
    int multiPv = 5,
    Duration movetime = const Duration(milliseconds: 800),
    EngineCancelToken? cancel,
  }) {
    final job = _FnJob<List<PvLine>>(_Priority.low, 'candidates', (
      job,
      engine,
    ) async {
      final infos = await job.searchUntilDone(
        engine,
        SearchRequest(fen: fen, limit: MoveTime(movetime), multiPv: multiPv),
      );
      return [
        for (final i in lastCompleteIteration(infos, multiPv))
          PvLine(score: i.score, pv: i.pv, depth: i.depth),
      ];
    });
    cancel?._attach(job);
    return _enqueue(job);
  }

  /// A move for play-on (05-engine §7): limited to [elo] (null: full
  /// strength), [movetime]. High priority. Null if there is no legal move.
  Future<String?> playMove(
    String fen, {
    int? elo,
    Duration movetime = const Duration(milliseconds: 600),
  }) => _enqueue(
    _FnJob<String?>(_Priority.high, 'play', (job, engine) async {
      engine.setOption('UCI_LimitStrength', elo != null);
      if (elo != null) engine.setOption('UCI_Elo', elo);
      try {
        final s = job.search = await engine.search(
          SearchRequest(fen: fen, limit: MoveTime(movetime)),
        );
        final best = await s.done;
        return best.move;
      } finally {
        job.search = null;
        if (elo != null && !engine.isClosed) {
          engine.setOption('UCI_LimitStrength', false);
        }
      }
    }),
  );

  /// Infinite analysis of [fen] with [multiPv] lines (05-engine §8),
  /// throttled; scores from White's point of view. Cancel the
  /// subscription to stop. Low priority: a high-priority job pauses it.
  Stream<AnalysisUpdate> analyse(String fen, {int multiPv = 1}) {
    late final StreamController<AnalysisUpdate> out;
    _FnJob<void>? job;
    final white = whiteToMove(fen);
    out = StreamController<AnalysisUpdate>(
      onListen: () {
        job = _FnJob<void>(_Priority.low, 'analysis', (job, engine) async {
          // Exact lines of the two deepest iterations seen.
          var recent = <SearchInfo>[];
          var lastEmit = Duration.zero;
          final watch = clock.stopwatch()..start();
          Timer? pending;
          void emit() {
            pending = null;
            lastEmit = watch.elapsed;
            final lines = lastCompleteIteration(recent, multiPv);
            if (lines.isEmpty || out.isClosed) return;
            out.add(
              AnalysisUpdate(
                depth: lines.first.depth,
                nps: recent.last.nps,
                lines: [
                  for (final i in lines)
                    PvLine(
                      score: white ? i.score : i.score.negated,
                      pv: i.pv,
                      depth: i.depth,
                    ),
                ],
              ),
            );
          }

          try {
            await job.searchUntilDone(
              engine,
              SearchRequest(
                fen: fen,
                limit: const Infinite(),
                multiPv: multiPv,
              ),
              onInfo: (info) {
                if (info.bound || info.multiPv > multiPv) return;
                recent.add(info);
                if (recent.length > 4 * multiPv) {
                  final keep = info.depth - 1;
                  recent = [
                    for (final r in recent)
                      if (r.depth >= keep) r,
                  ];
                }
                final since = watch.elapsed - lastEmit;
                if (since >= analysisInterval) {
                  pending?.cancel();
                  emit();
                } else {
                  pending ??= Timer(analysisInterval - since, emit);
                }
              },
            );
          } finally {
            pending?.cancel();
          }
        });
        unawaited(
          _enqueue(job!).then(
            (_) {},
            onError: (Object e) {
              if (e is EngineUnavailable && !out.isClosed) out.addError(e);
            },
          ),
        );
      },
      onCancel: () {
        job?.cancel();
        _high.remove(job);
        _low.remove(job);
        if (job != null) _fail(job!, const EngineJobCancelled());
      },
    );
    return out.stream;
  }

  /// Calibration (05-engine §9): 2 s from the start position, then 1 s on
  /// each of [calibrationFens]. Low priority.
  Future<CalibrationResult> calibrate({
    Duration long = const Duration(seconds: 2),
    Duration short = const Duration(seconds: 1),
  }) => _enqueue(
    _FnJob<CalibrationResult>(_Priority.low, 'calibration', (
      job,
      engine,
    ) async {
      SearchInfo? last;
      await job.searchUntilDone(
        engine,
        SearchRequest(fen: calibrationFens.first, limit: MoveTime(long)),
        onInfo: (i) => last = i,
      );
      final depths = <int>[];
      for (final fen in calibrationFens) {
        var depth = 0;
        await job.searchUntilDone(
          engine,
          SearchRequest(fen: fen, limit: MoveTime(short)),
          onInfo: (i) => depth = i.depth > depth ? i.depth : depth,
        );
        depths.add(depth);
      }
      return CalibrationResult(
        nps: last?.nps ?? 0,
        depthAt2s: last?.depth ?? 0,
        depthsAt1s: depths,
      );
    }),
  );

  /// App went to the background: stop the running search (re-queued),
  /// hold the queue, and quit the process after [idleQuitAfter].
  void pause() {
    if (_paused) return;
    _paused = true;
    _current?.preempt();
    _quitTimer?.cancel();
    _quitTimer = Timer(idleQuitAfter, () => unawaited(_quit()));
  }

  /// Back in the foreground: run queued jobs (the process restarts on
  /// demand if it quit).
  void resume() {
    _quitTimer?.cancel();
    _quitTimer = null;
    if (!_paused) return;
    _paused = false;
    unawaited(_pump());
  }

  Future<void> _quit() async {
    final engine = _engine;
    _engine = null;
    if (engine != null) await engine.dispose();
    if (_status.state != EngineState.unavailable) {
      _setState(EngineState.stopped);
    }
  }

  /// Clears an unavailable or error state and starts a fresh process.
  Future<void> restart() async {
    _lastCrash = null;
    await _quit();
    _setStatus(EngineStatus(EngineState.stopped, name: _status.name));
    await warmUp();
  }

  /// Quits the engine and fails pending jobs.
  Future<void> dispose() async {
    _disposed = true;
    _quitTimer?.cancel();
    _current?.cancel();
    for (final job in [..._high, ..._low]) {
      _fail(job, const EngineUnavailable('disposed'));
    }
    _high.clear();
    _low.clear();
    await _quit();
    await _statusController.close();
  }

  static Duration _maxTimeFor(Duration minTime) {
    final scaled = minTime * 2.5;
    const floor = Duration(milliseconds: 2500);
    return scaled > floor ? scaled : floor;
  }
}

/// Cancels a [EngineService.topLines] job.
final class EngineCancelToken {
  _Job<Object?>? _job;
  bool _cancelled = false;

  void _attach(_Job<Object?> job) {
    _job = job;
    if (_cancelled) job.cancel();
  }

  /// Cancels the job (its future completes with [EngineJobCancelled]).
  void cancel() {
    _cancelled = true;
    _job?.cancel();
  }
}
