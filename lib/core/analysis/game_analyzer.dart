import 'dart:async';
import 'dart:collection';
import 'dart:isolate';
import 'dart:math' as math;

import 'package:chess_core/chess_core.dart';
import 'package:drift/drift.dart';
import 'package:logging/logging.dart';
import 'package:repertoire_trainer/core/db/app_database.dart';
import 'package:repertoire_trainer/core/db/repositories/games_repository.dart';
import 'package:uci_engine/uci_engine.dart';

final _log = Logger('analysis');

/// Analysis tiers (ordered-todo.md §1b). Labels depend only on the
/// profile: fixed depth, one thread, hash cleared per position.
enum AnalysisProfile {
  /// Opens first: the graph, accuracy and ordinary labels; Brilliant is
  /// provisional and Great waits for Standard.
  quick(12, Duration(seconds: 3), secondPass: false),

  /// Refines in the background, with the MultiPV pass.
  standard(18, Duration(seconds: 10), secondPass: true),

  /// On request.
  deep(22, Duration(seconds: 30), secondPass: true);

  new(this.depth, this.cap, {required this.secondPass});

  /// Search depth.
  final int depth;

  /// Safety-net time per position; a capped position is flagged.
  final Duration cap;

  /// Runs the MultiPV 2 pass on Brilliant/Great candidates.
  final bool secondPass;
}

/// What to analyse.
final class AnalysisRequest {
  /// Creates the request.
  const new({
    required this.gameId,
    required this.ucis,
    this.book = const {},
    this.profiles = const [AnalysisProfile.quick, AnalysisProfile.standard],
  });

  /// `imported_games.id`.
  final String gameId;

  /// Mainline moves.
  final List<String> ucis;

  /// Book plies (1-based).
  final Set<int> book;

  /// Tiers, in order.
  final List<AnalysisProfile> profiles;
}

/// Progress of one tier.
final class AnalysisProgress {
  /// Creates the progress.
  const new(this.profile, this.done, this.total, {this.complete = false});

  /// The tier.
  final AnalysisProfile profile;

  /// Searches finished and in total (both passes).
  final int done;

  /// See [done].
  final int total;

  /// The tier's labels and summary are stored.
  final bool complete;
}

/// Worker count: `min(cores / 2, 4)`, at least 1.
int defaultWorkers(int cores) => (cores ~/ 2).clamp(1, 4);

/// Analyses games with a pool of single-thread engine processes, one
/// position per process at a time (positions are independent: hash
/// cleared, fixed depth). Every finished position is stored at once, so
/// a killed app resumes where it stopped; results are cached by game,
/// profile and engine. Jobs run one after another. [hold] pauses all
/// searches (a drill is open); the worker count drops when the measured
/// speed sags (thermal throttling).
final class GameAnalyzer {
  /// Creates the analyzer; [launch] starts one engine process.
  new({
    required this.launch,
    required this.store,
    required this.workers,
    required this.clock,
    this.hashMb = 16,
  });

  /// Time for the summaries' `updatedAt`.
  final Clock clock;

  /// Starts an engine process.
  final Future<UciTransport> Function() launch;

  /// Where results go.
  final GamesRepository store;

  /// Maximum parallel engines.
  final int workers;

  /// Hash per engine.
  final int hashMb;

  final _pool = <_Worker>[];
  var _active = 0;
  Future<void> _tail = Future.value();
  var _holds = 0;
  Completer<void>? _released;
  final _nps = Queue<int>();
  int? _baselineNps;
  var _limit = 0;

  /// Pauses analysis until the returned callback is called (idempotent).
  void Function() hold() {
    _holds++;
    for (final w in _pool) {
      w.interrupt();
    }
    var released = false;
    return () {
      if (released) return;
      released = true;
      if (--_holds == 0) {
        _released?.complete();
        _released = null;
      }
    };
  }

  /// Whether analysis is paused.
  bool get held => _holds > 0;

