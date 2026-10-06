import 'package:chess_core/src/training/constants.dart';
import 'package:chess_core/src/util/rng.dart';
import 'package:meta/meta.dart';

/// Engine score in centipawns from the side to move's view
/// (docs/plan/04-algorithms.md §7.1): mate in n → 100000 - n, mated in n →
/// -100000 + n. Exactly one of [cp] and [mate] must be given.
int scoreToCp({int? cp, int? mate}) {
  if ((cp == null) == (mate == null)) {
    throw ArgumentError('give exactly one of cp and mate');
  }
  if (cp != null) return cp;
  final n = mate!;
  return n > 0 ? mateScoreCp - n : -mateScoreCp - n;
}

/// Result of the comparable check (§7.1).
@immutable
final class ComparableJudgement {
  /// Creates a judgement.
  const new({required this.comparable, required this.lossCp});

  /// The user move is good enough for half credit.
  final bool comparable;

  /// Best repertoire score minus the user move's score (≤ 0 if better).
  final int lossCp;
}

/// Decides whether [userMove] is comparable to the best of [accepted],
/// given side-to-move centipawn [scores] for all of them.
ComparableJudgement judgeComparable({
  required Map<String, int> scores,
  required List<String> accepted,
  required String userMove,
  int thresholdCp = defaultComparableThresholdCp,
}) {
  final best = accepted.map((m) => scores[m]!).reduce((a, b) => a > b ? a : b);
  final loss = best - scores[userMove]!;
  return ComparableJudgement(comparable: loss <= thresholdCp, lossCp: loss);
}

/// One principal variation's first move and score (opponent's view, cp).
typedef PvMove = ({String uci, int scoreCp});

/// Deviation candidates (§7.2): PV first moves within [deviationWindowCp]
/// of the best score, excluding the position's repertoire moves.
List<PvMove> deviationCandidates(
  List<PvMove> pvs, {
  Set<String> repertoireMoves = const {},
}) {
  if (pvs.isEmpty) return const [];
  final best = pvs.map((p) => p.scoreCp).reduce((a, b) => a > b ? a : b);
  return [
    for (final p in pvs)
      if (p.scoreCp >= best - deviationWindowCp &&
          !repertoireMoves.contains(p.uci))
        p,
  ];
}

/// Picks a deviation among [candidates], weighted by
/// `101 - (best - score)`. Null when there are none.
String? pickDeviation(List<PvMove> candidates, Rng rng) {
  if (candidates.isEmpty) return null;
  final best = candidates.map((p) => p.scoreCp).reduce((a, b) => a > b ? a : b);
  final weights = [
    for (final p in candidates) deviationWeightBase - (best - p.scoreCp),
  ];
  final total = weights.fold(0, (s, w) => s + w);
  final x = rng.nextDouble() * total;
  var cum = 0.0;
  for (var i = 0; i < candidates.length; i++) {
    cum += weights[i];
    if (cum > x) return candidates[i].uci;
  }
  return candidates.last.uci;
}

/// Judgement of the user's reply to a deviation (§7.3).
@immutable
final class ReplyJudgement {
  /// Creates a judgement.
  const new({required this.passed, required this.lossCp});

  /// The reply loses at most [deviationReplyPassCp].
  final bool passed;

  /// Best score minus the reply's score.
  final int lossCp;
}

/// Judges [replyUci] against the engine's best move: the best move passes
/// with loss 0 (no second search needed, [replyCp] may be null).
ReplyJudgement judgeReply({
  required String bestUci,
  required int bestCp,
  required String replyUci,
  int? replyCp,
}) {
  if (replyUci == bestUci) {
    return const ReplyJudgement(passed: true, lossCp: 0);
  }
  if (replyCp == null) {
    throw ArgumentError.notNull('replyCp');
  }
  final loss = bestCp - replyCp;
  return ReplyJudgement(passed: loss <= deviationReplyPassCp, lossCp: loss);
}
