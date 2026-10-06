import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:repertoire_trainer/core/db/app_database.dart';
import 'package:repertoire_trainer/core/settings/app_settings.dart';

/// Device-local settings, one row per setting (JSON value).
abstract interface class SettingsRepository {
  /// The current settings (defaults for anything not stored).
  Future<AppSettings> load();

  /// Settings, re-emitted on every change.
  Stream<AppSettings> watch();

  /// Applies [change] to the current settings, normalizes ranges and stores
  /// the fields that changed. Returns the new settings.
  Future<AppSettings> update(AppSettings Function(AppSettings) change);
}

/// drift implementation of [SettingsRepository].
final class DriftSettingsRepository implements SettingsRepository {
  /// Creates the repository.
  new(this._db);

  final AppDatabase _db;

  /// Parses stored rows over the defaults. A stored value that no longer
  /// parses (renamed enum, wrong type) is ignored instead of breaking the
  /// app.
  static AppSettings fromRows(List<DbSetting> rows) {
    final merged = const AppSettings().toJson();
    for (final r in rows) {
      final Object? value;
      try {
        value = jsonDecode(r.value);
      } on FormatException {
        continue;
      }
      final candidate = {...merged, r.key: value};
      try {
        AppSettings.fromJson(candidate);
        merged[r.key] = value;
      } on Object {
        continue;
      }
    }
    return AppSettings.fromJson(merged).normalized();
  }

  @override
  Future<AppSettings> load() async =>
      fromRows(await _db.select(_db.settings).get());

  @override
  Stream<AppSettings> watch() =>
      _db.select(_db.settings).watch().map(fromRows).distinct();

  @override
  Future<AppSettings> update(AppSettings Function(AppSettings) change) =>
      _db.transaction(() async {
        final before = await load();
        final after = change(before).normalized();
        final a = before.toJson();
        final b = after.toJson();
        await _db.batch((batch) {
          for (final key in b.keys) {
            if (jsonEncode(a[key]) != jsonEncode(b[key])) {
              batch.insert(
                _db.settings,
                SettingsCompanion.insert(key: key, value: jsonEncode(b[key])),
                mode: InsertMode.insertOrReplace,
              );
            }
          }
        });
        return after;
      });
}
