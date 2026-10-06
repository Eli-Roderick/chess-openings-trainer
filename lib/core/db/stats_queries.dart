import 'package:chess_core/chess_core.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:repertoire_trainer/core/db/app_database.dart';
import 'package:repertoire_trainer/core/db/repositories/mappers.dart';

/// One training day of a repertoire (chart input, 04-algorithms §2.4).
@immutable
final class DailyAggregate {
  /// Creates it.
  const new({
    required this.day,
    required this.creditSum,
    required this.gradedSum,
    required this.runCount,
  });

  /// `YYYY-MM-DD`.
  final String day;

  /// Credit over eligible runs.
  final double creditSum;

  /// Graded moves over eligible runs.
  final int gradedSum;

  /// Completed runs.
  final int runCount;

  /// Daily accuracy, null without graded moves.
  double? get accuracy => gradedSum == 0 ? null : creditSum / gradedSum;
}

/// First-attempt results at one ply of one move sequence (completed runs).
@immutable
final class PlyMisses {
  /// Creates it.
  const new({
    required this.ucis,
    required this.ply,
    required this.attempts,
    required this.misses,
  });

  /// The runs' move sequence.
  final String ucis;

  /// The graded ply (1-based).
  final int ply;

  /// Graded attempts.
  final int attempts;

  /// Wrong first attempts and hints.
  final int misses;
}

/// A deviation reply with its run.
@immutable
final class DeviationEntry {
  /// Creates it.
  const new({
    required this.event,
    required this.lineKey,
    required this.finishedAt,
  });

  /// The event.
  final DeviationEvent event;

  /// The run's line.
  final String lineKey;

  /// When the run finished.
  final int finishedAt;
}

/// Deviation replies of a repertoire (01-product-spec §11.5).
@immutable
final class DeviationSummary {
  /// Creates it.
  const new({required this.count, required this.passed, required this.recent});

  /// Judged replies.
  final int count;

  /// Good replies.
  final int passed;

  /// The last 10, newest first.
  final List<DeviationEntry> recent;

  /// Good-reply rate, null without replies.
  double? get rate => count == 0 ? null : passed / count;
}

/// SQL aggregates behind the stats screens (P10 task 1). Everything that
/// would otherwise load every run with its grades is computed here.
final class StatsQueries {
  /// Creates the queries.
  new(this._db);

  final AppDatabase _db;

  /// Completed runs per local day of [repertoireId], oldest first.
  Future<List<DailyAggregate>> daily(String repertoireId) async {
    final rows = await _db
        .customSelect(
          'SELECT local_day AS day, '
          'SUM(CASE WHEN graded_count > 0 THEN credit_sum ELSE 0 END) '
          'AS credit, '
          'SUM(graded_count) AS graded, COUNT(*) AS runs '
          'FROM runs WHERE repertoire_id = ?1 AND completed = 1 '
          'GROUP BY local_day ORDER BY local_day',
          variables: [Variable.withString(repertoireId)],
          readsFrom: {_db.runs},
        )
        .get();
    return [
      for (final r in rows)
        DailyAggregate(
          day: r.read<String>('day'),
          creditSum: r.read<double>('credit'),
          gradedSum: r.read<int>('graded'),
          runCount: r.read<int>('runs'),
        ),
    ];
  }

  /// First-attempt misses per (move sequence, ply) over completed runs of
  /// [repertoireId] (the `ply_stats` cache); the app maps sequences to tree
  /// nodes.
  Future<List<PlyMisses>> plyMisses(String repertoireId) async {
    final rows = await (_db.select(
      _db.plyStats,
    )..where((p) => p.repertoireId.equals(repertoireId))).get();
    return [
      for (final r in rows)
        PlyMisses(
          ucis: r.ucis,
          ply: r.ply,
          attempts: r.attempts,
          misses: r.misses,
        ),
    ];
  }

  /// Deviation replies of [repertoireId]. `CROSS JOIN` keeps SQLite
  /// scanning the (small) events table, not every run.
  Future<DeviationSummary> deviations(String repertoireId) async {
    final totals = await _db
        .customSelect(
          'SELECT COUNT(*) AS n, '
          'SUM(CASE WHEN d.passed THEN 1 ELSE 0 END) AS ok '
          'FROM deviation_events d CROSS JOIN runs r ON r.id = d.run_id '
          'WHERE r.repertoire_id = ?1',
          variables: [Variable.withString(repertoireId)],
          readsFrom: {_db.runs, _db.deviationEvents},
        )
        .getSingle();
    final recent = await _db
        .customSelect(
          'SELECT d.*, r.line_key AS line_key, r.finished_at AS finished_at '
          'FROM deviation_events d CROSS JOIN runs r ON r.id = d.run_id '
          'WHERE r.repertoire_id = ?1 '
          'ORDER BY r.finished_at DESC, r.id DESC LIMIT 10',
          variables: [Variable.withString(repertoireId)],
          readsFrom: {_db.runs, _db.deviationEvents},
        )
        .get();
    return DeviationSummary(
      count: totals.read<int>('n'),
      passed: totals.read<int?>('ok') ?? 0,
      recent: [
        for (final r in recent)
          DeviationEntry(
            event: deviationOf(_db.deviationEvents.map(r.data)),
            lineKey: r.read<String>('line_key'),
            finishedAt: r.read<int>('finished_at'),
          ),
      ],
    );
  }

  /// Completed runs of [repertoireId] (any line).
  Future<int> completedRuns(String repertoireId) async {
    final row = await _db
        .customSelect(
          'SELECT COUNT(*) AS n FROM runs '
          'WHERE repertoire_id = ?1 AND completed = 1',
          variables: [Variable.withString(repertoireId)],
          readsFrom: {_db.runs},
        )
        .getSingle();
    return row.read<int>('n');
  }

  /// The move sequence of every line key with runs in [repertoireId]
  /// (labels of archived lines, which are no longer in the tree).
  Future<Map<String, String>> ucisByKey(String repertoireId) async {
    final rows = await _db
        .customSelect(
          'SELECT line_key, MAX(ucis) AS ucis FROM runs '
          'WHERE repertoire_id = ?1 GROUP BY line_key',
          variables: [Variable.withString(repertoireId)],
          readsFrom: {_db.runs},
        )
        .get();
    return {
      for (final r in rows) r.read<String>('line_key'): r.read<String>('ucis'),
    };
  }
}
