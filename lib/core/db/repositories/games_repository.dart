import 'package:drift/drift.dart';
import 'package:repertoire_trainer/core/db/app_database.dart';

/// Fetched games and their archive state (Game Review, device-local).
final class GamesRepository {
  /// Wraps [_db].
  new(this._db);

  final AppDatabase _db;

  /// Stores [games], replacing rows with the same id; returns how many ids
  /// were new.
  Future<int> upsertGames(List<ImportedGamesCompanion> games) async {
    if (games.isEmpty) return 0;
    return await _db.transaction(() async {
      final ids = [for (final g in games) g.id.value];
      final known =
          await (_db.selectOnly(_db.importedGames)
                ..addColumns([_db.importedGames.id])
                ..where(_db.importedGames.id.isIn(ids)))
              .map((r) => r.read(_db.importedGames.id)!)
              .get();
      await _db.batch(
        (b) => b.insertAll(
          _db.importedGames,
          games,
          mode: InsertMode.insertOrReplace,
        ),
      );
      return ids.toSet().length - known.toSet().length;
    });
  }

  /// [username]'s games, newest first.
  Stream<List<DbImportedGame>> watchGames(String username) =>
      (_db.select(_db.importedGames)
            ..where((g) => g.username.equals(username))
            ..orderBy([(g) => OrderingTerm.desc(g.endTime)]))
          .watch();

  /// One game.
  Future<DbImportedGame?> game(String id) => (_db.select(
    _db.importedGames,
  )..where((g) => g.id.equals(id))).getSingleOrNull();

  /// The archive row [archive] (`''` for the list) of [username].
  Future<DbGameArchive?> archive(String username, String archive) =>
      (_db.select(_db.gameArchives)..where(
            (a) => a.username.equals(username) & a.archive.equals(archive),
          ))
          .getSingleOrNull();

  /// Stores an archive row.
  Future<void> saveArchive(GameArchivesCompanion row) =>
      _db.into(_db.gameArchives).insert(row, mode: InsertMode.insertOrReplace);

  /// Records months listed by chess.com that are not known yet (not
  /// fetched: `fetchedAt` 0).
  Future<void> addKnownMonths(String username, List<String> months) =>
      _db.batch(
        (b) => b.insertAll(_db.gameArchives, [
          for (final m in months)
            GameArchivesCompanion.insert(
              username: username,
              archive: m,
              fetchedAt: 0,
            ),
        ], mode: InsertMode.insertOrIgnore),
      );

  /// Months (`YYYY/MM`) of [username], newest first, with whether each was
  /// fetched.
  Future<List<(String, bool)>> months(String username) async {
    final rows =
        await (_db.select(_db.gameArchives)
              ..where(
                (a) => a.username.equals(username) & a.archive.equals('').not(),
              )
              ..orderBy([(a) => OrderingTerm.desc(a.archive)]))
            .get();
    return [for (final r in rows) (r.archive, r.fetchedAt > 0)];
  }
}
