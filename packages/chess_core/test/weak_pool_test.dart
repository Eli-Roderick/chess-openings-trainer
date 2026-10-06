import 'package:chess_core/chess_core.dart';
import 'package:test/test.dart';

import 'training_helpers.dart';

/// Builds runs from a compact spec: 'P' perfect, 'p' perfect but deviated,
/// 'd' deviated imperfect, or a credit sum out of 10.
List<RunRecord> spec(List<Object> items) => [
  for (final (i, s) in items.indexed)
    switch (s) {
      'P' => scoredRun(id: 'r$i', creditSum: 10, finishedAt: i),
      'p' => scoredRun(id: 'r$i', creditSum: 10, finishedAt: i, deviated: true),
      'd' => scoredRun(id: 'r$i', creditSum: 5, finishedAt: i, deviated: true),
      final num c => scoredRun(
        id: 'r$i',
        creditSum: c.toDouble(),
        finishedAt: i,
      ),
      _ => throw ArgumentError(s),
    },
];

WeakPoolState replay(List<Object> items, {double enter = 0.8, int exit = 3}) =>
    replayWeakPool(spec(items), enterBelow: enter, exitCleanRuns: exit);

void main() {
  test('no runs: outside', () {
    expect(replayWeakPool(const []), WeakPoolState.outside);
  });

  test('entry at 79 % but not at 80 %', () {
    expect(replay([7.9]).inPool, isTrue);
    expect(replay([8]).inPool, isFalse);
  });

  test('perfect runs never enter, whatever the accuracy', () {
    expect(replay(['P']).inPool, isFalse);
  });

  test('exits after exactly 3 clean runs', () {
    expect(
      replay([5, 'P', 'P']),
      const WeakPoolState(inPool: true, cleanStreak: 2),
    );
    expect(replay([5, 'P', 'P', 'P']), WeakPoolState.outside);
  });

  test('a non-clean run resets the streak', () {
    expect(
      replay([5, 'P', 'P', 9.5, 'P']),
      const WeakPoolState(inPool: true, cleanStreak: 1),
    );
  });

  test('hysteresis: after leaving, old failures in the window do not '
      're-enter without a new non-clean run', () {
    // Accuracy after the third clean run is (0+0+0+10+10+10)/60 = 0.5.
    expect(replay([0, 0, 0, 'P', 'P', 'P']).inPool, isFalse);
    expect(replay([0, 0, 0, 'P', 'P', 'P', 'P']).inPool, isFalse);
    // The next non-clean run re-enters because the window is still low.
    expect(replay([0, 0, 0, 'P', 'P', 'P', 9]).inPool, isTrue);
  });

  test('a deviated perfect run is neutral', () {
    expect(
      replay([5, 'P', 'p', 'P']),
      const WeakPoolState(inPool: true, cleanStreak: 2),
    );
    expect(replay(['p']).inPool, isFalse);
  });

  test('a deviated imperfect run resets the streak and can enter', () {
    expect(
      replay([5, 'P', 'P', 'd']),
      const WeakPoolState(inPool: true, cleanStreak: 0),
    );
    expect(replay(['d']).inPool, isTrue);
  });

  test('changing thresholds re-derives', () {
    final items = <Object>[8.5, 'P'];
    expect(replay(items).inPool, isFalse);
    expect(replay(items, enter: 0.9).inPool, isTrue);
    expect(replay([5, 'P'], exit: 1).inPool, isFalse);
  });

  test('value semantics', () {
    expect(WeakPoolState.outside.hashCode, WeakPoolState.outside.hashCode);
    expect(WeakPoolState.outside.toString(), contains('false'));
  });
}
