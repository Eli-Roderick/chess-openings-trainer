import 'package:chess_core/chess_core.dart';
import 'package:flutter/foundation.dart';

/// A running deviation-candidates search; `cancel` drops it (its result
/// then completes empty).
typedef CandidateJob = ({Future<List<PvMove>> result, void Function() cancel});

/// The engine's judgement of a deviation reply (04 §7.3) with the best
/// move it was measured against.
typedef DeviationJudgement = ({bool passed, int lossCp, String bestUci});

/// What the drill needs from the engine for opponent deviations (P09). The
/// app adapts its `EngineJudge`; tests use fakes.
abstract interface class DeviationEngine {
  /// False when the engine cannot run (no binary, crashed twice): no
  /// deviation is rolled.
  bool get available;

  /// Deviation candidates (04 §7.2) in [fen], opponent to move, excluding
  /// [book] moves. A low-priority job (05 §6).
  CandidateJob candidates(String fen, {Set<String> book});

  /// Judges [replyUci] in [fen] (user to move); null when the engine
  /// failed.
  Future<DeviationJudgement?> judge(String fen, String replyUci);

  /// The best move in [fen] (the hint during a reply); null on failure.
  Future<String?> bestMove(String fen);
}

/// How a challenge started (01-product-spec §8.1).
enum ChallengeKind {
  /// "Anywhere in the line": the opponent left the book mid-line.
  midLine,

  /// End of line after a user leaf: the opponent played on.
  endOpponentPlays,

  /// End of line after an opponent leaf: the user moves directly.
  endFindMove,
}

/// The off-book challenge of the current run, as the screen shows it.
@immutable
final class ChallengeView {
  /// Creates it.
  const new({
    required this.kind,
    this.deviationSan,
    this.judging = false,
    this.passed,
    this.lossCp,
    this.bestSan,
    this.hinted = false,
  });

  /// How it started.
  final ChallengeKind kind;

  /// The opponent's off-book move, if it played one.
  final String? deviationSan;

  /// The reply is being judged.
  final bool judging;

  /// Result once judged (null before, or when the engine failed).
  final bool? passed;

  /// Loss of the reply against the best move.
  final int? lossCp;

  /// The engine's best move when the reply was not it.
  final String? bestSan;

  /// The hint was used (the reply fails).
  final bool hinted;

  /// A copy with the given fields replaced.
  ChallengeView copyWith({
    bool? judging,
    bool? passed,
    int? lossCp,
    String? bestSan,
    bool? hinted,
  }) => ChallengeView(
    kind: kind,
    deviationSan: deviationSan,
    judging: judging ?? this.judging,
    passed: passed ?? this.passed,
    lossCp: lossCp ?? this.lossCp,
    bestSan: bestSan ?? this.bestSan,
    hinted: hinted ?? this.hinted,
  );
}
