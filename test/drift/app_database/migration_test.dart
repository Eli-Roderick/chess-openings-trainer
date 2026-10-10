// Drift migration test scaffold (docs/plan/03-data-model.md §7). For every
// schema change: bump schemaVersion, write the onUpgrade step, run
// `dart run drift_dev make-migrations` and
// `dart run drift_dev schema generate drift_schemas/app_database/ test/drift/app_database/generated/`,
// then add an upgrade test from each older version below.
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repertoire_trainer/core/db/app_database.dart';

import 'generated/schema.dart';

void main() {
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('the exported v1 schema matches the database', () async {
    final schema = await verifier.schemaAt(1);
    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 1);
    await db.close();
  });

  test('1 → 2 adds ply_stats and the stats indexes', () async {
    final schema = await verifier.schemaAt(1);
    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 2);
    await db.close();
  });

  test('2 → 3 adds the Game Review tables', () async {
    final schema = await verifier.schemaAt(2);
    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 3);
    await db.close();
  });

  test('3 → 4 adds the chess.com accuracy columns', () async {
    final schema = await verifier.schemaAt(3);
    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 4);
    await db.close();
  });

  test('1 → 4 in one upgrade', () async {
    final schema = await verifier.schemaAt(1);
    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 4);
    await db.close();
  });

  test('a fresh database validates against the latest schema', () async {
    final db = AppDatabase.memory();
    expect(db.schemaVersion, 4);
    final schema = await verifier.schemaAt(db.schemaVersion);
    final migrated = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(migrated, db.schemaVersion);
    await migrated.close();
    await db.close();
  });
}
