import 'dart:async';
import 'dart:math' as math;

import 'package:chess_core/chess_core.dart';
import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart' hide File;
import 'package:flutter/foundation.dart';
import 'package:repertoire_trainer/core/audio/sound_service.dart';
import 'package:repertoire_trainer/core/diagnostics/drill_latency.dart';
import 'package:repertoire_trainer/core/haptics/haptics_service.dart';
import 'package:repertoire_trainer/core/settings/app_settings.dart';
import 'package:repertoire_trainer/features/board/board_appearance.dart';
import 'package:repertoire_trainer/features/board/board_position.dart';
import 'package:repertoire_trainer/features/board/repertoire_board.dart';
import 'package:repertoire_trainer/features/drill/drill_state.dart';
import 'package:repertoire_trainer/features/drill/line_picker.dart';

/// Comparable checks for wrong moves (the app's `EngineJudge`; a fake in
/// tests).
typedef ComparableCheck = Future<ComparableOutcome> Function({
  required String fen,
  required String userUci,
  required List<String> accepted,
});

/// Sounds, haptics and the board's error flash.
abstract interface class DrillEffects {
  /// Plays [type].
  void sound(SoundType type);

  /// Haptic pulse.
  void haptic(HapticKind kind);

  /// Flashes [square] red for 300 ms; completes when done.
  Future<void> flash(Square square);
}

/// What the controller needs from the app.
final class DrillDeps {
  /// Creates the dependencies.
  const new({
    required this.clock,
    required this.rng,
    required this.newId,
    required this.deviceId,
    required this.settings,
    required this.lineStats,
    required this.recentStarted,
    required this.recordRun,
    required this.check,
    required this.effects,
    this.latency,
    this.reviewsToday,
  });

  /// Time.
  final Clock clock;

  /// Randomness (line picks).
  final Rng rng;

  /// New run ids.
  final String Function() newId;

  /// This device.
  final String deviceId;

  /// Current settings.
  final AppSettings Function() settings;

  /// Derived stats of the repertoire's lines.
  final Future<List<LineStats>> Function() lineStats;

  /// Line keys of the most recently started runs (newest first).
  final Future<List<String>> Function() recentStarted;

  /// Stores a finished or abandoned run (and updates stats).
  final Future<void> Function(RunRecord run) recordRun;

  /// Comparable check.
  final ComparableCheck check;

  /// Effects.
  final DrillEffects effects;

  /// Latency recorder.
  final DrillLatency? latency;

  /// SRS reviews done on a training day, all repertoires (SRS daily cap).
  final Future<int> Function(String day)? reviewsToday;
}

/// The drill (docs/plan/phases/P07, 01-product-spec §7) for one repertoire
/// in Random mode. Every timer and async callback carries the run token it
/// was created for and does nothing once the run has changed.
final class DrillController extends ChangeNotifier {
  /// Creates the controller; call [start].
  new({
    required this.tree,
    required this.repertoireId,
    required this.deps,
    this.picker = const RandomPicker(),
    bool? startFromBranch,
  }) : _startFromBranch =
           startFromBranch ?? deps.settings().startFromBranchPoint,
       _state = DrillState(
         phase: DrillPhase.loading,
         board: BoardViewState(fen: tree.root.fen, orientation: tree.userSide),
       );

  /// The repertoire.
  final RepertoireTree tree;

  /// Its id.
  final String repertoireId;

  /// Dependencies.
  final DrillDeps deps;

  /// Chooses the lines (and so the mode).
  final LinePicker picker;

  /// Training mode.
  RunMode get mode => picker.mode;

  final bool _startFromBranch;
  DrillState _state;
  Side _orientation = Side.white;
  bool _flipped = false;
  bool _disposed = false;

  RunBuilder? _run;
  Line? _line;
  TreeNode? _node;
  int _token = 0;
  final _sessionStarts = <String>[];
  Map<String, LineStats> _statsByKey = const {};
  final _pendingChecks = <Future<void>>[];
  Timer? _opponentTimer;
  Timer? _autoAdvanceTimer;
  Timer? _bannerTimer;
  int _bannerId = 0;
  int? _userMoveAtMs;
  Future<void>? _saving;

