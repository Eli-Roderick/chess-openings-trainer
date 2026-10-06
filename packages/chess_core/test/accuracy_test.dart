import 'package:chess_core/chess_core.dart';
import 'package:test/test.dart';

import 'training_helpers.dart';

void main() {
  List<RunRecord> runs(List<double> creditSums, {int graded = 10}) => [
    for (final (i, c) in creditSums.indexed)
      scoredRun(id: 'r$i', creditSum: c, graded: graded, finishedAt: i),
  ];

  group('line accuracy (§2.2)', () {
    test('null without runs', () {
      expect(lineAccuracy(const []), isNull);
    });

    test('move-weighted over runs of different length', () {
      final r = [
        scoredRun(creditSum: 2, graded: 2),
        scoredRun(creditSum: 4, graded: 8, id: 'b', finishedAt: 1),
      ];
      expect(lineAccuracy(r), 0.6);
    });

    test('window boundary: exactly 10 runs count, the 11th oldest drops', () {
      final ten = runs([0, ...List.filled(9, 10)]);
      expect(lineAccuracy(ten), 0.9);
      final eleven = runs([0, 0, ...List.filled(9, 10)]);
      // Only the last 10 count: one 0 and nine perfect runs.
      expect(lineAccuracy(eleven), 0.9);
      final twelve = runs([0, 0, 10, ...List.filled(9, 10)]);
      expect(lineAccuracy(twelve), 1.0);
    });
  });

  test('eligibility: abandoned and ungraded runs are excluded, deviated '
      'runs count (§2.1)', () {
    expect(scoredRun(creditSum: 5, completed: false).isEligible, isFalse);
    expect(scoredRun(creditSum: 0, graded: 0).isEligible, isFalse);
    expect(scoredRun(creditSum: 5, deviated: true).isEligible, isTrue);
  });

  test('compareRuns orders by finishedAt, then id', () {
    final list = [
      scoredRun(creditSum: 1, id: 'b', finishedAt: 5),
      scoredRun(creditSum: 1, id: 'a', finishedAt: 5),
      scoredRun(creditSum: 1, id: 'c', finishedAt: 1),
    ]..sort(compareRuns);
    expect([for (final r in list) r.id], ['c', 'a', 'b']);
  });

  test('overall accuracy is the mean of non-null line accuracies (§2.3)', () {
    expect(overallAccuracy([0.5, null, 1.0]), 0.75);
    expect(overallAccuracy([null, null]), isNull);
    expect(overallAccuracy(const []), isNull);
  });

  test('daily accuracy pools eligible runs per day (§2.4)', () {
    final daily = dailyAccuracy([
      scoredRun(creditSum: 5),
      scoredRun(creditSum: 10, id: 'b'),
      scoredRun(creditSum: 2, graded: 4, day: '2026-01-02', id: 'c'),
      scoredRun(creditSum: 0, day: '2026-01-02', id: 'd', completed: false),
    ]);
    expect(daily, {'2026-01-01': 0.75, '2026-01-02': 0.5});
  });

  test('percent rounds half up', () {
    expect(accuracyPercent(0.845), 85);
    expect(accuracyPercent(0.8449), 84);
    expect(accuracyPercent(0.995), 100);
    expect(accuracyPercent(0.005), 1);
    expect(accuracyPercent(0), 0);
    expect(accuracyPercent(1), 100);
    expect(accuracyPercent(2 / 3), 67);
  });
}
