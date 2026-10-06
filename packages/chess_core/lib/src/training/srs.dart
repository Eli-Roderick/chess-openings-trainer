import 'dart:convert';
import 'dart:typed_data';

import 'package:chess_core/src/training/attribution.dart';
import 'package:chess_core/src/training/constants.dart';
import 'package:chess_core/src/training/day_clock.dart';
import 'package:chess_core/src/training/run.dart';
import 'package:crypto/crypto.dart';
import 'package:meta/meta.dart';

/// SRS phase of a line.
enum SrsPhase {
  /// Never passed an SRS review.
  fresh('new'),

  /// Lapsed; due again the same day.
  learning('learning'),

  /// Scheduled for review.
  review('review');

  new(this.dbValue);

  /// Value stored in `line_stats.srsState`.
  final String dbValue;
}

/// SM-2 scheduling state of one line (docs/plan/04-algorithms.md §5.1).
@immutable
final class SrsState {
  /// Creates a state.
  const new({
    required this.phase,
    required this.reps,
    required this.ease,
    required this.intervalDays,
    required this.dueDay,
    required this.lapses,
    required this.firstSeenDay,
  });

  /// A line that has never been reviewed.
  static const initial = SrsState(
    phase: SrsPhase.fresh,
    reps: 0,
    ease: srsInitialEase,
    intervalDays: 0,
    dueDay: null,
    lapses: 0,
    firstSeenDay: null,
  );

  /// Phase.
  final SrsPhase phase;

  /// Successful reviews in a row.
  final int reps;

  /// Ease factor (1.3-3.0).
  final double ease;

  /// Current interval in days.
  final int intervalDays;

  /// Day the line is due, or null if new.
  final String? dueDay;

  /// Number of failed reviews.
  final int lapses;

  /// Day of the first SRS review (counts against the new-per-day quota).
  final String? firstSeenDay;

  /// A copy with the given fields replaced.
  SrsState copyWith({
    SrsPhase? phase,
    int? reps,
    double? ease,
    int? intervalDays,
    String? dueDay,
    int? lapses,
    String? firstSeenDay,
  }) => SrsState(
    phase: phase ?? this.phase,
    reps: reps ?? this.reps,
    ease: ease ?? this.ease,
    intervalDays: intervalDays ?? this.intervalDays,
    dueDay: dueDay ?? this.dueDay,
    lapses: lapses ?? this.lapses,
    firstSeenDay: firstSeenDay ?? this.firstSeenDay,
  );

  /// True if the line is in learning or review and due on or before [day].
  bool isDueOn(String day) =>
      phase != SrsPhase.fresh &&
      dueDay != null &&
      daysBetween(dueDay!, day) >= 0;

  @override
  bool operator ==(Object other) =>
      other is SrsState &&
      other.phase == phase &&
      other.reps == reps &&
      other.ease == ease &&
      other.intervalDays == intervalDays &&
      other.dueDay == dueDay &&
      other.lapses == lapses &&
      other.firstSeenDay == firstSeenDay;

  @override
  int get hashCode => Object.hash(
    phase,
    reps,
    ease,
    intervalDays,
    dueDay,
    lapses,
    firstSeenDay,
  );

  @override
  String toString() =>
      'SrsState(${phase.dbValue}, reps $reps, ease '
      '${ease.toStringAsFixed(2)}, interval $intervalDays, due $dueDay, '
      'lapses $lapses, first $firstSeenDay)';
}

/// Deterministic interval fuzz in [-0.10, +0.10): the first 4 bytes of
/// SHA-256("key:reps") as a uint32 scaled to the range. Every device derives
/// the same schedule from the same runs.
double srsFuzz(String lineKey, int reps) {
  final bytes = sha256.convert(utf8.encode('$lineKey:$reps')).bytes;
  final u32 = ByteData.sublistView(Uint8List.fromList(bytes)).getUint32(0);
  return u32 / 4294967296 * (2 * srsFuzzRange) - srsFuzzRange;
}

/// True if [run] is an SRS review when attributed directly to its line
/// (§5.2): SRS mode, completed, not deviated, at least one graded move.
bool isSrsReview(RunRecord run) =>
    run.mode == RunMode.srs &&
    run.completed &&
    !run.deviated &&
    run.gradedCount > 0;

