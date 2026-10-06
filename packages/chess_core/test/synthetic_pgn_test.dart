import 'package:chess_core/chess_core.dart';
import 'package:dartchess/dartchess.dart' show Side;
import 'package:test/test.dart';

void main() {
  test('deterministic for a seed, different across seeds', () {
    final a = generateSyntheticPgn(lines: 20, depth: 10, seed: 7);
    expect(generateSyntheticPgn(lines: 20, depth: 10, seed: 7), a);
    expect(generateSyntheticPgn(lines: 20, depth: 10, seed: 8), isNot(a));
  });

  test('legal, exact line count and depth, user moves commented', () {
    for (final side in Side.values) {
      final pgn = generateSyntheticPgn(
        lines: 50,
        depth: 12,
        seed: 1,
        userSide: side,
      );
      final r = importPgn(pgn, side);
      expect(r.report.errors, isEmpty);
      expect(r.report.warnings, isEmpty);
      expect(r.report.lines, 50);
      expect(r.report.commentedUserMoves, r.report.userMoves);
      for (final line in r.tree!.lines) {
        expect(line.plies, 12);
      }
    }
  });

  // docs/plan/phases/P01-pgn-import.md: 1,000 lines of depth 16 import in
  // under 1.0 s on CI.
  test('benchmark: 1,000 lines x 16 plies import in < 1.0 s', () {
    final pgn = generateSyntheticPgn(lines: 1000, depth: 16, seed: 42);
    final r = importPgn(pgn, Side.white);
    expect(r.report.lines, 1000);
    expect(r.report.errors, isEmpty);
    expect(r.elapsed, lessThan(const Duration(seconds: 1)));
  });
}