  /// The current state.
  DrillState get state => _state;

  void _emit(DrillState next) {
    if (_disposed) return;
    var s = next;
    final line = s.line;
    final node = s.node;
    if (line != null && node != null) {
      bool counts(TreeNode n) => n.isUserMove && n.ply > next.startPly;
      s = s.copyWith(
        userMovesDone: line.path
            .where((n) => counts(n) && n.ply <= node.ply)
            .length,
        userMovesTotal: line.path.where(counts).length,
      );
    }
    _state = s;
    notifyListeners();
  }

  AppSettings get _settings => deps.settings();

  int get _nowMs => deps.clock.now().millisecondsSinceEpoch;

  bool get _isUserSideToMove {
    final next = _nextNode;
    return next != null && next.isUserMove;
  }

  TreeNode? get _nextNode {
    final line = _line;
    final node = _node;
    if (line == null || node == null || node.ply >= line.plies) return null;
    return line.path[node.ply];
  }

  PlayerSide get _userPlayerSide =>
      tree.userSide == Side.white ? PlayerSide.white : PlayerSide.black;

  /// Picks the first line.
  Future<void> start() => _pickAndStart();

  Future<void> _pickAndStart() async {
    final token = ++_token;
    _cancelTimers();
    _emit(
      _state.copyWith(
        phase: DrillPhase.loading,
        clearEndBar: true,
        clearBanner: true,
        summaryOpen: false,
      ),
    );
    // The previous run must be in the stats first (weak pool, SRS).
    final saving = _saving;
    if (saving != null) await saving;
    final context = await _context();
    if (token != _token || _disposed) return;
    final pick = picker.pick(context);
    final count = picker.count(context);
    final line = pick is PickedLine ? tree.lineByKey(pick.key) : null;
    if (line == null) {
      _emit(
        _state.copyWith(
          phase: DrillPhase.empty,
          empty: pick is PickedLine ? const NoTrainableLines() : pick,
          modeCount: count,
        ),
      );
      return;
    }
    _startLine(line, modeCount: count);
  }

  PickContext? _lastContext;

  Future<PickContext> _context() async {
    final stats = await deps.lineStats();
    final recentDb = await deps.recentStarted();
    final today = localDay(deps.clock.now(), _settings.dayStartHour);
    final reviews = mode == RunMode.srs && deps.reviewsToday != null
        ? await deps.reviewsToday!(today)
        : 0;
    _statsByKey = {for (final s in stats) s.lineKey: s};
    return _lastContext = PickContext(
      lines: tree.lines,
      stats: _statsByKey,
      recentNewestFirst: [..._sessionStarts.reversed, ...recentDb],
      nowMs: _nowMs,
      today: today,
      settings: _settings,
      rng: deps.rng,
      sessionPickIndex: _sessionStarts.length,
      reviewsToday: reviews,
    );
  }

  void _startLine(Line line, {int? modeCount}) {
    final startPly = _startFromBranch ? line.branchPly : 0;
    _line = line;
    _node = startPly == 0 ? tree.root : line.path[startPly - 1];
    _sessionStarts.add(line.key);
    _run = RunBuilder(
      id: deps.newId(),
      repertoireId: repertoireId,
      lineKey: line.key,
      ucis: line.ucis,
      mode: mode,
      startPly: startPly,
      wrongMoveMode: _settings.wrongMoveMode,
      startedAt: _nowMs,
      deviceId: deps.deviceId,
    );
    _orientation = _flipped ? tree.userSide.opposite : tree.userSide;
    _emit(
      DrillState(
        phase: DrillPhase.loading,
        board: BoardViewState(
          fen: _node!.fen,
          orientation: _orientation,
          lastMove: _node!.uci == null ? null : parseUci(_node!.uci!),
          animate: false,
        ),
        line: line,
        node: _node,
        startPly: startPly,
        skippedSans: [for (final n in line.path.take(startPly)) n.san!],
        session: _state.session,
        restarts: _state.restarts,
        modeCount: modeCount,
        summary: _state.summary,
      ),
    );
    _continueFromNode(afterUserMove: false, viaDrag: true);
  }

