import 'package:chess_core/chess_core.dart';
import 'package:flutter/foundation.dart';
import 'package:repertoire_trainer/features/board/free_move.dart';
import 'package:repertoire_trainer/features/board/repertoire_board.dart';
import 'package:repertoire_trainer/features/drill/deviation.dart';
import 'package:repertoire_trainer/features/drill/line_picker.dart';

/// Where the drill is (docs/plan/phases/P07 state machine).
enum DrillPhase {
  /// Picking a line / loading stats.
  loading,

  /// No trainable line in the repertoire.
  empty,

  /// Waiting for the opponent's move.
  opponentToMove,

  /// The user's turn.
  userToMove,

  /// A wrong move is being shown (flash, then take back or restart).
  mistake,

  /// The user replies to an off-book position (any legal move, no take
  /// back; 01-product-spec §8.1).
  deviationReply,

  /// The reply is being judged by the engine.
  judging,

  /// The line was played to its end; the end bar shows.
  lineComplete,
}

/// Kind of banner over the info panel (01-product-spec §7.2, §7.7).
enum BannerKind {
  /// "That is not the move in your repertoire, but it is a comparable
  /// move." (4 s).
  comparable,

  /// "Not your repertoire move" (2 s).
  notRepertoire,
}

/// A banner; [sanPrefix] is set when the user already moved on.
@immutable
final class DrillBanner {
  /// Creates a banner.
  const new(this.id, this.kind, {this.sanPrefix});

  /// Unique per banner (for animations and dismissal).
  final int id;

  /// What it says.
  final BannerKind kind;

  /// The move it is about, when it is no longer the current ply.
  final String? sanPrefix;
}

/// One move of the line so far, for the wide-layout move list.
@immutable
final class MoveLogEntry {
  /// Creates the entry.
  const new({
    required this.ply,
    required this.san,
    required this.isUser,
    this.result,
  });

  /// Ply.
  final int ply;

  /// SAN.
  final String san;

  /// Whether the user played it.
  final bool isUser;

  /// The ply's grade (user moves).
  final GradeResult? result;
}

/// The end bar after a line (01-product-spec §7.9).
@immutable
final class EndBarState {
  /// Creates it.
  const new({
    required this.graded,
    required this.creditSum,
    required this.autoAdvance,
    required this.counting,
    required this.saved,
  });

  /// Graded plies.
  final int graded;

  /// Credit sum.
  final double creditSum;

  /// Auto-advance delay.
  final Duration autoAdvance;

  /// Whether the countdown runs (a tap cancels it).
  final bool counting;

  /// Whether the run has been stored (pending checks resolved or timed out).
  final bool saved;
}

/// Lines completed this session (01-product-spec §7.10).
@immutable
final class SessionStats {
  /// Creates it.
  const new({this.linesCompleted = 0, this.graded = 0, this.creditSum = 0});

  /// Completed lines.
  final int linesCompleted;

  /// Graded plies over completed lines.
  final int graded;

  /// Credit over completed lines.
  final double creditSum;

  /// Session accuracy, null before any graded ply.
  double? get accuracy => graded == 0 ? null : creditSum / graded;
}

/// One graded user move in the line summary (01 §7.9).
@immutable
final class SummaryMove {
  /// Creates it.
  const new({required this.node, required this.grade, this.firstAttemptSan});

  /// The repertoire move (expected move, its comment).
  final TreeNode node;

  /// The grade.
  final MoveGrade grade;

  /// SAN of the user's first attempt when it was not the expected move.
  final String? firstAttemptSan;
}

/// The line summary (01 §7.9) of the last completed run.
@immutable
final class LineSummary {
  /// Creates it.
  const new({
    required this.line,
    required this.run,
    required this.moves,
    this.before,
    this.after,
  });

  /// The completed line.
  final Line line;

  /// The stored run.
  final RunRecord run;

  /// Graded user moves.
  final List<SummaryMove> moves;

  /// Line stats before the run.
  final LineStats? before;

  /// Line stats after the run.
  final LineStats? after;

  /// "Entered weak pool" (true), "Left weak pool" (false), unchanged (null).
  bool? get weakChange {
    final was = before?.inWeakPool ?? false;
    final now = after?.inWeakPool ?? false;
    return was == now ? null : now;
  }
}

