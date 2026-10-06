import 'package:chess_core/chess_core.dart';
import 'package:dartchess/dartchess.dart' show kInitialFEN;
import 'package:flutter/foundation.dart';
import 'package:repertoire_trainer/core/db/stats_queries.dart';
import 'package:repertoire_trainer/features/board/board_position.dart';

/// One day of the accuracy chart (01-product-spec §11.2).
@immutable
final class ChartDay {
  /// Creates it.
  const new({
    required this.day,
    required this.accuracy,
    required this.movingAverage,
    required this.runs,
  });

  /// `YYYY-MM-DD`.
  final String day;

  /// Daily accuracy; null on a day without graded runs (a gap).
  final double? accuracy;

  /// 7-day moving average: credit over graded moves of the 7 days ending
  /// here; null when none of them has graded runs.
  final double? movingAverage;

  /// Completed runs that day.
  final int runs;
}

/// Chart ranges.
enum ChartRange {
  /// The last 30 days.
  days30(30),

  /// The last 90 days.
  days90(90),

  /// From the first training day.
  all(null);

  new(this.days);

  /// Days shown, null for all.
  final int? days;
}

/// The chart's days for [range] ending [today], one entry per calendar
/// day (gaps included), from [daily] (oldest first).
List<ChartDay> chartDays(
  List<DailyAggregate> daily,
  String today,
  ChartRange range,
) {
  if (daily.isEmpty) return const [];
  final byDay = {for (final d in daily) d.day: d};
  final first = switch (range.days) {
    final n? => addDays(today, -(n - 1)),
    null => daily.first.day,
  };
  final n = daysBetween(first, today) + 1;
  if (n <= 0) return const [];
  final out = <ChartDay>[];
  for (var i = 0; i < n; i++) {
    final day = addDays(first, i);
    var credit = 0.0;
    var graded = 0;
    for (var k = 0; k < 7; k++) {
      final d = byDay[addDays(day, -k)];
      if (d == null) continue;
      credit += d.creditSum;
      graded += d.gradedSum;
    }
    final entry = byDay[day];
    out.add(
      ChartDay(
        day: day,
        accuracy: entry?.accuracy,
        movingAverage: graded == 0 ? null : credit / graded,
        runs: entry?.runCount ?? 0,
      ),
    );
  }
  return out;
}

/// A user move with its first-attempt record (§11.4).
@immutable
final class MissedMove {
  /// Creates it.
  const new({required this.node, required this.attempts, required this.misses});

  /// The repertoire move (the user's).
  final TreeNode node;

  /// Graded attempts.
  final int attempts;

  /// Misses (wrong first attempt or hint).
  final int misses;

  /// Error rate.
  double get rate => misses / attempts;
}

/// The node reached by [ucis] from the root, or null when the tree does
/// not contain those moves.
TreeNode? nodeAlong(RepertoireTree tree, Iterable<String> ucis) {
  var node = tree.root;
  for (final uci in ucis) {
    final next = node.children.where((c) => c.uci == uci).firstOrNull;
    if (next == null) return null;
    node = next;
  }
  return node;
}

/// Minimum attempts for the most-missed list.
const mostMissedMinAttempts = 3;

/// User moves by error rate (ties: more misses, then tree order), with at
/// least [minAttempts]; moves no longer in the tree are left out.
List<MissedMove> mostMissed(
  RepertoireTree tree,
  List<PlyMisses> rows, {
  int minAttempts = mostMissedMinAttempts,
  int limit = 10,
}) {
  final attempts = <int, int>{};
  final misses = <int, int>{};
  for (final r in rows) {
    final ucis = r.ucis.split(' ');
    if (r.ply < 1 || r.ply > ucis.length) continue;
    final node = nodeAlong(tree, ucis.take(r.ply));
    if (node == null || !node.isUserMove) continue;
    attempts[node.id] = (attempts[node.id] ?? 0) + r.attempts;
    misses[node.id] = (misses[node.id] ?? 0) + r.misses;
  }
  final out =
      [
        for (final id in attempts.keys)
          if (attempts[id]! >= minAttempts && misses[id]! > 0)
            MissedMove(
              node: tree.node(id),
              attempts: attempts[id]!,
              misses: misses[id]!,
            ),
      ]..sort((a, b) {
        final byRate = b.rate.compareTo(a.rate);
        if (byRate != 0) return byRate;
        final byMisses = b.misses.compareTo(a.misses);
        return byMisses != 0 ? byMisses : a.node.id.compareTo(b.node.id);
      });
  return out.take(limit).toList();
}

/// The runs of [runs] that count for current line [lineKey] (direct or
/// inherited, 03-data-model §5), or for archived [lineKey] when it is not a
/// current line.
List<RunRecord> lineHistory(
  LineIndex index,
  String lineKey,
  List<RunRecord> runs,
) => [
  for (final r in runs)
    if (switch (index.attribute(ucis: r.ucis, lineKey: r.lineKey)) {
      DirectAttribution(:final key) => key == lineKey,
      InheritedAttribution(:final keys) => keys.contains(lineKey),
      ArchivedAttribution(:final key) => key == lineKey,
    })
      r,
];

/// Per-ply first-attempt misses over [runs] (a line's error table).
List<({int ply, int attempts, int misses})> plyErrors(List<RunRecord> runs) {
  final attempts = <int, int>{};
  final misses = <int, int>{};
  for (final r in runs.where((r) => r.completed)) {
    for (final g in r.grades) {
      attempts[g.ply] = (attempts[g.ply] ?? 0) + 1;
      if (g.result == GradeResult.wrong || g.result == GradeResult.hint) {
        misses[g.ply] = (misses[g.ply] ?? 0) + 1;
      }
    }
  }
  final plies = attempts.keys.toList()..sort();
  return [
    for (final p in plies)
      (ply: p, attempts: attempts[p]!, misses: misses[p] ?? 0),
  ];
}

/// SAN of [ucis] from the start position (moves that do not resolve end
/// it).
List<String> sansOf(String ucis) => [
  for (final m in resolvePv(
    kInitialFEN,
    ucis.isEmpty ? const [] : ucis.split(' '),
    max: 1 << 20,
  ))
    m.san,
];

/// A line label for [ucis] when the line is not in the tree (archived):
/// the last [labelTailPlies] plies, like `lineLabel`.
String ucisLabel(String ucis) {
  final sans = sansOf(ucis);
  if (sans.length <= labelTailPlies) return formatSanMoves(sans);
  final first = sans.length - labelTailPlies + 1;
  return '…${formatSanMoves(sans.sublist(first - 1), firstPly: first)}';
}
