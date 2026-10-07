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

  /// The analysis summary of [gameId] at [profile].
  Future<DbGameReview?> review(String gameId, int profile) =>
      (_db.select(_db.gameReviews)
            ..where((r) => r.gameId.equals(gameId) & r.profile.equals(profile)))
          .getSingleOrNull();

  /// Every analysis summary of [gameId] (live).
  Stream<List<DbGameReview>> watchReviews(String gameId) => (_db.select(
    _db.gameReviews,
  )..where((r) => r.gameId.equals(gameId))).watch();

  /// Stores a summary.
  Future<void> saveReview(GameReviewsCompanion row) =>
      _db.into(_db.gameReviews).insert(row, mode: InsertMode.insertOrReplace);

  /// Per-position results of [gameId] at [profile], by ply.
  Future<List<DbGameAnalysis>> positions(String gameId, int profile) =>
      (_db.select(_db.gameAnalysis)
            ..where((a) => a.gameId.equals(gameId) & a.profile.equals(profile))
            ..orderBy([(a) => OrderingTerm.asc(a.ply)]))
          .get();

  /// The same, live (the review fills in while analysis runs).
  Stream<List<DbGameAnalysis>> watchPositions(String gameId, int profile) =>
      (_db.select(_db.gameAnalysis)
            ..where((a) => a.gameId.equals(gameId) & a.profile.equals(profile))
            ..orderBy([(a) => OrderingTerm.asc(a.ply)]))
          .watch();

  /// Stores one position's result (the per-position checkpoint).
  Future<void> savePosition(GameAnalysisCompanion row) =>
      _db.into(_db.gameAnalysis).insert(row, mode: InsertMode.insertOrReplace);

  /// Sets the second-best score of one stored position.
  Future<void> saveSecond(
    String gameId,
    int profile,
    int ply, {
    int? cp,
    int? mate,
  }) =>
      (_db.update(_db.gameAnalysis)..where(
            (a) =>
                a.gameId.equals(gameId) &
                a.profile.equals(profile) &
                a.ply.equals(ply),
          ))
          .write(
            GameAnalysisCompanion(secondCp: Value(cp), secondMate: Value(mate)),
          );

  /// Stores the labels (index = ply - 1) and the completed summary. Rows
  /// without a score (`cp` and `mate` null) carry only a label.
  Future<void> completeReview(
    GameReviewsCompanion summary,
    List<int?> labels,
  ) => _db.transaction(() async {
    final gameId = summary.gameId.value;
    final profile = summary.profile.value;
    for (var i = 0; i < labels.length; i++) {
      // Book plies inside the opening have no engine row: a label-only row.
      await _db
          .into(_db.gameAnalysis)
          .insert(
            GameAnalysisCompanion.insert(
              gameId: gameId,
              profile: profile,
              ply: i + 1,
              depth: 0,
            ),
            mode: InsertMode.insertOrIgnore,
          );
      await (_db.update(_db.gameAnalysis)..where(
            (a) =>
                a.gameId.equals(gameId) &
                a.profile.equals(profile) &
                a.ply.equals(i + 1),
          ))
          .write(GameAnalysisCompanion(label: Value(labels[i])));
    }
    await saveReview(summary);
  });

  /// Removes [gameId]'s results at [profile] (engine changed).
  Future<void> clearAnalysis(String gameId, int profile) => _db.transaction(
    () async {
      await (_db.delete(_db.gameAnalysis)
            ..where((a) => a.gameId.equals(gameId) & a.profile.equals(profile)))
          .go();
      await (_db.delete(_db.gameReviews)
            ..where((r) => r.gameId.equals(gameId) & r.profile.equals(profile)))
          .go();
    },
  );

  /// Removes every stored result of [gameId], every profile (re-run).
  Future<void> clearGame(String gameId) => _db.transaction(() async {
    await (_db.delete(
      _db.gameAnalysis,
    )..where((a) => a.gameId.equals(gameId))).go();
    await (_db.delete(
      _db.gameReviews,
    )..where((r) => r.gameId.equals(gameId))).go();
  });

  /// Rewrites the stored scores of a complete summary (the formula changed
  /// since it was stored).
  Future<void> updateScores(
    String gameId,
    int profile, {
    double? whiteAccuracy,
    double? blackAccuracy,
    int? whitePerformance,
    int? blackPerformance,
  }) =>
      (_db.update(_db.gameReviews)
            ..where((r) => r.gameId.equals(gameId) & r.profile.equals(profile)))
          .write(
            GameReviewsCompanion(
              whiteAccuracy: Value(whiteAccuracy),
              blackAccuracy: Value(blackAccuracy),
              whitePerformance: Value(whitePerformance),
              blackPerformance: Value(blackPerformance),
            ),
          );

  /// The user's accuracy per game id from complete Quick or Standard
  /// reviews (Standard wins).
  Stream<Map<String, double>> watchUserAccuracies() => _db
      .customSelect(
        'SELECT r.game_id AS id, r.profile AS profile, '
        'CASE WHEN g.user_white THEN r.white_accuracy '
        'ELSE r.black_accuracy END AS acc '
        'FROM game_reviews r JOIN imported_games g ON g.id = r.game_id '
        'WHERE r.complete = 1 AND r.profile <= 1 ORDER BY r.profile',
        readsFrom: {_db.gameReviews, _db.importedGames},
      )
      .watch()
      .map(
        (rows) => {
          for (final r in rows)
            if (r.read<double?>('acc') != null)
              r.read<String>('id'): r.read<double>('acc'),
        },
      );
}
