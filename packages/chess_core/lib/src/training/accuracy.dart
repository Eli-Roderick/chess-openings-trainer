import 'package:chess_core/src/training/constants.dart';
import 'package:chess_core/src/training/run.dart';

/// Orders runs by `finishedAt`, ties by `id` (all derivations use this).
int compareRuns(RunRecord a, RunRecord b) {
  final c = a.finishedAt.compareTo(b.finishedAt);
  return c != 0 ? c : a.id.compareTo(b.id);
}

/// Move-weighted accuracy of [runs]: total credit over total graded moves,
/// or null when nothing was graded.
double? pooledAccuracy(Iterable<RunRecord> runs) {
  var credit = 0.0;
  var graded = 0;
  for (final r in runs) {
    credit += r.creditSum;
    graded += r.gradedCount;
  }
  return graded == 0 ? null : credit / graded;
}

/// Line accuracy (docs/plan/04-algorithms.md §2.2) over the last
/// [accuracyWindow] of [eligibleSorted] (eligible runs of the line, oldest
/// first). Null when there are none.
double? lineAccuracy(List<RunRecord> eligibleSorted) {
  final n = eligibleSorted.length;
  return pooledAccuracy(
    n <= accuracyWindow
        ? eligibleSorted
        : eligibleSorted.sublist(n - accuracyWindow),
  );
}

/// Overall repertoire accuracy (§2.3): the mean of the non-null line
/// accuracies, or null if there are none.
double? overallAccuracy(Iterable<double?> lineAccuracies) {
  final values = lineAccuracies.whereType<double>().toList();
  if (values.isEmpty) return null;
  return values.reduce((a, b) => a + b) / values.length;
}

/// Daily accuracy (§2.4) per `localDay` over the eligible runs in [runs].
Map<String, double> dailyAccuracy(Iterable<RunRecord> runs) {
  final credit = <String, double>{};
  final graded = <String, int>{};
  for (final r in runs.where((r) => r.isEligible)) {
    credit[r.localDay] = (credit[r.localDay] ?? 0) + r.creditSum;
    graded[r.localDay] = (graded[r.localDay] ?? 0) + r.gradedCount;
  }
  return {for (final d in graded.keys) d: credit[d]! / graded[d]!};
}

/// [accuracy] as an integer percent, rounded half up.
int accuracyPercent(double accuracy) =>
    // The epsilon keeps values like 0.845 (0.8449999...) rounding up.
    (accuracy * 100 + 0.5 + 1e-9).floor();