  /// After the board reached [_node]: the opponent moves after the delay,
  /// or it is the user's turn.
  void _continueFromNode({required bool afterUserMove, required bool viaDrag}) {
    if (_node!.ply >= _line!.plies) {
      _completeLine();
      return;
    }
    if (_isUserSideToMove) {
      _emit(
        _state.copyWith(
          phase: DrillPhase.userToMove,
          board: _state.board.copyWith(movable: _userPlayerSide),
          hintLevel: 0,
        ),
      );
      return;
    }
    // The delay counts from the end of the user's move animation; a dropped
    // piece does not animate.
    final s = _settings;
    final animation = afterUserMove && !viaDrag ? s.animationSpeed.ms : 0;
    final delay = Duration(milliseconds: animation + s.opponentMoveDelayMs);
    _emit(
      _state.copyWith(
        phase: DrillPhase.opponentToMove,
        board: _state.board.copyWith(movable: PlayerSide.none),
      ),
    );
    final token = _token;
    _opponentTimer?.cancel();
    _opponentTimer = Timer(delay, () {
      if (token == _token) _playOpponent();
    });
  }

  void _playOpponent() {
    final next = _nextNode!;
    _node = next;
    final userMoveAt = _userMoveAtMs;
    if (userMoveAt != null) {
      deps.latency?.add(Duration(milliseconds: _nowMs - userMoveAt));
      _userMoveAtMs = null;
    }
    deps.effects.sound(SoundType.forSan(next.san!));
    _emit(
      _state.copyWith(
        node: next,
        board: _state.board.copyWith(
          fen: next.fen,
          lastMove: parseUci(next.uci!),
          shapes: const {},
          highlights: const {},
          animate: true,
        ),
        log: [
          ..._state.log,
          MoveLogEntry(ply: next.ply, san: next.san!, isUser: false),
        ],
      ),
    );
    _continueFromNode(afterUserMove: false, viaDrag: true);
  }

  List<String> get _accepted => [
    for (final c in _node!.children)
      if (c.isUserMove) c.uci!,
  ];

  /// The user moved [uci] ([san], position [fenAfter]); [viaDrag] when the
  /// piece was dropped (no move animation). Returns whether it was taken
  /// into account.
  bool onUserMove({
    required String uci,
    required String san,
    required String fenAfter,
    bool viaDrag = false,
  }) {
    if (_state.phase != DrillPhase.userToMove) return false;
    final run = _run!;
    final node = _node!;
    final expected = _nextNode!;
    final ply = expected.ply;
    final accepted = _accepted;
    final grade = run.ply(ply, expected: expected.uci!, accepted: accepted);
    final correct = grade.attempt(uci);
    if (correct) {
      _correctMove(node.children.firstWhere((c) => c.uci == uci), viaDrag);
    } else {
      unawaited(
        _mistake(
          uci: uci,
          san: san,
          fenAfter: fenAfter,
          ply: ply,
          accepted: accepted,
          checkNeeded: grade.moveToCheck == uci,
        ),
      );
    }
    return true;
  }