  /// Analyses [request]'s tiers in order, emitting progress; queued
  /// behind earlier jobs. Cancel the subscription to stop (stored
  /// positions are kept).
  Stream<AnalysisProgress> analyse(AnalysisRequest request) {
    late final StreamController<AnalysisProgress> out;
    var cancelled = false;
    out = StreamController<AnalysisProgress>(
      onListen: () {
        final job = _tail.then((_) async {
          try {
            await _run(request, out, () => cancelled);
          } on Object catch (e, st) {
            if (!out.isClosed) out.addError(e, st);
          } finally {
            await _shrinkPool(0);
            if (!out.isClosed) await out.close();
          }
        });
        _tail = job.then((_) {}, onError: (Object _) {});
      },
      onCancel: () {
        cancelled = true;
        for (final w in _pool) {
          w.interrupt();
        }
      },
    );
    return out.stream;
  }

  Future<void> _run(
    AnalysisRequest request,
    StreamController<AnalysisProgress> out,
    bool Function() cancelled,
  ) async {
    final game = await _replay(request.ucis);
    final first = await _ensureWorkers(1);
    final engineName = first.first.name;
    for (final profile in request.profiles) {
      if (cancelled()) return;
      await _runProfile(game, request, profile, engineName, out, cancelled);
    }
  }

  Future<void> _runProfile(
    ReviewedGame game,
    AnalysisRequest request,
    AnalysisProfile profile,
    String engineName,
    StreamController<AnalysisProgress> out,
    bool Function() cancelled,
  ) async {
    final id = request.gameId;
    final p = profile.index;
    final existing = await store.review(id, p);
    if (existing != null && existing.engine != engineName) {
      await store.clearAnalysis(id, p);
    } else if (existing?.complete ?? false) {
      out.add(
        AnalysisProgress(
          profile,
          existing!.total,
          existing.total,
          complete: true,
        ),
      );
      return;
    }
    final rows = {for (final r in await store.positions(id, p)) r.ply: r};
    final analyses = List<PositionAnalysis?>.filled(game.length + 1, null);
    rows.forEach((ply, r) => analyses[ply] = analysisFromRow(r));
    // Game-ending positions are scored from the board.
    for (var i = 0; i <= game.length; i++) {
      if (game.isTerminal(i) && analyses[i] == null) {
        analyses[i] = PositionAnalysis(score: game.terminalScore(i));
        await store.savePosition(
          _row(id, p, i, analyses[i]!, 0, capped: false),
        );
      }
    }
    final needed = game.positionsToAnalyse(book: request.book);
    final todo = [
      for (final i in needed)
        if (analyses[i] == null) i,
    ];
    var done = needed.length - todo.length;
    var total = needed.length;
    Future<void> summary({required bool complete}) => store.saveReview(
      GameReviewsCompanion.insert(
        gameId: id,
        profile: p,
        engine: engineName,
        analysed: done,
        total: total,
        complete: complete,
        updatedAt: clock.now().millisecondsSinceEpoch,
      ),
    );
    await summary(complete: false);
    out.add(AnalysisProgress(profile, done, total));
    await _parallel(todo, cancelled, (w, i) async {
      final r = await w.search(game.fen(i), profile, multiPv: 1);
      if (r == null) return false;
      final white = game.fen(i).split(' ')[1] == 'w';
      final a = PositionAnalysis(
        score: _white(r.lines.first.score, white),
        pv: r.lines.first.pv,
      );
      analyses[i] = a;
      await store.savePosition(_row(id, p, i, a, r.depth, capped: r.capped));
      _recordNps(r.nps);
      done++;
      out.add(AnalysisProgress(profile, done, total));
      return true;
    });
    if (cancelled()) return;
    if (profile.secondPass) {
      final candidates = game.secondPassCandidates(
        analyses,
        book: request.book,
      );
      final pass2 = [
        for (final i in candidates)
          if (analyses[i]!.second == null) i,
      ];
      total += candidates.length;
      done += candidates.length - pass2.length;
      out.add(AnalysisProgress(profile, done, total));
      await _parallel(pass2, cancelled, (w, i) async {
        final r = await w.search(game.fen(i), profile, multiPv: 2);
        if (r == null) return false;
        if (r.lines.length > 1) {
          final white = game.fen(i).split(' ')[1] == 'w';
          final s = _white(r.lines[1].score, white);
          analyses[i] = PositionAnalysis(
            score: analyses[i]!.score,
            pv: analyses[i]!.pv,
            second: s,
          );
          await store.saveSecond(id, p, i, cp: s.cp, mate: s.mate);
        }
        done++;
        out.add(AnalysisProgress(profile, done, total));
        return true;
      });
      if (cancelled()) return;
    }
    final review = await _review(
      game,
      analyses,
      request.book,
      secondPass: profile.secondPass,
    );
    await store.completeReview(
      GameReviewsCompanion.insert(
        gameId: id,
        profile: p,
        engine: engineName,
        analysed: done,
        total: total,
        complete: true,
        whiteAccuracy: Value(review.whiteAccuracy),
        blackAccuracy: Value(review.blackAccuracy),
        whitePerformance: Value(review.whitePerformance),
        blackPerformance: Value(review.blackPerformance),
        updatedAt: clock.now().millisecondsSinceEpoch,
      ),
      [for (final l in review.labels) l?.index],
    );
    out.add(AnalysisProgress(profile, done, total, complete: true));
  }

