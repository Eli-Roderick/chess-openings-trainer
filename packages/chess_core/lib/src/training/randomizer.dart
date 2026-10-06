import 'dart:math' as math;

import 'package:chess_core/src/training/constants.dart';
import 'package:chess_core/src/training/run.dart';
import 'package:chess_core/src/util/rng.dart';
import 'package:meta/meta.dart';

/// A line as seen by the pickers (docs/plan/04-algorithms.md §3).
@immutable
final class PickCandidate {
  /// Creates a candidate.
  const new({
    required this.key,
    required this.ordinal,
    this.userMoveCount = 1,
    this.lastPlayedAt,
    this.accuracy,
  });

  /// Line key.
  final String key;

  /// PGN preorder position (sampling order).
  final int ordinal;

  /// Moves by the repertoire's side; lines with 0 are never picked.
  final int userMoveCount;

  /// Latest `finishedAt` of an eligible run (direct or inherited), or null.
  final int? lastPlayedAt;

  /// Line accuracy, or null if never played.
  final double? accuracy;
}

/// Pick weight of a line at [nowMs] (§3.1): `(0.25 + R) * W` with recency
/// `R` saturating after 7 days and `W = 1 + 3 * (1 - accuracy)`.
double lineWeight({required int nowMs, int? lastPlayedAt, double? accuracy}) {
  final hours = lastPlayedAt == null
      ? recencySaturationHours.toDouble()
      : math.min(
          recencySaturationHours.toDouble(),
          math.max(0, nowMs - lastPlayedAt) / 3600000,
        );
  final r = hours / recencySaturationHours;
  final acc = accuracy ?? unknownAccuracy;
  return (recencyBase + r) * (1 + accuracyWeightFactor * (1 - acc));
}

/// Keys excluded because they were started most recently (§3.2): the first
/// `min(3, lineCount - 1)` distinct keys of [recentNewestFirst].
Set<String> recentExclusion(Iterable<String> recentNewestFirst, int lineCount) {
  final k = math.min(maxRecentExclusion, lineCount - 1);
  final out = <String>{};
  for (final key in recentNewestFirst) {
    if (out.length >= k) break;
    out.add(key);
  }
  return out;
}

/// Samples one key from [weighted] (in ordinal order) proportionally to its
/// weight (§3.3). Returns null when the list is empty or all weights are 0.
String? sampleWeighted(List<(String, double)> weighted, Rng rng) {
  final total = weighted.fold<double>(0, (s, e) => s + e.$2);
  if (total <= 0) return null;
  final x = rng.nextDouble() * total;
  var cum = 0.0;
  for (final (key, w) in weighted) {
    cum += w;
    if (cum > x) return key;
  }
  // Floating-point rounding: fall back to the last positive weight.
  return weighted.lastWhere((e) => e.$2 > 0).$1;
}

List<PickCandidate> _trainable(Iterable<PickCandidate> lines) => [
  for (final l in lines)
    if (l.userMoveCount > 0) l,
]..sort((a, b) => a.ordinal.compareTo(b.ordinal));

String? _pick(
  List<PickCandidate> lines, {
  required Set<String> excluded,
  required int nowMs,
  required Rng rng,
}) {
  if (lines.isEmpty) return null;
  if (lines.length == 1) return lines.single.key;
  return sampleWeighted([
    for (final l in lines)
      (
        l.key,
        excluded.contains(l.key)
            ? 0.0
            : lineWeight(
                nowMs: nowMs,
                lastPlayedAt: l.lastPlayedAt,
                accuracy: l.accuracy,
              ),
      ),
  ], rng);
}

/// Random mode (§3): weighted pick over trainable [lines], excluding the
/// most recently started ones. Null if no line is trainable.
String? pickRandomLine({
  required Iterable<PickCandidate> lines,
  required Iterable<String> recentNewestFirst,
  required int nowMs,
  required Rng rng,
}) {
  final pool = _trainable(lines);
  return _pick(
    pool,
    excluded: recentExclusion(recentNewestFirst, pool.length),
    nowMs: nowMs,
    rng: rng,
  );
}

/// Weak mode (§4): the Random rule restricted to [weakPool], with exclusion
/// `min(3, poolSize - 1)` over the recently started *pool* lines. Null when
/// the pool is empty ("No weak lines").
String? pickWeakLine({
  required Iterable<PickCandidate> lines,
  required Set<String> weakPool,
  required Iterable<String> recentNewestFirst,
  required int nowMs,
  required Rng rng,
}) {
  final pool = [
    for (final l in _trainable(lines))
      if (weakPool.contains(l.key)) l,
  ];
  return _pick(
    pool,
    // Only pool lines take up exclusion slots (D-44).
    excluded: recentExclusion(
      recentNewestFirst.where(weakPool.contains),
      pool.length,
    ),
    nowMs: nowMs,
    rng: rng,
  );
}

/// Branch switch (§3.4): the user played another repertoire move; pick the
/// continuation among [candidates] (the lines through the new child) with
/// the active [mode]'s rule and no exclusion. Weak mode prefers [weakPool]
/// lines, SRS mode prefers [srsDue] lines; otherwise the Random weights.
String? pickBranchSwitch({
  required RunMode mode,
  required Iterable<PickCandidate> candidates,
  required int nowMs,
  required Rng rng,
  Set<String> weakPool = const {},
  Set<String> srsDue = const {},
}) {
  final all = _trainable(candidates);
  final preferred = switch (mode) {
    RunMode.weak => weakPool,
    RunMode.srs => srsDue,
    RunMode.random || RunMode.single => const <String>{},
  };
  final first = [
    for (final l in all)
      if (preferred.contains(l.key)) l,
  ];
  return _pick(
    first.isNotEmpty ? first : all,
    excluded: const {},
    nowMs: nowMs,
    rng: rng,
  );
}