/// Applies one run attributed directly to line [lineKey] (§5.2, §5.3).
SrsState applySrsRun(SrsState s, RunRecord run, String lineKey) {
  final day = run.localDay;
  if (!isSrsReview(run)) {
    // §5.3: a failure in another mode pulls the due date to that day.
    final a = run.accuracy;
    final outsideFailure =
        run.mode != RunMode.srs &&
        run.completed &&
        !run.deviated &&
        a != null &&
        a < srsPassAccuracy;
    if (outsideFailure &&
        s.phase == SrsPhase.review &&
        s.dueDay != null &&
        daysBetween(day, s.dueDay!) > 0) {
      return s.copyWith(dueDay: day);
    }
    return s;
  }

  final a = run.accuracy!;
  final pass = a >= srsPassAccuracy;
  if (s.phase == SrsPhase.review &&
      s.dueDay != null &&
      daysBetween(day, s.dueDay!) > 0) {
    // Reviewed early (branch switch): a pass changes nothing, a failure lapses.
    return pass ? s : _lapse(s, day);
  }
  final seen = s.firstSeenDay ?? day;
  if (!pass) return _lapse(s.copyWith(firstSeenDay: seen), day);

  final int reps;
  int interval;
  if (s.phase != SrsPhase.review) {
    reps = 1;
    interval = srsFirstIntervalDays;
  } else if (s.reps == 1) {
    reps = 2;
    interval = srsSecondIntervalDays;
  } else {
    reps = s.reps + 1;
    // The tolerance stops float noise (10 * 2.7000000000000002) adding a day.
    interval = (s.intervalDays * s.ease - 1e-9).ceil();
  }
  final perfect = a == 1.0;
  final ease = _roundEase(
    (s.ease + (perfect ? srsPerfectEaseBonus : 0)).clamp(
      srsMinEase,
      srsMaxEase,
    ),
  );
  if (interval >= srsFuzzFromDays) {
    interval += (interval * srsFuzz(lineKey, reps)).round();
  }
  if (interval > srsMaxIntervalDays) interval = srsMaxIntervalDays;
  return SrsState(
    phase: SrsPhase.review,
    reps: reps,
    ease: ease,
    intervalDays: interval,
    dueDay: addDays(day, interval),
    lapses: s.lapses,
    firstSeenDay: seen,
  );
}

/// Ease steps are 0.10 and 0.20, so two decimals are exact; rounding stops
/// float drift from accumulating over many reviews.
double _roundEase(num ease) => (ease * 100).round() / 100;

SrsState _lapse(SrsState s, String day) => SrsState(
  phase: SrsPhase.learning,
  reps: 0,
  ease: _roundEase(
    (s.ease - srsLapseEasePenalty).clamp(srsMinEase, srsMaxEase),
  ),
  intervalDays: 0,
  dueDay: day,
  lapses: s.lapses + 1,
  firstSeenDay: s.firstSeenDay ?? day,
);

/// Replays the runs attributed *directly* to [lineKey], oldest first.
/// Inherited runs must not be passed: an extended line starts as new (§5.4).
SrsState replaySrs(String lineKey, Iterable<RunRecord> directRunsSorted) {
  var s = SrsState.initial;
  for (final run in directRunsSorted) {
    s = applySrsRun(s, run, lineKey);
  }
  return s;
}

/// Outcome of [pickSrs].
@immutable
sealed class SrsPick {
  const new();
}

/// Train this line next.
final class SrsPickLine extends SrsPick {
  /// Creates a pick.
  const new(this.key, {required this.isNew});

  /// Line key.
  final String key;

  /// True if the line is introduced for the first time.
  final bool isNew;

  @override
  bool operator ==(Object other) =>
      other is SrsPickLine && other.key == key && other.isNew == isNew;

  @override
  int get hashCode => Object.hash(key, isNew);

  @override
  String toString() => 'SrsPickLine($key, new: $isNew)';
}

/// Nothing is due and no new line is allowed today ("All caught up").
final class SrsCaughtUp extends SrsPick {
  /// Creates the result.
  const new({required this.nextDueDay, required this.dueOnNextDay});

