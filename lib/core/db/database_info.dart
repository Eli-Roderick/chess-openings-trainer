import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:repertoire_trainer/core/db/app_database.dart';
import 'package:repertoire_trainer/core/db/providers.dart';

/// Database facts for Diagnostics (10-testing §6).
final class DatabaseInfo {
  /// Creates the facts.
  const new({required this.fileBytes, required this.rowCounts});

  /// Size of the database file plus its WAL; null for a database without a
  /// file (tests).
  final int? fileBytes;

  /// Rows per table, in schema order.
  final Map<String, int> rowCounts;
}

/// Counts the rows of every table of [db] and sizes the file at [path].
Future<DatabaseInfo> readDatabaseInfo(AppDatabase db, {String? path}) async {
  final counts = <String, int>{};
  for (final table in db.allTables) {
    final name = table.actualTableName;
    final row = await db
        .customSelect('SELECT count(*) AS c FROM "$name"')
        .getSingle();
    counts[name] = row.read<int>('c');
  }
  int? bytes;
  if (path != null) {
    for (final f in [File(path), File('$path-wal')]) {
      if (f.existsSync()) bytes = (bytes ?? 0) + f.lengthSync();
    }
  }
  return DatabaseInfo(fileBytes: bytes, rowCounts: counts);
}

/// The on-device database file (`AppDatabase.open`).
Future<String> defaultDatabasePath() async =>
    p.join((await getApplicationSupportDirectory()).path, 'repertoire.sqlite');

/// Where the on-device database file is (in-memory test databases have
/// none; the size then reads n/a).
final FutureProvider<String?> databasePathProvider = FutureProvider<String?>(
  (ref) => defaultDatabasePath(),
);

/// The facts, read when Diagnostics opens or refreshes.
final FutureProvider<DatabaseInfo> databaseInfoProvider =
    FutureProvider.autoDispose<DatabaseInfo>((ref) async {
      final db = ref.watch(databaseProvider);
      String? path;
      try {
        path = await ref.watch(databasePathProvider.future);
      } on Object {
        path = null;
      }
      return await readDatabaseInfo(db, path: path);
    });
