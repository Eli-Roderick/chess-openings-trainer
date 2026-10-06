import 'dart:convert';

import 'package:chess_core/chess_core.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:repertoire_trainer/core/db/app_database.dart';

/// A backup checked by SQLite: everything but the runs, which stay in a
/// temporary table ([docId]) until the import inserts them in SQL.
@immutable
final class RawBackup {
  /// Creates it.
  const new({
    required this.header,
    required this.runCount,
    required this.docId,
  });

  /// Everything but the runs (`runs` is empty).
  final BackupFile header;

  /// Runs in the file.
  final int runCount;

  /// The document in the `backup_doc` temporary table.
  final int docId;
}

/// Reads backup JSON with SQLite's JSON functions: a 20k-run backup is
/// tens of megabytes of JSON, too slow to decode into Dart objects or to
/// send to the database repeatedly (P11 import < 5 s). The text goes to
/// SQLite once and is kept as JSONB in a temporary table.
final class BackupQueries {
  /// Creates the queries.
  new(this._db);

  final AppDatabase _db;

  /// Stores [json] (an unpacked backup), checks it and returns its header;
  /// throws a [CodecError] like `SyncCodec.decodeBackup` would. Earlier
  /// documents are dropped.
  Future<RawBackup> inspect(String json) async {
    await _db.customStatement(
      'CREATE TEMP TABLE IF NOT EXISTS backup_doc '
      '(id INTEGER PRIMARY KEY, v BLOB NOT NULL)',
    );
    await _db.customStatement('DELETE FROM backup_doc');
    final valid = await _db
        .customSelect(
          'SELECT json_valid(?1) AS valid',
          variables: [Variable.withString(json)],
        )
        .getSingle();
    if (valid.read<int>('valid') != 1) throw const CorruptFile('not JSON');
    final docId = await _db.customInsert(
      'INSERT INTO backup_doc (v) VALUES (jsonb(?1))',
      variables: [Variable.withString(json)],
    );
    const doc = '(SELECT v FROM backup_doc WHERE id = ?1)';
    final id = [Variable.withInt(docId)];
    final row = await _db
        .customSelect(
          'SELECT json_type($doc) AS type, '
          "json_extract($doc, '\$.format') AS format, "
          "json_extract($doc, '\$.schema') AS schema, "
          "json_type($doc, '\$.runs') AS runs_type",
          variables: id,
        )
        .getSingle();
    if (row.read<String?>('type') != 'object') throw const WrongFormat(null);
    final format = row.data['format'];
    if (format != backupFormat) {
      throw WrongFormat(format is String ? format : null);
    }
    final schema = row.data['schema'];
    if (schema is! int) throw const CorruptFile('no schema');
    if (schema > supportedSchema) throw NewerSchema(schema);
    if (row.read<String?>('runs_type') != 'array') {
      throw const CorruptFile('bad field runs');
    }
    final runs = await _db
        .customSelect(
          'SELECT COUNT(*) AS n, '
          r"MAX(COALESCE(json_extract(value, '$.schema'), 1)) AS max_schema, "
          "SUM(CASE WHEN type != 'object' "
          r"OR json_type(value, '$.id') IS NOT 'text' THEN 1 ELSE 0 END) "
          'AS bad '
          "FROM jsonb_each($doc, '\$.runs')",
          variables: id,
        )
        .getSingle();
    final maxSchema = runs.readNullable<int>('max_schema') ?? 1;
    if (maxSchema > supportedSchema) throw NewerSchema(maxSchema);
    if ((runs.readNullable<int>('bad') ?? 0) > 0) {
      throw const CorruptFile('bad runs record');
    }
    final head = await _db
        .customSelect(
          "SELECT json_extract($doc, '\$.exportedAt') AS exported_at, "
          "json_extract($doc, '\$.appVersion') AS app_version, "
          "json_extract($doc, '\$.deviceId') AS device_id, "
          "json(json_extract($doc, '\$.repertoires')) AS repertoires, "
          "json(json_extract($doc, '\$.settings')) AS settings",
          variables: id,
        )
        .getSingle();
    T field<T>(String column) {
      final v = head.data[column];
      if (v is! T) throw CorruptFile('bad field $column');
      return v;
    }

    final List<RepertoireRecord> repertoires;
    try {
      repertoires = [
        for (final r
            in jsonDecode(field<String>('repertoires')) as List<dynamic>)
          RepertoireRecord.fromJson(r as Map<String, dynamic>),
      ];
    } on CodecError {
      rethrow;
    } on Object catch (e) {
      throw CorruptFile('bad repertoires record: $e');
    }
    final settingsText = head.readNullable<String>('settings');
    final settings = settingsText == null ? null : jsonDecode(settingsText);
    return RawBackup(
      header: BackupFile(
        exportedAt: field<int>('exported_at'),
        appVersion: field<String>('app_version'),
        deviceId: field<String>('device_id'),
        repertoires: repertoires,
        runs: const [],
        settings: settings is Map<String, dynamic> ? settings : const {},
      ),
      runCount: runs.read<int>('n'),
      docId: docId,
    );
  }

  /// Drops stored documents.
  Future<void> clear() async {
    await _db.customStatement(
      'CREATE TEMP TABLE IF NOT EXISTS backup_doc '
      '(id INTEGER PRIMARY KEY, v BLOB NOT NULL)',
    );
    await _db.customStatement('DELETE FROM backup_doc');
  }
}
