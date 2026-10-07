import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:repertoire_trainer/core/db/app_database.steps.dart';
import 'package:repertoire_trainer/core/db/tables.dart';

part 'app_database.g.dart';

/// The app's SQLite database (docs/plan/03-data-model.md §2).
@DriftDatabase(
  tables: [
    Repertoires,
    Nodes,
    Lines,
    Runs,
    MoveGrades,
    DeviationEvents,
    LineStatsTable,
    PlyStats,
    Settings,
    SyncState,
    AppMeta,
    ImportedGames,
    GameArchives,
    GameReviews,
    GameAnalysis,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Wraps the query executor [e].
  new(super.e);

  /// The on-device database: a background isolate shared across isolates,
  /// WAL journal (docs/plan/02-architecture.md §4), stored in the app support
  /// directory (drift_flutter's default is the user's Documents folder).
  factory open() => AppDatabase(
    driftDatabase(
      name: 'repertoire',
      native: DriftNativeOptions(
        shareAcrossIsolates: true,
        databaseDirectory: getApplicationSupportDirectory,
        setup: (db) => db.execute('PRAGMA journal_mode=WAL;'),
      ),
    ),
  );

  /// An in-memory database for tests.
  factory memory() => AppDatabase(NativeDatabase.memory());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: stepByStep(
      from1To2: (m, schema) async {
        // P10: the ply_stats cache and the stats indexes.
        await m.createTable(schema.plyStats);
        await m.createIndex(schema.runsDailyStats);
        await m.createIndex(schema.runsKeyUcis);
        await customStatement(plyStatsFillSql());
      },
      from2To3: (m, schema) async {
        // G1: Game Review tables (additive).
        await m.createTable(schema.importedGames);
        await m.createIndex(schema.gamesByUser);
        await m.createTable(schema.gameArchives);
        await m.createTable(schema.gameReviews);
        await m.createTable(schema.gameAnalysis);
      },
    ),
  );

  /// Fills `ply_stats` from the stored grades: every repertoire, or only
  /// the one bound to `?1` when [oneRepertoire].
  static String plyStatsFillSql({bool oneRepertoire = false}) {
    final only = oneRepertoire ? 'AND r.repertoire_id = ?1 ' : '';
    return 'INSERT INTO ply_stats (repertoire_id, ucis, ply, attempts, misses) '
        'SELECT r.repertoire_id, r.ucis, g.ply, COUNT(*), '
        "SUM(CASE WHEN g.result IN ('wrong', 'hint') THEN 1 ELSE 0 END) "
        'FROM move_grades g JOIN runs r ON r.id = g.run_id '
        'WHERE r.completed = 1 $only'
        'GROUP BY r.repertoire_id, r.ucis, g.ply';
  }
}
