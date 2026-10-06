import 'package:chess_core/src/training/day_clock.dart';
import 'package:chess_core/src/training/run.dart';
import 'package:meta/meta.dart';

/// Training streak (docs/plan/04-algorithms.md §9).
@immutable
final class Streak {
  /// Creates a streak.
  const new({
    required this.current,
    required this.best,
    required this.todayDone,
  });

  /// Consecutive training days ending today, or yesterday if today is not
  /// done yet.
  final int current;

  /// Longest run of consecutive training days ever.
  final int best;

  /// True if a run was completed today.
  final bool todayDone;

  @override
  bool operator ==(Object other) =>
      other is Streak &&
      other.current == current &&
      other.best == best &&
      other.todayDone == todayDone;

  @override
  int get hashCode => Object.hash(current, best, todayDone);

  @override
  String toString() => 'Streak($current, best $best, today $todayDone)';
}

/// Streak from the set of training [days] (`YYYY-MM-DD`) as of [today].
Streak computeStreak(Iterable<String> days, String today) {
  final set = days.toSet();
  final todayDone = set.contains(today);
  var d = todayDone ? today : addDays(today, -1);
  var current = 0;
  while (set.contains(d)) {
    current++;
    d = addDays(d, -1);
  }
  final sorted = set.toList()..sort();
  var best = 0;
  var run = 0;
  for (var i = 0; i < sorted.length; i++) {
    run = (i > 0 && daysBetween(sorted[i - 1], sorted[i]) == 1) ? run + 1 : 1;
    if (run > best) best = run;
  }
  return Streak(current: current, best: best, todayDone: todayDone);
}

/// Streak from [runs] of all repertoires: a day counts when at least one
/// run was completed on it (any mode, including mid-line deviations).
Streak streakFromRuns(Iterable<RunRecord> runs, String today) => computeStreak([
  for (final r in runs)
    if (r.completed) r.localDay,
], today);
