import 'dart:convert';
import 'dart:typed_data';

import 'package:chess_core/src/sync/records.dart';
import 'package:chess_core/src/training/run.dart';
import 'package:meta/meta.dart';

/// Gzip compression, supplied by the platform so this package stays free
/// of `dart:io`.
abstract interface class GzipCodec {
  /// Compresses [bytes].
  List<int> encode(List<int> bytes);

  /// Decompresses [bytes]; throws on corrupt input.
  List<int> decode(List<int> bytes);
}

/// Sync meta file format name.
const metaFormat = 'rt-sync-meta';

/// Backup file format name.
const backupFormat = 'rt-backup';

/// Highest meta / backup / run schema this code reads.
const supportedSchema = 1;

/// Why a file could not be read (docs/plan/06-sync.md §3, §7).
sealed class CodecError implements Exception {
  const new();
}

/// Not gzip, not JSON, or missing fields.
final class CorruptFile extends CodecError {
  /// Creates the error.
  const new(this.reason);

  /// What failed.
  final String reason;

  @override
  String toString() => 'CorruptFile($reason)';
}

/// Valid JSON of another kind ([found] instead of the expected format).
final class WrongFormat extends CodecError {
  /// Creates the error.
  const new(this.found);

  /// The `format` field found, if any.
  final String? found;

  @override
  String toString() => 'WrongFormat($found)';
}

/// Written by a newer app ([schema] > [supportedSchema]).
final class NewerSchema extends CodecError {
  /// Creates the error.
  const new(this.schema);

  /// The file's schema.
  final int schema;

  @override
  String toString() => 'NewerSchema($schema)';
}

/// A device's meta file: every repertoire it knows, tombstones included.
@immutable
final class MetaFile {
  /// Creates it.
  const new({
    required this.deviceId,
    required this.deviceName,
    required this.appVersion,
    required this.writtenAt,
    required this.repertoires,
  });

  /// Writer.
  final String deviceId;

  /// Writer's display name.
  final String deviceName;

  /// Writer's app version.
  final String appVersion;

  /// UTC ms.
  final int writtenAt;

  /// Repertoires.
  final List<RepertoireRecord> repertoires;
}

/// A manual backup (docs/plan/06-sync.md §8).
@immutable
final class BackupFile {
  /// Creates it.
  const new({
    required this.exportedAt,
    required this.appVersion,
    required this.deviceId,
    required this.repertoires,
    required this.runs,
    this.settings = const {},
  });

  /// UTC ms.
  final int exportedAt;

  /// Exporting app version.
  final String appVersion;

  /// Exporting device.
  final String deviceId;

  /// Non-deleted repertoires.
  final List<RepertoireRecord> repertoires;

  /// All runs.
  final List<RunRecord> runs;

  /// The exporting device's settings (JSON).
  final Map<String, dynamic> settings;
}

/// Encodes and decodes sync and backup files (bytes in, bytes out).
final class SyncCodec {
  /// Creates a codec on [gzip].
  const new(this.gzip);

  /// Compression.
  final GzipCodec gzip;

  Uint8List _pack(Object json) =>
      Uint8List.fromList(gzip.encode(utf8.encode(jsonEncode(json))));

  String _unpackText(List<int> bytes) {
    try {
      return utf8.decode(gzip.decode(bytes));
    } on Object catch (e) {
      throw CorruptFile('not gzip/UTF-8: $e');
    }
  }

  Map<String, dynamic> _unpackObject(List<int> bytes, String format) {
    final text = _unpackText(bytes);
    final Object? json;
    try {
      json = jsonDecode(text);
    } on FormatException catch (e) {
      throw CorruptFile('not JSON: ${e.message}');
    }
    if (json is! Map<String, dynamic>) throw const WrongFormat(null);
    final found = json['format'];
    if (found != format) throw WrongFormat(found is String ? found : null);
    final schema = json['schema'];
    if (schema is! int) throw const CorruptFile('no schema');
    if (schema > supportedSchema) throw NewerSchema(schema);
    return json;
  }

  T _field<T>(Map<String, dynamic> json, String key) {
    final v = json[key];
    if (v is! T) throw CorruptFile('bad field $key');
    return v;
  }

