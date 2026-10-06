import 'package:chess_core/chess_core.dart';
import 'package:test/test.dart';

const hour = 3600000;
const int now = 1000 * hour;

void main() {
  group('weights (§3.1)', () {
    test('boundaries', () {
      expect(lineWeight(nowMs: now), closeTo(3.125, 1e-9)); // untrained
      expect(
        lineWeight(nowMs: now, lastPlayedAt: now - hour, accuracy: 1),
        closeTo(0.25 + 1 / 168, 1e-9),
      );
      expect(
        lineWeight(nowMs: now, lastPlayedAt: now - 168 * hour, accuracy: 0.5),
        closeTo(3.125, 1e-9),
      );
      expect(
        lineWeight(nowMs: now, lastPlayedAt: now - 168 * hour, accuracy: 0),
        closeTo(5.0, 1e-9),
      );
      // Saturates after 7 days; a clock skew into the future counts as 0 h.
      expect(
        lineWeight(nowMs: now, lastPlayedAt: now - 500 * hour, accuracy: 0),
        closeTo(5.0, 1e-9),
      );
      expect(
        lineWeight(nowMs: now, lastPlayedAt: now + hour, accuracy: 1),
        closeTo(0.25, 1e-9),
      );
    });
  });

  group('exclusion (§3.2)', () {
    const recent = ['a', 'b', 'a', 'c', 'd'];
    test('k = min(3, lineCount - 1) distinct keys, newest first', () {
      expect(recentExclusion(recent, 1), isEmpty);
      expect(recentExclusion(recent, 2), {'a'});
      expect(recentExclusion(recent, 3), {'a', 'b'});
      expect(recentExclusion(recent, 4), {'a', 'b', 'c'});
      expect(recentExclusion(recent, 40), {'a', 'b', 'c'});
      expect(recentExclusion(const [], 4), isEmpty);
    });
  });

  List<PickCandidate> lines(int n) => [
    for (var i = 0; i < n; i++) PickCandidate(key: 'L$i', ordinal: i),
  ];

  group('random picker', () {
    test('1 line is always picked, even if just played', () {
      expect(
        pickRandomLine(
          lines: lines(1),
          recentNewestFirst: ['L0'],
          nowMs: now,
          rng: SeededRng(1),
        ),
        'L0',
      );
    });

    test('never picks an excluded line', () {
      for (final n in [2, 3, 4]) {
        final rng = SeededRng(n);
        final recent = ['L0', 'L1', 'L2'];
        final excluded = recentExclusion(recent, n);
        for (var i = 0; i < 2000; i++) {
          final pick = pickRandomLine(
            lines: lines(n),
            recentNewestFirst: recent,
            nowMs: now,
            rng: rng,
          );
          expect(excluded.contains(pick), isFalse, reason: 'n=$n');
        }
      }
    });

    test('lines without user moves are never candidates', () {
      final pick = pickRandomLine(
        lines: [
          const PickCandidate(key: 'x', ordinal: 0, userMoveCount: 0),
          const PickCandidate(key: 'y', ordinal: 1),
        ],
        recentNewestFirst: const [],
        nowMs: now,
        rng: SeededRng(3),
      );
      expect(pick, 'y');
      expect(
        pickRandomLine(
          lines: [const PickCandidate(key: 'x', ordinal: 0, userMoveCount: 0)],
          recentNewestFirst: const [],
          nowMs: now,
          rng: SeededRng(3),
        ),
        isNull,
      );
    });

    test('distribution: 100k seeded picks within ±2 % of weight share', () {
      final candidates = [
        const PickCandidate(key: 'A', ordinal: 0),
        const PickCandidate(
          key: 'B',
          ordinal: 1,
          lastPlayedAt: now - hour,
          accuracy: 1,
        ),
        const PickCandidate(
          key: 'C',
          ordinal: 2,
          lastPlayedAt: now - 48 * hour,
          accuracy: 0.7,
        ),
        const PickCandidate(
          key: 'D',
          ordinal: 3,
          lastPlayedAt: now - 200 * hour,
          accuracy: 0.2,
        ),
      ];
      final weights = {
        for (final c in candidates)
          c.key: lineWeight(
            nowMs: now,
            lastPlayedAt: c.lastPlayedAt,
            accuracy: c.accuracy,
          ),
      };
      final total = weights.values.reduce((a, b) => a + b);
      final counts = <String, int>{};
      final rng = SeededRng(2026);
      const n = 100000;
      for (var i = 0; i < n; i++) {
        final k = pickRandomLine(
          lines: candidates,
          recentNewestFirst: const [],
          nowMs: now,
          rng: rng,
        )!;
        counts[k] = (counts[k] ?? 0) + 1;
      }
      for (final k in weights.keys) {
        expect(counts[k]! / n, closeTo(weights[k]! / total, 0.02), reason: k);
      }
    });

    test('sampleWeighted', () {
      expect(sampleWeighted(const [], SeededRng(1)), isNull);
      expect(sampleWeighted(const [('a', 0)], SeededRng(1)), isNull);
      expect(sampleWeighted(const [('a', 0), ('b', 2)], SeededRng(1)), 'b');
      expect(sampleWeighted(const [('a', 1), ('b', 0)], _MaxRng()), 'a');
    });
  });

  group('weak picker (§4)', () {
    test('restricted to the pool with exclusion min(3, poolSize - 1)', () {
      final rng = SeededRng(9);
      for (var i = 0; i < 500; i++) {
        final pick = pickWeakLine(
          lines: lines(6),
          weakPool: {'L1', 'L3', 'L5'},
          recentNewestFirst: ['L2', 'L3', 'L0', 'L1'],
          nowMs: now,
          rng: rng,
        );
        // Non-pool lines do not use exclusion slots: k = 2 excludes L3 and
        // L1; only L5 remains.
        expect(pick, 'L5');
      }
      expect(
        pickWeakLine(
          lines: lines(6),
          weakPool: {'L4'},
          recentNewestFirst: ['L4'],
          nowMs: now,
          rng: rng,
        ),
        'L4',
      );
    });

    test('empty pool: null ("No weak lines")', () {
      expect(
        pickWeakLine(
          lines: lines(3),
          weakPool: const {},
          recentNewestFirst: const [],
          nowMs: now,
          rng: SeededRng(1),
        ),
        isNull,
      );
    });
  });

  group('branch switch (§3.4)', () {
    final index = LineIndex([
      const LineRef(key: 'A', ucis: 'e2e4 e7e5 g1f3'),
      const LineRef(key: 'B', ucis: 'e2e4 e7e5 f1c4', ordinal: 1),
      const LineRef(key: 'C', ucis: 'e2e4 e7e5 f1c4 f8c5', ordinal: 2),
      const LineRef(key: 'D', ucis: 'd2d4', ordinal: 3),
    ]);
    final all = {
      for (final (i, k) in ['A', 'B', 'C', 'D'].indexed)
        k: PickCandidate(key: k, ordinal: i),
    };
    List<PickCandidate> through(String prefix) => [
      for (final k in index.linesThrough(prefix)) all[k]!,
    ];

    test('candidates are the lines through the new child', () {
      expect([for (final c in through('e2e4 e7e5 f1c4')) c.key], ['B', 'C']);
    });

    String? pick(
      RunMode mode, {
      Set<String> weak = const {},
      Set<String> due = const {},
    }) => pickBranchSwitch(
      mode: mode,
      candidates: through('e2e4 e7e5 f1c4'),
      nowMs: now,
      rng: SeededRng(4),
      weakPool: weak,
      srsDue: due,
    );

    test('random and single use weights among candidates only', () {
      for (final mode in [RunMode.random, RunMode.single]) {
        expect(['B', 'C'], contains(pick(mode)));
      }
    });

    test('weak prefers pool lines, SRS prefers due lines', () {
      expect(pick(RunMode.weak, weak: {'C', 'D'}), 'C');
      expect(pick(RunMode.srs, due: {'B'}), 'B');
      expect(['B', 'C'], contains(pick(RunMode.weak, weak: {'D'})));
    });
  });
}

final class _MaxRng implements Rng {
  @override
  double nextDouble() => 0.9999999999999999;

  @override
  int nextInt(int max) => max - 1;
}
