import 'package:chess_core/chess_core.dart';
import 'package:repertoire_trainer/core/db/app_database.dart';
import 'package:repertoire_trainer/core/db/repositories/mappers.dart';

/// The derived `line_stats` cache.
abstract interface class StatsRepository {
  /// Stats of every line (current and archived) of [repertoireId].
  Stream<List<LineStats>> watchLineStats(String repertoireId);

  /// Current stats of [repertoireId].
  Future<List<LineStats>> lineStats(String repertoireId);

  /// Replaces all stats of [repertoireId] with [stats].
  Future<void> replaceDerived(String repertoireId, List<LineStats> stats);

  /// Inserts or updates [stats] of [repertoireId].
  Future<void> upsertDerived(String repertoireId, List<LineStats> stats);

  /// Adds a stored [run]'s first-attempt results to the `ply_stats` cache
  /// (completed runs only).
  Future<void> addPlyResults(RunRecord run);

  /// Recomputes the `ply_stats` cache of [repertoireId] from its grades.
  Future<void> rebuildPlyStats(String repertoireId);
}

/// drift implementation of [StatsRepository].
final class DriftStatsRepository implements StatsRepository {
  /// Creates the repository.
  new(this._db);

  final AppDatabase _db;

  @override
  Stream<List<LineStats>> watchLineStats(String repertoireId) =>
      (_db.select(_db.lineStatsTable)
            ..where((s) => s.repertoireId.equals(repertoireId)))
          .watch()
          .map((rows) => [for (final r in rows) lineStatsOf(r)]);

  @override
  Future<List<LineStats>> lineStats(String repertoireId) async => [
    for (final r in await (_db.select(
      _db.lineStatsTable,
    )..where((s) => s.repertoireId.equals(repertoireId))).get())
      lineStatsOf(r),
  ];

  @override
  Future<void> replaceDerived(String repertoireId, List<LineStats> stats) =>
      _db.transaction(() async {
        await (_db.delete(
          _db.lineStatsTable,
        )..where((s) => s.repertoireId.equals(repertoireId))).go();
        await upsertDerived(repertoireId, stats);
      });

  @override
  Future<void> upsertDerived(String repertoireId, List<LineStats> stats) =>
      _db.batch((b) {
        b.insertAllOnConflictUpdate(_db.lineStatsTable, [
          for (final s in stats) lineStatsCompanion(repertoireId, s),
        ]);
      });

  @override
  Future<void> addPlyResults(RunRecord run) async {
    if (!run.completed || run.grades.isEmpty) return;
    await _db.batch((b) {
      for (final g in run.grades) {
        final miss =
            g.result == GradeResult.wrong || g.result == GradeResult.hint;
        b.customStatement(
          'INSERT INTO ply_stats (repertoire_id, ucis, ply, attempts, misses) '
          'VALUES (?1, ?2, ?3, 1, ?4) '
          'ON CONFLICT (repertoire_id, ucis, ply) DO UPDATE SET '
          'attempts = attempts + 1, misses = misses + excluded.misses',
          [run.repertoireId, run.ucis, g.ply, if (miss) 1 else 0],
        );
      }
    });
  }

  @override
  Future<void> rebuildPlyStats(String repertoireId) =>
      _db.transaction(() async {
        await (_db.delete(
          _db.plyStats,
        )..where((p) => p.repertoireId.equals(repertoireId))).go();
        await _db.customStatement(
          AppDatabase.plyStatsFillSql(oneRepertoire: true),
          [repertoireId],
        );
      });
}
