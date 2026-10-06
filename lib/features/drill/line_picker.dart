import 'package:chess_core/chess_core.dart';
import 'package:flutter/foundation.dart';
import 'package:repertoire_trainer/core/settings/app_settings.dart';

/// Everything a picker may look at (live stats, read before each pick).
@immutable
final class PickContext {
  /// Creates the context.
  const new({
    required this.lines,
    required this.stats,
    required this.recentNewestFirst,
    required this.nowMs,
    required this.today,
    required this.settings,
    required this.rng,
    required this.sessionPickIndex,
    this.reviewsToday = 0,
  });

  /// The repertoire's lines.
  final List<Line> lines;

  /// Derived stats by line key.
  final Map<String, LineStats> stats;

  /// Recently started line keys, newest first (database and session).
  final List<String> recentNewestFirst;

  /// Now (UTC ms).
  final int nowMs;

  /// Today's training day.
  final String today;

  /// Settings.
  final AppSettings settings;

  /// Randomness.
  final Rng rng;

  /// Lines picked so far in this session.
  final int sessionPickIndex;

  /// SRS reviews done today (all repertoires).
  final int reviewsToday;

  /// Weak-pool lines.
  Set<String> get weakPool => {
    for (final s in stats.values)
      if (!s.archived && s.inWeakPool) s.lineKey,
  };

  /// Lines due today (SRS).
  Set<String> get srsDue => {
    for (final s in stats.values)
      if (!s.archived && s.srs.isDueOn(today)) s.lineKey,
  };

  /// Pick candidates for [lines].
  List<PickCandidate> candidates(Iterable<Line> lines) => [
    for (final l in lines)
      PickCandidate(
        key: l.key,
        ordinal: l.ordinal,
        userMoveCount: l.userMoveCount,
        lastPlayedAt: stats[l.key]?.lastPlayedAt,
        accuracy: stats[l.key]?.accuracy,
      ),
  ];

  /// SRS states by line key.
  Map<String, SrsState> get srsStates => {
    for (final s in stats.values)
      if (!s.archived) s.lineKey: s.srs,
  };

  /// [lines] as line refs.
  List<LineRef> get lineRefs => [
    for (final l in lines)
      LineRef(
        key: l.key,
        ucis: l.ucis,
        ordinal: l.ordinal,
        userMoveCount: l.userMoveCount,
      ),
  ];
}

/// Outcome of a pick.
@immutable
sealed class LinePick {
  const new();
}

/// Train this line.
final class PickedLine extends LinePick {
  /// Creates it.
  const new(this.key, {this.isNew = false});

  /// Line key.
  final String key;

  /// SRS: introduced today for the first time.
  final bool isNew;
}

/// No trainable line at all.
final class NoTrainableLines extends LinePick {
  /// Creates it.
  const new();
}

/// Weak mode with an empty pool ("No weak lines. Nice.").
final class WeakPoolEmpty extends LinePick {
  /// Creates it.
  const new();
}

/// SRS: nothing due and no new line allowed ("All caught up").
final class SrsAllCaughtUp extends LinePick {
  /// Creates it.
  const new({
    this.nextDueDay,
    this.dueOnNextDay = 0,
    this.limitReached = false,
  });

  /// Earliest future due day.
  final String? nextDueDay;

  /// Lines due on [nextDueDay].
  final int dueOnNextDay;

  /// The daily review limit stopped the session.
  final bool limitReached;
}

/// Chooses lines for a drill session (P08 task 1).
abstract interface class LinePicker {
  /// The mode runs are recorded with.
  RunMode get mode;

  /// The next line.
  LinePick pick(PickContext c);

  /// The continuation after an alternative repertoire move: one of
  /// [candidates] (lines through the new child), 04 §3.4.
  String? branchSwitch(PickContext c, List<Line> candidates);

  /// What the app bar shows next to the mode ("Weak 6", "SRS 12 left").
  int? count(PickContext c);
}

String? _switch(RunMode mode, PickContext c, List<Line> candidates) =>
    pickBranchSwitch(
      mode: mode,
      candidates: c.candidates(candidates),
      nowMs: c.nowMs,
      rng: c.rng,
      weakPool: c.weakPool,
      srsDue: c.srsDue,
    );

/// Random mode (04 §3).
final class RandomPicker implements LinePicker {
  /// Creates it.
  const new();

