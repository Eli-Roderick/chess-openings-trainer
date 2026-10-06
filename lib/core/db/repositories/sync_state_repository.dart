import 'package:drift/drift.dart';
import 'package:repertoire_trainer/core/db/app_database.dart';

/// Device-local key/value state for sync (docs/plan/03-data-model.md §2.9).
abstract interface class SyncStateRepository {
  /// The value of [key], or null.
  Future<String?> get(String key);

  /// Stores [value] under [key].
  Future<void> set(String key, String value);

  /// Removes [key].
  Future<void> remove(String key);

  /// The value of [key], re-emitted on change.
  Stream<String?> watch(String key);

  /// This device's id: a UUID v4 created on first use and kept forever.
  Future<String> deviceId();
}

/// Key of the device id.
const deviceIdKey = 'deviceId';

/// drift implementation of [SyncStateRepository].
final class DriftSyncStateRepository implements SyncStateRepository {
  /// Creates the repository; [_newId] makes the device id on first launch.
  new(this._db, {required this._newId});

  final AppDatabase _db;
  final String Function() _newId;

  @override
  Future<String?> get(String key) async => (await (_db.select(
    _db.syncState,
  )..where((s) => s.key.equals(key))).getSingleOrNull())?.value;

  @override
  Future<void> set(String key, String value) => _db
      .into(_db.syncState)
      .insert(
        SyncStateCompanion.insert(key: key, value: value),
        mode: InsertMode.insertOrReplace,
      );

  @override
  Future<void> remove(String key) =>
      (_db.delete(_db.syncState)..where((s) => s.key.equals(key))).go();

  @override
  Stream<String?> watch(String key) => (_db.select(
    _db.syncState,
  )..where((s) => s.key.equals(key))).watchSingleOrNull().map((r) => r?.value);

  @override
  Future<String> deviceId() => _db.transaction(() async {
    final existing = await get(deviceIdKey);
    if (existing != null) return existing;
    final id = _newId();
    await set(deviceIdKey, id);
    return id;
  });
}
