import 'dart:math';

import 'package:chess_core/chess_core.dart';
import 'package:test/test.dart';

import 'training_helpers.dart';

const a = LineRef(key: 'A', ucis: 'e2e4 e7e5 g1f3');
const b = LineRef(key: 'B', ucis: 'e2e4 e7e5 f1c4', ordinal: 1);
const c = LineRef(key: 'C', ucis: 'e2e4 c7c5 g1f3', ordinal: 2);

/// Random runs over [lines] plus archived and shortened (inherited) ones.
List<RunRecord> syntheticRuns(List<LineRef> lines, int n, int seed) {
  final rng = SeededRng(seed);
  const modes = RunMode.values;
  return [
    for (var i = 0; i < n; i++)
      () {
        final l = lines[rng.nextInt(lines.length)];
        final kind = rng.nextInt(10);
        final tokens = l.ucis.split(' ');
        final ucis = kind == 0
            ? tokens
                  .take(tokens.length - 1)
                  .join(' ') // inherited
            : kind == 1
            ? '${l.ucis} a7a6' // archived (longer than any current line)
            : l.ucis;
        final graded = 1 + rng.nextInt(6);
        final credits = [
          for (var g = 0; g < graded; g++)
            [1.0, 1.0, 1.0, 0.5, 0.0][rng.nextInt(5)],
        ];
        return makeRun(
          id: 'run$i',
          lineKey: kind == 1 ? 'old-${l.key}' : l.key,
          ucis: ucis,
          mode: modes[rng.nextInt(modes.length)],
          finishedAt: 1000 + rng.nextInt(n * 10),
          day: addDays('2026-01-01', rng.nextInt(120)),
          completed: rng.nextInt(12) != 0,
          deviated: rng.nextInt(15) == 0,
          credits: credits,
        );
      }(),
  ];
}

void main() {
  group('deriveRepertoire (§8)', () {
    test('direct, inherited and archived runs', () {
      final runs = [
        makeRun(
          id: '1',
          lineKey: 'A',
          ucis: a.ucis,
          finishedAt: 10,
          credits: [1, 0],
        ),
        // Inherited by A and B (run of the old, shorter line).
        makeRun(
          id: '2',
          lineKey: 'old',
          ucis: 'e2e4 e7e5',
          finishedAt: 20,
          mode: RunMode.srs,
        ),
        // Archived: no current line matches.
        makeRun(
          id: '3',
          lineKey: 'gone',
          ucis: 'd2d4',
          finishedAt: 30,
          credits: [0.5],
        ),
        // Abandoned direct run: not eligible.
        makeRun(
          id: '4',
          lineKey: 'B',
          ucis: b.ucis,
          finishedAt: 40,
          completed: false,
        ),
        makeRun(
          id: '5',
          lineKey: 'C',
          ucis: c.ucis,
          finishedAt: 50,
          mode: RunMode.srs,
          day: '2026-02-01',
        ),
      ];
      final stats = {
        for (final s in deriveRepertoire(lines: const [a, b, c], runs: runs))
          s.lineKey: s,
      };
      expect(stats.keys, ['A', 'B', 'C', 'gone']);

      expect(stats['A']!.runCount, 2);
      expect(stats['A']!.accuracy, 2 / 3);
      expect(stats['A']!.lastPlayedAt, 20);
      expect(stats['A']!.inWeakPool, isTrue);
      // The inherited SRS run does not count for SRS (§5.4).
      expect(stats['A']!.srs, SrsState.initial);

      expect(stats['B']!.runCount, 1);
      expect(stats['B']!.accuracy, 1.0);
      expect(stats['B']!.weakCleanStreak, 0);

      expect(stats['C']!.srs.phase, SrsPhase.review);
      expect(stats['C']!.srs.dueDay, '2026-02-02');

      final gone = stats['gone']!;
      expect(gone.archived, isTrue);
      expect(gone.accuracy, 0.5);
      expect(gone.inWeakPool, isFalse);
      expect(gone.srs, SrsState.initial);
      expect(gone.toString(), contains('archived'));
    });

    test('lines without runs get empty stats', () {
      final s = deriveRepertoire(lines: const [a], runs: const []).single;
      expect(s.runCount, 0);
      expect(s.accuracy, isNull);
      expect(s.lastPlayedAt, isNull);
      expect(s.weak, WeakPoolState.outside);
      expect(s.archived, isFalse);
    });

    test('weak thresholds come from settings', () {
      final runs = [
        makeRun(lineKey: 'A', ucis: a.ucis, credits: [1, 1, 1, 1, 0.5]),
      ];
      bool weak(double enter) => deriveRepertoire(
        lines: const [a],
        runs: runs,
        settings: DeriveSettings(weakEnterBelow: enter),
      ).single.inWeakPool;
      expect(weak(0.8), isFalse);
      expect(weak(0.95), isTrue);
    });
  });

  test('incremental derivation equals full derivation', () {
    const lines = [a, b, c];
    final runs = syntheticRuns(lines, 3000, 7);
    final full = {
      for (final s in deriveRepertoire(lines: lines, runs: runs)) s.lineKey: s,
    };
    for (final key in [...full.keys, 'unknown']) {
      final one = deriveLines(keys: [key], lines: lines, runs: runs);
      if (full[key] == null) {
        expect(one, isEmpty);
      } else {
        expect(one, [full[key]]);
      }
    }
    expect(deriveLines(keys: ['A', 'C'], lines: lines, runs: runs), [
      full['A'],
      full['C'],
    ]);
  });

  test('property: insertion order does not matter', () {
    const lines = [a, b, c];
    final runs = syntheticRuns(lines, 2000, 11);
    final expected = deriveRepertoire(lines: lines, runs: runs);
    for (var seed = 0; seed < 5; seed++) {
      final shuffled = [...runs]..shuffle(Random(seed));
      expect(deriveRepertoire(lines: lines, runs: shuffled), expected);
    }
    expect(expected.first.hashCode, expected.first.hashCode);
  });

  test('benchmark: 50k runs over 500 lines derive in < 1 s', () {
    final lines = [
      for (var i = 0; i < 500; i++)
        LineRef(
          key: 'K$i',
          ucis: 'e2e4 e7e5 g1f3 b8c6 m${i ~/ 50} n${i % 50} x$i y$i',
          ordinal: i,
        ),
    ];
    final runs = syntheticRuns(lines, 50000, 1);
    final sw = Stopwatch()..start();
    final stats = deriveRepertoire(lines: lines, runs: runs);
    sw.stop();
    expect(stats.where((s) => !s.archived), hasLength(500));
    expect(sw.elapsed, lessThan(const Duration(seconds: 1)));
  }, tags: 'bench');
}