  /// Runs [task] for every item on the pool; a task that returns false
  /// (interrupted by [hold]) is retried after the hold ends.
  Future<void> _parallel(
    List<int> items,
    bool Function() cancelled,
    Future<bool> Function(_Worker w, int item) task, {
    bool retry = false,
  }) async {
    final queue = Queue<int>.of(items);
    if (queue.isEmpty) return;
    _limit = _limit == 0 ? workers : _limit;
    final pool = await _ensureWorkers(math.min(_limit, queue.length));
    Future<void> loop(_Worker w) async {
      while (queue.isNotEmpty && !cancelled() && !w.retired) {
        if (held) {
          await (_released ??= Completer<void>()).future;
          continue;
        }
        final item = queue.removeFirst();
        w.resume();
        bool ok;
        try {
          ok = await task(w, item);
        } on EngineFailure catch (e) {
          _log.warning('worker failed: $e');
          w.retired = true;
          queue.addFirst(item);
          break;
        }
        if (!ok) queue.addFirst(item);
      }
    }

    await Future.wait([for (final w in pool) loop(w)]);
    if (!cancelled() && queue.isNotEmpty) {
      // Every worker failed or retired: one fresh engine finishes the job.
      if (retry) throw const EngineFailure('analysis engine keeps failing');
      _limit = 1;
      await _parallel(queue.toList(), cancelled, task, retry: true);
    }
  }

  void _recordNps(int? nps) {
    if (nps == null || nps <= 0) return;
    _nps.addLast(nps);
    if (_nps.length > 6) _nps.removeFirst();
    if (_nps.length < 4) return;
    final avg = _nps.reduce((a, b) => a + b) / _nps.length;
    final base = _baselineNps ??= avg.round();
    if (avg < base * 0.6 && _active > 1) {
      _log.info('nps $avg below 60 % of $base: one engine fewer');
      _limit = _active - 1;
      _pool.lastWhere((w) => !w.retired).retired = true;
      _active--;
      _nps.clear();
      _baselineNps = null;
    }
  }

  Future<List<_Worker>> _ensureWorkers(int n) async {
    _pool.removeWhere((w) {
      if (w.retired) unawaited(w.dispose());
      return w.retired;
    });
    while (_pool.length < n) {
      final w = _Worker(await launch());
      await w.start(hashMb);
      _pool.add(w);
    }
    _active = _pool.length;
    return _pool.take(n).toList();
  }

  // Engines are released between jobs; the next job starts them again.
  Future<void> _shrinkPool(int n) async {
    while (_pool.length > n) {
      await _pool.removeLast().dispose();
    }
    _active = _pool.length;
    _limit = 0;
  }