  List<T> _records<T>(
    Map<String, dynamic> json,
    String key,
    T Function(Map<String, dynamic>) parse,
  ) {
    final list = _field<List<dynamic>>(json, key);
    try {
      return [for (final e in list) parse(e as Map<String, dynamic>)];
    } on CodecError {
      rethrow;
    } on Object catch (e) {
      throw CorruptFile('bad $key record: $e');
    }
  }

  /// A meta file.
  Uint8List encodeMeta(MetaFile meta) => _pack({
    'format': metaFormat,
    'schema': supportedSchema,
    'deviceId': meta.deviceId,
    'deviceName': meta.deviceName,
    'appVersion': meta.appVersion,
    'writtenAt': meta.writtenAt,
    'repertoires': [for (final r in meta.repertoires) r.toJson()],
  });

  /// Reads a meta file.
  MetaFile decodeMeta(List<int> bytes) {
    final json = _unpackObject(bytes, metaFormat);
    return MetaFile(
      deviceId: _field<String>(json, 'deviceId'),
      deviceName: _field<String>(json, 'deviceName'),
      appVersion: _field<String>(json, 'appVersion'),
      writtenAt: _field<int>(json, 'writtenAt'),
      repertoires: _records(json, 'repertoires', RepertoireRecord.fromJson),
    );
  }

  /// A run log: one run per line (JSONL), gzipped.
  Uint8List encodeRunLog(List<RunRecord> runs) => Uint8List.fromList(
    gzip.encode(
      utf8.encode([for (final r in runs) '${jsonEncode(r.toJson())}\n'].join()),
    ),
  );

  /// Reads a run log. A run with a newer schema makes the file unreadable
  /// ([NewerSchema]).
  List<RunRecord> decodeRunLog(List<int> bytes) {
    final text = _unpackText(bytes);
    final runs = <RunRecord>[];
    for (final line in const LineSplitter().convert(text)) {
      if (line.trim().isEmpty) continue;
      final Object? json;
      try {
        json = jsonDecode(line);
      } on FormatException catch (e) {
        throw CorruptFile('not JSON: ${e.message}');
      }
      if (json is! Map<String, dynamic>) throw const CorruptFile('not a run');
      final schema = json['schema'];
      if (schema is int && schema > supportedSchema) {
        throw NewerSchema(schema);
      }
      try {
        runs.add(RunRecord.fromJson(json));
      } on Object catch (e) {
        throw CorruptFile('bad run: $e');
      }
    }
    return runs;
  }

  /// A backup file.
  Uint8List encodeBackup(BackupFile backup) => _pack({
    'format': backupFormat,
    'schema': supportedSchema,
    'exportedAt': backup.exportedAt,
    'appVersion': backup.appVersion,
    'deviceId': backup.deviceId,
    'repertoires': [for (final r in backup.repertoires) r.toJson()],
    'runs': [for (final r in backup.runs) r.toJson()],
    'settings': backup.settings,
  });

  /// Reads a backup file.
  BackupFile decodeBackup(List<int> bytes) {
    final json = _unpackObject(bytes, backupFormat);
    final settings = json['settings'];
    return BackupFile(
      exportedAt: _field<int>(json, 'exportedAt'),
      appVersion: _field<String>(json, 'appVersion'),
      deviceId: _field<String>(json, 'deviceId'),
      repertoires: _records(json, 'repertoires', RepertoireRecord.fromJson),
      runs: _records(json, 'runs', RunRecord.fromJson),
      settings: settings is Map<String, dynamic> ? settings : const {},
    );
  }

  /// A backup whose runs are given as [runsJson], a JSON array of run
  /// objects in the [RunRecord] JSON form (the app builds it in SQL for
  /// large histories); `backup.runs` is ignored.
  Uint8List encodeBackupWithRuns(BackupFile backup, String runsJson) {
    // The placeholder string as jsonEncode writes it (NULs escaped).
    const marker = r'"\u0000runs\u0000"';
    final head = jsonEncode({
      'format': backupFormat,
      'schema': supportedSchema,
      'exportedAt': backup.exportedAt,
      'appVersion': backup.appVersion,
      'deviceId': backup.deviceId,
      'repertoires': [for (final r in backup.repertoires) r.toJson()],
      'runs': '\u0000runs\u0000',
      'settings': backup.settings,
    });
    final text = head.replaceFirst(marker, runsJson);
    return Uint8List.fromList(gzip.encode(utf8.encode(text)));
  }
}