  @override
  RunMode get mode => RunMode.random;

  @override
  LinePick pick(PickContext c) {
    final key = pickRandomLine(
      lines: c.candidates(c.lines),
      recentNewestFirst: c.recentNewestFirst,
      nowMs: c.nowMs,
      rng: c.rng,
    );
    return key == null ? const NoTrainableLines() : PickedLine(key);
  }

  @override
  String? branchSwitch(PickContext c, List<Line> candidates) =>
      _switch(mode, c, candidates);

  @override
  int? count(PickContext c) => null;
}

/// Weak mode (04 §4): pool lines only.
final class WeakPicker implements LinePicker {
  /// Creates it.
  const new();

  @override
  RunMode get mode => RunMode.weak;

  @override
  LinePick pick(PickContext c) {
    final key = pickWeakLine(
      lines: c.candidates(c.lines),
      weakPool: c.weakPool,
      recentNewestFirst: c.recentNewestFirst,
      nowMs: c.nowMs,
      rng: c.rng,
    );
    return key == null ? const WeakPoolEmpty() : PickedLine(key);
  }

  @override
  String? branchSwitch(PickContext c, List<Line> candidates) =>
      _switch(mode, c, candidates);

  @override
  int? count(PickContext c) {
    final keys = {for (final l in c.lines) l.key};
    return c.weakPool.where(keys.contains).length;
  }
}

/// Spaced repetition (04 §5.5).
final class SrsPicker implements LinePicker {
  /// Creates it.
  const new();

  @override
  RunMode get mode => RunMode.srs;

  @override
  LinePick pick(PickContext c) {
    final refs = c.lineRefs;
    final pick = pickSrs(
      lines: refs,
      states: c.srsStates,
      today: c.today,
      sessionPickIndex: c.sessionPickIndex,
      excluded: recentExclusion(
        c.recentNewestFirst,
        refs.where((l) => l.isTrainable).length,
      ),
      newPerDay: c.settings.srsNewPerDay,
      maxReviewsPerDay: c.settings.srsMaxReviewsPerDay,
      reviewsToday: c.reviewsToday,
    );
    return switch (pick) {
      SrsPickLine(:final key, :final isNew) => PickedLine(key, isNew: isNew),
      SrsCaughtUp(:final nextDueDay, :final dueOnNextDay) => SrsAllCaughtUp(
        nextDueDay: nextDueDay,
        dueOnNextDay: dueOnNextDay,
      ),
      SrsLimitReached() => const SrsAllCaughtUp(limitReached: true),
    };
  }

  @override
  String? branchSwitch(PickContext c, List<Line> candidates) =>
      _switch(mode, c, candidates);

  /// Due lines plus the new lines still allowed today.
  @override
  int? count(PickContext c) {
    final refs = c.lineRefs;
    final states = c.srsStates;
    final due = srsDueOrder(refs, states, c.today).length;
    final newToday = states.values
        .where((s) => s.firstSeenDay == c.today)
        .length;
    final allowed = (c.settings.srsNewPerDay - newToday).clamp(0, 1 << 30);
    final fresh = refs
        .where(
          (l) =>
              l.isTrainable &&
              (states[l.key] ?? SrsState.initial).phase == SrsPhase.fresh,
        )
        .length;
    return due + (fresh < allowed ? fresh : allowed);
  }
}

/// One line, again and again (01 §7.12).
final class SingleLinePicker implements LinePicker {
  /// Drills the line [lineKey].
  const new(this.lineKey);

  /// The line.
  final String lineKey;

  @override
  RunMode get mode => RunMode.single;

  @override
  LinePick pick(PickContext c) {
    final line = c.lines.where((l) => l.key == lineKey).firstOrNull;
    return line == null || line.userMoveCount == 0
        ? const NoTrainableLines()
        : PickedLine(lineKey);
  }

  @override
  String? branchSwitch(PickContext c, List<Line> candidates) =>
      _switch(mode, c, candidates);

  @override
  int? count(PickContext c) => null;
}

/// The picker for [mode] (single needs [lineKey]).
LinePicker pickerFor(RunMode mode, {String? lineKey}) => switch (mode) {
  RunMode.random => const RandomPicker(),
  RunMode.weak => const WeakPicker(),
  RunMode.srs => const SrsPicker(),
  RunMode.single => SingleLinePicker(lineKey ?? ''),
};