  void _correctMove(TreeNode child, bool viaDrag) {
    final run = _run!;
    if (!_line!.path.contains(child)) {
      // Alternative repertoire move: continue on a line through it (§3.4).
      final candidates = [
        for (final l in tree.lines)
          if (l.path.contains(child)) l,
      ];
      final context = _lastContext;
      final key = context == null
          ? candidates.first.key
          : picker.branchSwitch(context, candidates) ?? candidates.first.key;
      final line = tree.lineByKey(key)!;
      _line = line;
      run.switchLine(lineKey: line.key, ucis: line.ucis);
    }
    _node = child;
    _userMoveAtMs = _nowMs;
    deps.effects
      ..sound(SoundType.forSan(child.san!))
      ..haptic(HapticKind.light);
    final s = _settings;
    final comment = s.showComments ? child : null;
    final shapes = comment != null && s.showCommentArrows
        ? boardShapes(comment.comment?.shapes ?? const [])
        : const <Shape>{};
    final grade = _gradeOf(child.ply);
    _emit(
      _state.copyWith(
        line: _line,
        node: child,
        comment: comment,
        clearComment: comment == null,
        board: _state.board.copyWith(
          fen: child.fen,
          lastMove: parseUci(child.uci!),
          movable: PlayerSide.none,
          shapes: shapes,
          highlights: const {},
          animate: true,
        ),
        hintLevel: 0,
        log: [
          ..._state.log,
          MoveLogEntry(
            ply: child.ply,
            san: child.san!,
            isUser: true,
            result: grade,
          ),
        ],
      ),
    );
    _refreshScore();
    _continueFromNode(afterUserMove: true, viaDrag: viaDrag);
  }

  GradeResult? _gradeOf(int ply) => _run?.gradeAt(ply)?.result;

  void _refreshScore() {
    final run = _run;
    if (run == null) return;
    final grades = run.grades;
    final graded = grades.length;
    final credit = grades.fold<double>(0, (s, g) => s + g.credit);
    MoveLogEntry regrade(MoveLogEntry e) => MoveLogEntry(
      ply: e.ply,
      san: e.san,
      isUser: e.isUser,
      result: e.isUser ? _gradeOf(e.ply) : null,
    );
    final log = [for (final e in _state.log) regrade(e)];
    _emit(_state.copyWith(graded: graded, creditSum: credit, log: log));
  }

  Future<void> _mistake({
    required String uci,
    required String san,
    required String fenAfter,
    required int ply,
    required List<String> accepted,
    required bool checkNeeded,
  }) async {
    final token = _token;
    final node = _node!;
    final move = parseUci(uci)!;
    deps.effects
      ..sound(SoundType.error)
      ..haptic(HapticKind.medium);
    _emit(
      _state.copyWith(
        phase: DrillPhase.mistake,
        board: _state.board.copyWith(
          fen: fenAfter,
          lastMove: move,
          movable: PlayerSide.none,
          highlights: const {},
          animate: true,
        ),
      ),
    );
    _refreshScore();
    if (checkNeeded) _queueCheck(node.fen, uci, san, ply, accepted);
    await deps.effects.flash(move.to);
    if (token != _token || _disposed) return;
    if (_run!.wrongMoveMode == WrongMoveMode.retry) {
      // Take back: the piece animates home (D-73).
      _emit(
        _state.copyWith(
          phase: DrillPhase.userToMove,
          board: _state.board.copyWith(
            fen: node.fen,
            lastMove: node.uci == null ? null : parseUci(node.uci!),
            movable: _userPlayerSide,
            shapes: const {},
            animate: true,
          ),
        ),
      );
      return;
    }
    // Restart mode: back to the start; graded plies keep their grades.
    _run!.restart();
    final line = _line!;
    final startPly = _run!.startPly;
    _node = startPly == 0 ? tree.root : line.path[startPly - 1];
    _emit(
      _state.copyWith(
        node: _node,
        board: BoardViewState(
          fen: _node!.fen,
          orientation: _orientation,
          lastMove: _node!.uci == null ? null : parseUci(_node!.uci!),
          animate: false,
        ),
        clearComment: true,
        hintLevel: 0,
        log: const [],
        restarts: _state.restarts + 1,
      ),
    );
    _continueFromNode(afterUserMove: false, viaDrag: true);
  }