  /// Earliest future due day, or null if nothing is scheduled.
  final String? nextDueDay;

  /// Number of lines due on [nextDueDay].
  final int dueOnNextDay;

  @override
  bool operator ==(Object other) =>
      other is SrsCaughtUp &&
      other.nextDueDay == nextDueDay &&
      other.dueOnNextDay == dueOnNextDay;

  @override
  int get hashCode => Object.hash(nextDueDay, dueOnNextDay);

  @override
  String toString() => 'SrsCaughtUp($nextDueDay, $dueOnNextDay)';
}

/// The daily review limit is reached.
final class SrsLimitReached extends SrsPick {
  /// Creates the result.
  const new();
}

/// Lines due on [today], in session order: learning first, then by overdue
/// ratio descending, then ordinal (§5.5).
List<LineRef> srsDueOrder(
  Iterable<LineRef> lines,
  Map<String, SrsState> states,
  String today,
) {
  final due = [
    for (final l in lines)
      if (l.isTrainable && (states[l.key]?.isDueOn(today) ?? false)) l,
  ];
  double ratio(LineRef l) {
    final s = states[l.key]!;
    final interval = s.intervalDays < 1 ? 1 : s.intervalDays;
    return daysBetween(s.dueDay!, today) / interval;
  }

  due.sort((a, b) {
    final la = states[a.key]!.phase == SrsPhase.learning ? 0 : 1;
    final lb = states[b.key]!.phase == SrsPhase.learning ? 0 : 1;
    if (la != lb) return la - lb;
    final r = ratio(b).compareTo(ratio(a));
    return r != 0 ? r : a.ordinal.compareTo(b.ordinal);
  });
  return due;
}

/// Picks the next line of an SRS session (§5.5).
///
/// [sessionPickIndex] is the number of lines already picked in this session
/// (every [srsNewLineEvery]-th pick prefers a new line). [excluded] is the
/// §3.2 recent-line exclusion set; excluded lines are skipped when another
/// candidate exists. [reviewsToday] counts today's SRS reviews.
SrsPick pickSrs({
  required List<LineRef> lines,
  required Map<String, SrsState> states,
  required String today,
  required int sessionPickIndex,
  Set<String> excluded = const {},
  int newPerDay = defaultSrsNewPerDay,
  int? maxReviewsPerDay,
  int reviewsToday = 0,
}) {
  if (maxReviewsPerDay != null && reviewsToday >= maxReviewsPerDay) {
    return const SrsLimitReached();
  }
  final byOrdinal = [...lines]..sort((a, b) => a.ordinal.compareTo(b.ordinal));
  final due = srsDueOrder(byOrdinal, states, today);
  final newToday = states.values.where((s) => s.firstSeenDay == today).length;
  final allowed = newPerDay - newToday;
  final fresh = allowed <= 0
      ? <LineRef>[]
      : [
          for (final l in byOrdinal)
            if (l.isTrainable &&
                (states[l.key] ?? SrsState.initial).phase == SrsPhase.fresh)
              l,
        ].take(allowed).toList();

  if (due.isEmpty && fresh.isEmpty) {
    String? next;
    var count = 0;
    for (final s in states.values) {
      final d = s.dueDay;
      if (s.phase == SrsPhase.fresh || d == null) continue;
      if (daysBetween(today, d) <= 0) continue;
      if (next == null || daysBetween(d, next) > 0) {
        next = d;
        count = 1;
      } else if (d == next) {
        count++;
      }
    }
    return SrsCaughtUp(nextDueDay: next, dueOnNextDay: count);
  }

  final preferNew = (sessionPickIndex + 1) % srsNewLineEvery == 0;
  final first = preferNew ? fresh : due;
  final second = preferNew ? due : fresh;
  for (final list in [first, second]) {
    for (final l in list) {
      if (!excluded.contains(l.key)) {
        return SrsPickLine(l.key, isNew: identical(list, fresh));
      }
    }
  }
  final l = first.isNotEmpty ? first.first : second.first;
  final isNew = first.isNotEmpty ? identical(first, fresh) : !preferNew;
  return SrsPickLine(l.key, isNew: isNew);
}
