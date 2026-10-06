/// Local-day helpers (docs/plan/04-algorithms.md §10). Days are
/// `YYYY-MM-DD` strings.
library;

/// The training day of [instant]: its local date after subtracting
/// [dayStartHour] hours, so 03:30 with a 04:00 day start belongs to the
/// previous day.
String localDay(DateTime instant, int dayStartHour) {
  final local = instant.toLocal();
  // Calendar arithmetic (not Duration) so DST changes cannot shift the date.
  final shifted = DateTime(
    local.year,
    local.month,
    local.day,
    local.hour - dayStartHour,
    local.minute,
  );
  return formatDay(shifted);
}

/// Formats the date part of [d] as `YYYY-MM-DD`.
String formatDay(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

DateTime _parse(String day) {
  final parts = day.split('-');
  if (parts.length != 3) throw FormatException('not a day: $day');
  return DateTime.utc(
    int.parse(parts[0]),
    int.parse(parts[1]),
    int.parse(parts[2]),
  );
}

/// [day] plus [days] calendar days (negative to go back).
String addDays(String day, int days) {
  final d = _parse(day);
  return formatDay(DateTime.utc(d.year, d.month, d.day + days));
}

/// Calendar days from [from] to [to] (negative if [to] is earlier).
int daysBetween(String from, String to) =>
    _parse(to).difference(_parse(from)).inDays;
