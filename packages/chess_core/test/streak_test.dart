import 'package:chess_core/chess_core.dart';
import 'package:test/test.dart';

import 'training_helpers.dart';

void main() {
  const today = '2026-10-06';

  test('no days', () {
    expect(
      computeStreak(const [], today),
      const Streak(current: 0, best: 0, todayDone: false),
    );
  });

  test('today only', () {
    expect(
      computeStreak([today], today),
      const Streak(current: 1, best: 1, todayDone: true),
    );
  });

  test('yesterday only: alive but not done today', () {
    expect(
      computeStreak(['2026-10-05'], today),
      const Streak(current: 1, best: 1, todayDone: false),
    );
  });

  test('a gap breaks the current streak; best is kept', () {
    final s = computeStreak([
      '2026-09-01',
      '2026-09-02',
      '2026-09-03',
      '2026-10-04',
      '2026-10-06',
    ], today);
    expect(s, const Streak(current: 1, best: 3, todayDone: true));
    expect(computeStreak(['2026-10-04'], today).current, 0);
  });

  test('duplicates and order do not matter; months roll over', () {
    expect(
      computeStreak([
        '2026-10-06',
        '2026-09-30',
        '2026-10-01',
        '2026-10-06',
        '2026-10-02',
        '2026-10-03',
        '2026-10-04',
        '2026-10-05',
      ], today),
      const Streak(current: 7, best: 7, todayDone: true),
    );
  });

  test('day-start boundary: a run at 03:30 with a 04:00 start belongs to the '
      'previous day', () {
    final day = localDay(DateTime(2026, 10, 7, 3, 30), 4);
    expect(computeStreak([day], today).todayDone, isTrue);
  });

  test('from runs: completed runs of any mode count, abandoned do not', () {
    final s = streakFromRuns([
      makeRun(day: today, mode: RunMode.single),
      makeRun(day: '2026-10-05', deviated: true, credits: const [0]),
      makeRun(day: '2026-10-04', completed: false),
    ], today);
    expect(s, const Streak(current: 2, best: 2, todayDone: true));
  });

  test('value semantics', () {
    const s = Streak(current: 1, best: 2, todayDone: false);
    expect(
      s.hashCode,
      const Streak(current: 1, best: 2, todayDone: false).hashCode,
    );
    expect(s.toString(), contains('best 2'));
  });
}
