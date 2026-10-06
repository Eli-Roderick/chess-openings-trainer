import 'package:chess_core/chess_core.dart';
import 'package:test/test.dart';

import 'training_helpers.dart';

SrsState review(String due, {int interval = 4, int reps = 2}) => SrsState(
  phase: SrsPhase.review,
  reps: reps,
  ease: 2.5,
  intervalDays: interval,
  dueDay: due,
  lapses: 0,
  firstSeenDay: '2026-01-01',
);

const learning = SrsState(
  phase: SrsPhase.learning,
  reps: 0,
  ease: 2.3,
  intervalDays: 0,
  dueDay: '2026-01-10',
  lapses: 1,
  firstSeenDay: '2026-01-01',
);

List<LineRef> refs(int n, {Set<int> untrainable = const {}}) => [
  for (var i = 0; i < n; i++)
    LineRef(
      key: 'L$i',
      ucis: 'x$i',
      ordinal: i,
      userMoveCount: untrainable.contains(i) ? 0 : 1,
    ),
];

void main() {
  group('fuzz', () {
    test('values match an independent SHA-256 computation', () {
      // Computed with Python hashlib for key a1b2c3d4e5f60718.
      final expected = [-0.046218, 0.092488, 0.061712, 0.043543, 0.053288];
      for (var reps = 1; reps <= 5; reps++) {
        expect(
          srsFuzz('a1b2c3d4e5f60718', reps),
          closeTo(expected[reps - 1], 1e-6),
        );
      }
    });

    test('deterministic and within [-0.10, 0.10)', () {
      for (var i = 0; i < 5000; i++) {
        final f = srsFuzz('key$i', i % 7);
        expect(f, greaterThanOrEqualTo(-0.1));
        expect(f, lessThan(0.1));
        expect(srsFuzz('key$i', i % 7), f);
      }
    });
  });

  group('state', () {
    test('isDueOn', () {
      expect(SrsState.initial.isDueOn('2026-01-01'), isFalse);
      expect(review('2026-01-05').isDueOn('2026-01-05'), isTrue);
      expect(review('2026-01-05').isDueOn('2026-01-04'), isFalse);
      expect(learning.isDueOn('2026-01-11'), isTrue);
    });

    test('copyWith, equality, toString', () {
      final s = review('2026-01-05');
      expect(s.copyWith(), s);
      expect(s.copyWith().hashCode, s.hashCode);
      expect(s.copyWith(reps: 9).reps, 9);
      expect(
        s.copyWith(
          phase: SrsPhase.learning,
          ease: 2,
          intervalDays: 1,
          dueDay: 'd',
          lapses: 3,
          firstSeenDay: 'f',
        ),
        isNot(s),
      );
      expect(s.toString(), contains('review'));
      expect(SrsPhase.fresh.dbValue, 'new');
    });

    test('90 % passes and 89.x % fails', () {
      final pass = applySrsRun(
        SrsState.initial,
        scoredRun(mode: RunMode.srs, creditSum: 9),
        'k',
      );
      expect(pass.phase, SrsPhase.review);
      final fail = applySrsRun(
        SrsState.initial,
        scoredRun(mode: RunMode.srs, creditSum: 17.5, graded: 20),
        'k',
      );
      expect(fail.phase, SrsPhase.learning);
    });

    test('isSrsReview', () {
      expect(isSrsReview(scoredRun(mode: RunMode.srs, creditSum: 1)), isTrue);
      expect(isSrsReview(scoredRun(creditSum: 1)), isFalse);
    });
  });

  group('picker (§5.5)', () {
    const today = '2026-01-10';

    test('due order: learning first, then overdue ratio, then ordinal', () {
      final states = {
        'L0': review('2026-01-09', interval: 10), // ratio 0.1
        'L1': review('2026-01-08', interval: 2), // ratio 1.0
        'L2': learning,
        'L3': review('2026-01-09', interval: 10), // ratio 0.1, later ordinal
        'L4': review('2026-01-11'), // not due
      };
      expect(
        [for (final l in srsDueOrder(refs(5), states, today)) l.key],
        ['L2', 'L1', 'L0', 'L3'],
      );
    });

    test('interleave: every 4th pick is new when both exist', () {
      final states = {
        for (var i = 0; i < 5; i++) 'L$i': review('2026-01-0${i + 1}'),
      };
      final picks = [
        for (var i = 0; i < 8; i++)
          pickSrs(
            lines: refs(8),
            states: states,
            today: today,
            sessionPickIndex: i,
          ),
      ];
      expect(
        [for (final p in picks) (p as SrsPickLine).isNew],
        [false, false, false, true, false, false, false, true],
      );
      expect((picks[3] as SrsPickLine).key, 'L5');
    });

    test('when one queue runs out the other is used', () {
      final onlyNew = pickSrs(
        lines: refs(2),
        states: const {},
        today: today,
        sessionPickIndex: 0,
      );
      expect(onlyNew, const SrsPickLine('L0', isNew: true));
      final onlyDue = pickSrs(
        lines: refs(1),
        states: {'L0': review('2026-01-01')},
        today: today,
        sessionPickIndex: 3,
      );
      expect(onlyDue, const SrsPickLine('L0', isNew: false));
    });

    test('new lines come in ordinal order, untrainable lines never', () {
      final pick = pickSrs(
        lines: refs(3, untrainable: {0}).reversed.toList(),
        states: const {},
        today: today,
        sessionPickIndex: 0,
      );
      expect(pick, const SrsPickLine('L1', isNew: true));
    });

    test('new-per-day quota counts lines first seen today, and resets the '
        'next day', () {
      final seenToday = {
        'L0': review('2026-01-11', reps: 1).copyWith(firstSeenDay: today),
        'L1': review('2026-01-11', reps: 1).copyWith(firstSeenDay: today),
      };
      expect(
        pickSrs(
          lines: refs(4),
          states: seenToday,
          today: today,
          sessionPickIndex: 0,
          newPerDay: 2,
        ),
        const SrsCaughtUp(nextDueDay: '2026-01-11', dueOnNextDay: 2),
      );
      expect(
        pickSrs(
          lines: refs(4),
          states: seenToday,
          today: today,
          sessionPickIndex: 0,
          newPerDay: 3,
        ),
        const SrsPickLine('L2', isNew: true),
      );
      // Next day: L0 and L1 are due, the quota is fresh again.
      expect(
        pickSrs(
          lines: refs(4),
          states: seenToday,
          today: '2026-01-11',
          sessionPickIndex: 3,
          newPerDay: 2,
        ),
        const SrsPickLine('L2', isNew: true),
      );
    });

    test('excluded lines are skipped when an alternative exists', () {
      final states = {'L0': review('2026-01-01'), 'L1': review('2026-01-02')};
      expect(
        pickSrs(
          lines: refs(2),
          states: states,
          today: today,
          sessionPickIndex: 0,
          excluded: {'L0'},
        ),
        const SrsPickLine('L1', isNew: false),
      );
      // Excluded from the due queue, alternative is a new line.
      expect(
        pickSrs(
          lines: refs(3),
          states: states,
          today: today,
          sessionPickIndex: 0,
          excluded: {'L0', 'L1'},
        ),
        const SrsPickLine('L2', isNew: true),
      );
      // Everything excluded: pick anyway.
      expect(
        pickSrs(
          lines: refs(2),
          states: states,
          today: today,
          sessionPickIndex: 0,
          excluded: {'L0', 'L1'},
        ),
        const SrsPickLine('L0', isNew: false),
      );
      expect(
        pickSrs(
          lines: refs(1),
          states: const {},
          today: today,
          sessionPickIndex: 0,
          excluded: {'L0'},
        ),
        const SrsPickLine('L0', isNew: true),
      );
    });

    test('daily review limit', () {
      expect(
        pickSrs(
          lines: refs(1),
          states: const {},
          today: today,
          sessionPickIndex: 0,
          maxReviewsPerDay: 10,
          reviewsToday: 10,
        ),
        isA<SrsLimitReached>(),
      );
    });

    test('caught up reports the earliest future due day', () {
      final states = {
        'L0': review('2026-01-20'),
        'L1': review('2026-01-15'),
        'L2': review('2026-01-15'),
        'L3': SrsState.initial,
      };
      expect(
        pickSrs(
          lines: refs(3),
          states: states,
          today: today,
          sessionPickIndex: 0,
          newPerDay: 0,
        ),
        const SrsCaughtUp(nextDueDay: '2026-01-15', dueOnNextDay: 2),
      );
      expect(
        pickSrs(
          lines: const [],
          states: const {},
          today: today,
          sessionPickIndex: 0,
        ),
        const SrsCaughtUp(nextDueDay: null, dueOnNextDay: 0),
      );
    });

    test('pick value semantics', () {
      expect(
        const SrsPickLine('a', isNew: true).hashCode,
        const SrsPickLine('a', isNew: true).hashCode,
      );
      expect(
        const SrsCaughtUp(nextDueDay: 'd', dueOnNextDay: 1).hashCode,
        const SrsCaughtUp(nextDueDay: 'd', dueOnNextDay: 1).hashCode,
      );
      expect(const SrsPickLine('a', isNew: true).toString(), contains('a'));
      expect(
        const SrsCaughtUp(nextDueDay: 'd', dueOnNextDay: 1).toString(),
        contains('d'),
      );
    });
  });
}
