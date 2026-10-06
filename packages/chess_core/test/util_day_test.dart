import 'package:chess_core/chess_core.dart';
import 'package:test/test.dart';

void main() {
  group('clock and rng', () {
    test('FakeClock moves only when told', () {
      final c = FakeClock(DateTime.utc(2026));
      expect(c.now(), DateTime.utc(2026));
      c.advance(const Duration(hours: 2));
      expect(c.now(), DateTime.utc(2026, 1, 1, 2));
      c.current = DateTime.utc(2027);
      expect(c.now(), DateTime.utc(2027));
    });

    test('SystemClock returns a current time', () {
      final before = DateTime.now();
      expect(const SystemClock().now().isBefore(before), isFalse);
    });

    test('SeededRng is deterministic; SystemRng stays in range', () {
      final a = SeededRng(5);
      final b = SeededRng(5);
      expect(
        [for (var i = 0; i < 5; i++) a.nextInt(1000)],
        [for (var i = 0; i < 5; i++) b.nextInt(1000)],
      );
      expect(a.nextDouble(), b.nextDouble());
      final r = SystemRng();
      for (var i = 0; i < 100; i++) {
        expect(r.nextDouble(), inInclusiveRange(0, 1));
        expect(r.nextInt(3), inInclusiveRange(0, 2));
      }
    });
  });

  group('local day (§10)', () {
    test('day starts at the configured hour', () {
      expect(localDay(DateTime(2026, 10, 6, 3, 30), 4), '2026-10-05');
      expect(localDay(DateTime(2026, 10, 6, 4), 4), '2026-10-06');
      expect(localDay(DateTime(2026, 10, 6, 0, 10), 0), '2026-10-06');
      expect(localDay(DateTime(2026, 1, 1, 1), 4), '2025-12-31');
    });

    test('UTC instants are converted to local time first', () {
      final local = DateTime(2026, 10, 6, 12);
      expect(localDay(local.toUtc(), 4), '2026-10-06');
    });

    test('day arithmetic across months, years and leap days', () {
      expect(addDays('2026-01-31', 1), '2026-02-01');
      expect(addDays('2026-12-31', 1), '2027-01-01');
      expect(addDays('2028-02-28', 1), '2028-02-29');
      expect(addDays('2026-03-01', -1), '2026-02-28');
      expect(daysBetween('2026-01-01', '2026-12-31'), 364);
      expect(daysBetween('2026-01-05', '2026-01-01'), -4);
      expect(formatDay(DateTime(987, 6, 5)), '0987-06-05');
      expect(() => addDays('2026/01/01', 1), throwsFormatException);
    });
  });
}
