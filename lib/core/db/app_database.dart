import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
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
    Settings,
    SyncState,
    AppMeta,
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
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration =>
      MigrationStrategy(onCreate: (m) => m.createAll());
}