/// Everything the drill screen shows.
@immutable
final class DrillState {
  /// Creates a state.
  const new({
    required this.phase,
    required this.board,
    this.line,
    this.node,
    this.startPly = 0,
    this.skippedSans = const [],
    this.hintLevel = 0,
    this.banner,
    this.comment,
    this.userMovesDone = 0,
    this.userMovesTotal = 0,
    this.graded = 0,
    this.creditSum = 0,
    this.log = const [],
    this.endBar,
    this.session = const SessionStats(),
    this.restarts = 0,
    this.empty,
    this.modeCount,
    this.summary,
    this.summaryOpen = false,
    this.challenge,
    this.playOn,
  });

  /// Phase.
  final DrillPhase phase;

  /// Board view.
  final BoardViewState board;

  /// The line being played.
  final Line? line;

  /// The node on the board.
  final TreeNode? node;

  /// Start ply of the run (0 or the branch ply).
  final int startPly;

  /// Moves skipped by a branch-point start (SAN), for the chip.
  final List<String> skippedSans;

  /// Hint level at the current ply (0-2).
  final int hintLevel;

  /// Banner, if any.
  final DrillBanner? banner;

  /// The user move whose comment the info panel shows.
  final TreeNode? comment;

  /// User moves played on this line so far (progress "Move 5 of 9").
  final int userMovesDone;

  /// User moves of the line after the start ply.
  final int userMovesTotal;

  /// Graded plies of this run so far.
  final int graded;

  /// Credit of this run so far.
  final double creditSum;

  /// Moves of this run so far.
  final List<MoveLogEntry> log;

  /// End bar after a completed line.
  final EndBarState? endBar;

  /// Session totals.
  final SessionStats session;

  /// Restart-mode resets so far (the board fades on each).
  final int restarts;

  /// Why there is no line to train ([DrillPhase.empty]).
  final LinePick? empty;

  /// Weak pool size / SRS lines left, for the app bar.
  final int? modeCount;

  /// Summary of the last completed line, once stored.
  final LineSummary? summary;

  /// Whether the summary screen is shown.
  final bool summaryOpen;

  /// The run's off-book challenge, once it started.
  final ChallengeView? challenge;

  /// Where Play on starts, once the line is complete.
  final PlayOnArgs? playOn;

  /// A copy with the given fields replaced.
  DrillState copyWith({
    DrillPhase? phase,
    BoardViewState? board,
    Line? line,
    TreeNode? node,
    int? startPly,
    List<String>? skippedSans,
    int? hintLevel,
    DrillBanner? banner,
    bool clearBanner = false,
    TreeNode? comment,
    bool clearComment = false,
    int? userMovesDone,
    int? userMovesTotal,
    int? graded,
    double? creditSum,
    List<MoveLogEntry>? log,
    EndBarState? endBar,
    bool clearEndBar = false,
    SessionStats? session,
    int? restarts,
    LinePick? empty,
    int? modeCount,
    bool clearModeCount = false,
    LineSummary? summary,
    bool clearSummary = false,
    bool? summaryOpen,
    ChallengeView? challenge,
    bool clearChallenge = false,
    PlayOnArgs? playOn,
    bool clearPlayOn = false,
  }) => DrillState(
    phase: phase ?? this.phase,
    board: board ?? this.board,
    line: line ?? this.line,
    node: node ?? this.node,
    startPly: startPly ?? this.startPly,
    skippedSans: skippedSans ?? this.skippedSans,
    hintLevel: hintLevel ?? this.hintLevel,
    banner: clearBanner ? null : banner ?? this.banner,
    comment: clearComment ? null : comment ?? this.comment,
    userMovesDone: userMovesDone ?? this.userMovesDone,
    userMovesTotal: userMovesTotal ?? this.userMovesTotal,
    graded: graded ?? this.graded,
    creditSum: creditSum ?? this.creditSum,
    log: log ?? this.log,
    endBar: clearEndBar ? null : endBar ?? this.endBar,
    session: session ?? this.session,
    restarts: restarts ?? this.restarts,
    empty: empty ?? this.empty,
    modeCount: clearModeCount ? null : modeCount ?? this.modeCount,
    summary: clearSummary ? null : summary ?? this.summary,
    summaryOpen: summaryOpen ?? this.summaryOpen,
    challenge: clearChallenge ? null : challenge ?? this.challenge,
    playOn: clearPlayOn ? null : playOn ?? this.playOn,
  );
}