  /// Stops every engine.
  Future<void> dispose() => _shrinkPool(0);
}

// Isolate entry points are top-level so their closures capture only
// their arguments.
Future<ReviewedGame> _replay(List<String> ucis) =>
    Isolate.run(() => ReviewedGame.of(ucis));

Future<GameReview> _review(
  ReviewedGame game,
  List<PositionAnalysis?> analyses,
  Set<int> book, {
  required bool secondPass,
}) => Isolate.run(
  () => game.review(analyses, book: book, secondPass: secondPass),
);

EvalScore _white(EngineScore s, bool whiteToMove) {
  final mate = s.mate;
  if (mate != null) return EvalScore(mate: whiteToMove ? mate : -mate);
  return EvalScore(cp: whiteToMove ? s.cp : -s.cp!);
}

/// A stored position row as an analysis (null until scored).
PositionAnalysis? analysisFromRow(DbGameAnalysis r) {
  if (r.cp == null && r.mate == null) return null;
  final second = r.secondCp != null || r.secondMate != null
      ? EvalScore(cp: r.secondCp, mate: r.secondMate)
      : null;
  return PositionAnalysis(
    score: EvalScore(cp: r.cp, mate: r.mate),
    pv: r.pv == null || r.pv!.isEmpty ? const [] : r.pv!.split(' '),
    second: second,
  );
}

GameAnalysisCompanion _row(
  String id,
  int profile,
  int ply,
  PositionAnalysis a,
  int depth, {
  required bool capped,
}) => GameAnalysisCompanion.insert(
  gameId: id,
  profile: profile,
  ply: ply,
  cp: Value(a.score.cp),
  mate: Value(a.score.mate),
  pv: Value(a.pv.take(10).join(' ')),
  depth: depth,
  capped: Value(capped),
);

/// One search result.
final class _Result {
  const new(this.lines, this.depth, {required this.capped, this.nps});

  final List<SearchInfo> lines;
  final int depth;
  final bool capped;
  final int? nps;
}

final class _Worker {
  new(this._transport);

  final UciTransport _transport;
  late final UciEngine _engine = UciEngine(_transport);
  UciSearch? _search;
  bool _interrupted = false;

  /// Leaves the pool after its current search.
  bool retired = false;

  String get name => _engine.name ?? 'engine';

  Future<void> start(int hashMb) =>
      _engine.start(options: {'Threads': 1, 'Hash': hashMb});

  /// Clears an earlier [interrupt] before the next search.
  void resume() => _interrupted = false;

  /// Stops the current search; its result is dropped.
  void interrupt() {
    _interrupted = true;
    unawaited(_search?.stop().then((_) {}, onError: (Object _) {}));
  }

  /// Searches [fen] to the profile's depth; null when interrupted.
  Future<_Result?> search(
    String fen,
    AnalysisProfile profile, {
    required int multiPv,
  }) async {
    await _engine.newGame();
    final s = _search = await _engine.search(
      SearchRequest(fen: fen, limit: Depth(profile.depth), multiPv: multiPv),
    );
    if (_interrupted) unawaited(s.stop().then((_) {}, onError: (Object _) {}));
    final infos = <SearchInfo>[];
    final sub = s.infos.listen((i) {
      if (!i.bound && i.pv.isNotEmpty) infos.add(i);
    });
    var capped = false;
    final timer = Timer(profile.cap, () {
      capped = true;
      unawaited(s.stop().then((_) {}, onError: (Object _) {}));
    });
    try {
      await s.done;
    } finally {
      timer.cancel();
      unawaited(sub.cancel());
      _search = null;
    }
    if (_interrupted) return null;
    final lines = lastCompleteIteration(infos, multiPv);
    if (lines.isEmpty) throw EngineFailure('no line for $fen');
    return _Result(
      lines,
      lines.first.depth,
      capped: capped && lines.first.depth < profile.depth,
      nps: infos.last.nps,
    );
  }

  Future<void> dispose() => _engine.dispose();
}