  void _queueCheck(
    String fen,
    String uci,
    String san,
    int ply,
    List<String> accepted,
  ) {
    final run = _run!;
    final future = deps.check(fen: fen, userUci: uci, accepted: accepted).then((
      outcome,
    ) {
      // Applies to its own run while that is unfinished (a finished
      // run recorded the check as timed out).
      final applied = run.applyCheck(ply, outcome);
      if (!applied || _disposed || !identical(run, _run)) return;
      _refreshScore();
      final movedOn = (_node?.ply ?? 0) >= ply;
      if (outcome.comparable &&
          run.gradeAt(ply)?.result == GradeResult.comparable) {
        _showBanner(
          BannerKind.comparable,
          const Duration(seconds: 4),
          sanPrefix: movedOn ? formatSanMoves([san], firstPly: ply) : null,
        );
      } else if (!outcome.comparable &&
          outcome.status == CheckStatus.ok &&
          !movedOn) {
        _showBanner(BannerKind.notRepertoire, const Duration(seconds: 2));
      }
    }, onError: (Object _) {});
    _pendingChecks.add(future);
    unawaited(future.whenComplete(() => _pendingChecks.remove(future)));
  }

  void _showBanner(BannerKind kind, Duration duration, {String? sanPrefix}) {
    final id = ++_bannerId;
    _emit(_state.copyWith(banner: DrillBanner(id, kind, sanPrefix: sanPrefix)));
    _bannerTimer?.cancel();
    _bannerTimer = Timer(duration, () {
      if (_state.banner?.id == id) _emit(_state.copyWith(clearBanner: true));
    });
  }

  /// Dismisses the banner.
  void dismissBanner() {
    _bannerTimer?.cancel();
    _emit(_state.copyWith(clearBanner: true));
  }

  /// Hint (01 §7.8): level 1 highlights the from-square, level 2 draws the
  /// move. The ply's grade becomes 0.
  void hint() {
    if (_state.phase != DrillPhase.userToMove) return;
    final level = math.min(2, _state.hintLevel + 1);
    final expected = _nextNode!;
    _run!
        .ply(expected.ply, expected: expected.uci!, accepted: _accepted)
        .hint(level);
    final move = parseUci(expected.uci!)!;
    deps.effects.sound(SoundType.hint);
    _emit(
      _state.copyWith(
        hintLevel: level,
        board: _state.board.copyWith(
          highlights: {move.from: hintSquareColor},
          shapes: level >= 2
              ? {
                  Arrow(
                    color: shapeColor(ShapeColor.blue),
                    orig: move.from,
                    dest: move.to,
                  ),
                }
              : const {},
        ),
      ),
    );
    _refreshScore();
  }

  void _completeLine() {
    final run = _run!;
    final finishedAt = _nowMs;
    final before = _statsByKey[run.lineKey];
    deps.effects.sound(SoundType.lineComplete);
    final s = _settings;
    // With "Show line summary" on the summary opens instead of the end bar
    // countdown (01 §7.9).
    final showSummary = s.showLineSummary;
    final auto = Duration(milliseconds: s.autoAdvanceDelayMs);
    _emit(
      _state.copyWith(
        phase: DrillPhase.lineComplete,
        board: _state.board.copyWith(movable: PlayerSide.none),
        endBar: EndBarState(
          graded: _state.graded,
          creditSum: _state.creditSum,
          autoAdvance: auto,
          counting: !showSummary,
          saved: false,
        ),
        clearSummary: true,
        summaryOpen: false,
      ),
    );
    final token = _token;
    _saving = _finalize(run, finishedAt, completed: true).then((record) async {
      LineStats? after;
      try {
        after = (await deps.lineStats())
            .where((l) => l.lineKey == record.lineKey)
            .firstOrNull;
      } on Object {
        after = null;
      }
      if (_disposed) return;
      final current = token == _token;
      final bar = _state.endBar;
      _emit(
        _state.copyWith(
          session: SessionStats(
            linesCompleted: _state.session.linesCompleted + 1,
            graded: _state.session.graded + record.gradedCount,
            creditSum: _state.session.creditSum + record.creditSum,
          ),
          endBar: current && bar != null
              ? EndBarState(
                  graded: record.gradedCount,
                  creditSum: record.creditSum,
                  autoAdvance: bar.autoAdvance,
                  counting: bar.counting,
                  saved: true,
                )
              : null,
          summary: current ? _summary(record, before, after) : null,
          summaryOpen: current && showSummary,
        ),
      );
    });
    if (showSummary) return;
    if (auto == Duration.zero) {
      unawaited(nextLine());
    } else {
      _autoAdvanceTimer = Timer(auto, () {
        if (token == _token) unawaited(nextLine());
      });
    }
  }

