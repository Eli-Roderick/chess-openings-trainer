import 'package:chess_core/src/training/constants.dart';
import 'package:chess_core/src/training/run.dart';
import 'package:meta/meta.dart';

/// Weak-pool membership of a line (docs/plan/04-algorithms.md §4).
@immutable
final class WeakPoolState {
  /// Creates a state.
  const new({required this.inPool, required this.cleanStreak});

  /// Not in the pool.
  static const outside = WeakPoolState(inPool: false, cleanStreak: 0);

  /// In the weak pool.
  final bool inPool;

  /// Clean runs in a row since entering (0 when outside).
  final int cleanStreak;

  @override
  bool operator ==(Object other) =>
      other is WeakPoolState &&
      other.inPool == inPool &&
      other.cleanStreak == cleanStreak;

  @override
  int get hashCode => Object.hash(inPool, cleanStreak);

  @override
  String toString() => 'WeakPoolState(inPool: $inPool, streak: $cleanStreak)';
}

/// Replays [eligibleSorted] (eligible runs of one line, oldest first).
///
/// A line enters after a non-clean run while its accuracy over the last
/// [accuracyWindow] runs (up to that run) is below [enterBelow], and leaves
/// after [exitCleanRuns] clean runs in a row. A mid-line deviated run with
/// every move perfect is neutral; an imperfect one is not clean.
WeakPoolState replayWeakPool(
  List<RunRecord> eligibleSorted, {
  double enterBelow = defaultWeakEnterBelow,
  int exitCleanRuns = defaultWeakExitCleanRuns,
}) {
  var inPool = false;
  var streak = 0;
  var credit = 0.0;
  var graded = 0;
  for (var i = 0; i < eligibleSorted.length; i++) {
    final run = eligibleSorted[i];
    credit += run.creditSum;
    graded += run.gradedCount;
    if (i >= accuracyWindow) {
      final old = eligibleSorted[i - accuracyWindow];
      credit -= old.creditSum;
      graded -= old.gradedCount;
    }
    final allPerfect = run.allPerfect;
    if (run.deviated && allPerfect) continue;
    final clean = allPerfect && !run.deviated;
    if (inPool) {
      if (clean) {
        streak++;
        if (streak >= exitCleanRuns) {
          inPool = false;
          streak = 0;
        }
      } else {
        streak = 0;
      }
    } else if (!clean && credit / graded < enterBelow) {
      inPool = true;
      streak = 0;
    }
  }
  return WeakPoolState(inPool: inPool, cleanStreak: streak);
}
