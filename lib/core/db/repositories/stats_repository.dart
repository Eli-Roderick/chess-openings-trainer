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
}