  LineSummary _summary(RunRecord run, LineStats? before, LineStats? after) {
    final line = tree.lineByKey(run.lineKey) ?? _line!;
    String? san(TreeNode node, String? uci) {
      if (uci == null || uci == node.uci) return null;
      final move = parseUci(uci);
      final parent = node.parent;
      if (move == null || parent == null) return uci;
      return resolveMove(positionFromFen(parent.fen), move)?.san ?? uci;
    }

    return LineSummary(
      line: line,
      run: run,
      before: before,
      after: after,
      moves: [
        for (final g in run.grades)
          if (g.ply >= 1 && g.ply <= line.plies)
            SummaryMove(
              node: line.path[g.ply - 1],
              grade: g,
              firstAttemptSan: san(line.path[g.ply - 1], g.firstAttempt),
            ),
      ],
    );
  }

  /// Opens the line summary (end bar "Summary").
  void openSummary() {
    if (_state.summary == null) return;
    cancelAutoAdvance();
    _emit(_state.copyWith(summaryOpen: true));
  }

  /// Closes the line summary.
  void closeSummary() => _emit(_state.copyWith(summaryOpen: false));

  /// Waits up to 3 s for the run's pending checks (04 §1), then stores it.
  Future<RunRecord> _finalize(
    RunBuilder run,
    int finishedAt, {
    required bool completed,
  }) async {
    final pending = [..._pendingChecks];
    if (completed && run.pendingChecks.isNotEmpty && pending.isNotEmpty) {
      await Future.any([
        Future.wait(pending),
        Future<void>.delayed(const Duration(seconds: 3)),
      ]);
    }
    final record = run.finish(
      finishedAt: finishedAt,
      localDay: localDay(
        DateTime.fromMillisecondsSinceEpoch(finishedAt),
        _settings.dayStartHour,
      ),
      completed: completed,
    );
    await deps.recordRun(record);
    return record;
  }

  /// Stops the end bar's countdown (any tap on the bar).
  void cancelAutoAdvance() {
    _autoAdvanceTimer?.cancel();
    final bar = _state.endBar;
    if (bar == null || !bar.counting) return;
    _emit(
      _state.copyWith(
        endBar: EndBarState(
          graded: bar.graded,
          creditSum: bar.creditSum,
          autoAdvance: bar.autoAdvance,
          counting: false,
          saved: bar.saved,
        ),
      ),
    );
  }

  /// Next line (end bar, Space/Enter).
  Future<void> nextLine() async {
    if (_state.phase != DrillPhase.lineComplete) return;
    await _pickAndStart();
  }

  /// Skip line: the run is stored as abandoned (01 §7.10).
  Future<void> skipLine() async {
    final run = _run;
    if (run == null || run.isFinished || _state.phase == DrillPhase.loading) {
      return;
    }
    _token++;
    _cancelTimers();
    await _finalize(run, _nowMs, completed: false);
    await _pickAndStart();
  }

  /// Flips the board for this session.
  void flip() {
    _flipped = !_flipped;
    _orientation = _orientation.opposite;
    _emit(
      _state.copyWith(board: _state.board.copyWith(orientation: _orientation)),
    );
  }

  /// Waits until the last completed run has been stored (tests).
  @visibleForTesting
  Future<void> get saved => _saving ?? Future<void>.value();

  void _cancelTimers() {
    _opponentTimer?.cancel();
    _autoAdvanceTimer?.cancel();
    _bannerTimer?.cancel();
  }

  /// Leaves the drill: a run in progress is stored as abandoned.
  Future<void> close() async {
    if (_disposed) return;
    _cancelTimers();
    _token++;
    final run = _run;
    _disposed = true;
    if (run != null && !run.isFinished) {
      await _finalize(run, _nowMs, completed: false);
    }
    await _saving;
  }

  @override
  void dispose() {
    unawaited(close());
    super.dispose();
  }
}
