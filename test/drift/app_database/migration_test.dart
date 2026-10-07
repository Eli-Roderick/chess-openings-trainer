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

  test('2 → 3 adds snapshots and keeps existing repertoires', () async {
    final schema = await verifier.schemaAt(2);
    schema.rawDatabase.execute(
      'INSERT INTO repertoires (id, name, color, pgn, pgn_hash, created_at, '
      'updated_at, updated_by, deleted, drill_start_from) '
      "VALUES ('r1', 'R', 'w', '1. e4 *', 'h', 1, 2, 'd', 0, 'move1')",
    );
    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 3);
    expect((await db.select(db.repertoires).getSingle()).name, 'R');
    expect(await db.select(db.snapshots).get(), isEmpty);
    await db.close();
  });

  test('a fresh database validates against the latest schema', () async {
    final db = AppDatabase.memory();
    expect(db.schemaVersion, 3);
    final schema = await verifier.schemaAt(db.schemaVersion);
    final migrated = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(migrated, db.schemaVersion);
    await migrated.close();
    await db.close();
  });
}
