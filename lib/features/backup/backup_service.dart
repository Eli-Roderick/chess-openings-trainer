import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:chess_core/chess_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repertoire_trainer/app/version.dart';
import 'package:repertoire_trainer/core/db/backup_queries.dart';
import 'package:repertoire_trainer/core/db/merge_applier.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/core/db/repositories/repertoire_repository.dart';
import 'package:repertoire_trainer/core/db/repositories/run_repository.dart';
import 'package:repertoire_trainer/core/db/repositories/settings_repository.dart';
import 'package:repertoire_trainer/core/files/file_service.dart';
import 'package:repertoire_trainer/core/settings/app_settings.dart';
import 'package:repertoire_trainer/core/sync/io_codec.dart';

/// `repertoire-trainer-backup-YYYYMMDD-HHMM.rtbackup` for [local] time
/// (docs/plan/06-sync.md §8).
String backupFileName(DateTime local) {
  String two(int n) => n.toString().padLeft(2, '0');
  return 'repertoire-trainer-backup-${local.year}${two(local.month)}'
      '${two(local.day)}-${two(local.hour)}${two(local.minute)}'
      '.$backupExtension';
}

// Isolate entry points take only their data (a closure in a method would
// capture everything in scope).
Future<Uint8List> _encode(BackupFile header, String runsJson) =>
    Isolate.run(() => syncCodec.encodeBackupWithRuns(header, runsJson));

Future<String> _unpack(Uint8List bytes) => Isolate.run(() {
  try {
    return utf8.decode(syncCodec.gzip.decode(bytes));
  } on Object catch (e) {
    throw CorruptFile('not gzip/UTF-8: $e');
  }
});

/// Settings that describe this machine, never restored from a backup.
const _machineSettings = {'engineVariant'};

/// Manual backup export and import (P11 task 4).
final class BackupService {
  /// Creates the service.
  new({
    required this.repertoires,
    required this.runs,
    required this.settings,
    required this.applier,
    required this.queries,
    required this.deviceId,
    required this.clock,
  });

  /// Repertoires.
  final RepertoireRepository repertoires;

  /// Runs.
  final RunRepository runs;

  /// Settings.
  final SettingsRepository settings;

  /// Merge (shared with sync).
  final MergeApplier applier;

  /// Backup JSON checks in SQLite.
  final BackupQueries queries;

  /// This device.
  final Future<String> Function() deviceId;

  /// Time.
  final Clock clock;

  /// The backup of everything: non-deleted repertoires, all runs (JSON
  /// built by SQLite), the settings; compressed on an isolate.
  Future<({String fileName, Uint8List bytes})> export() async {
    final now = clock.now();
    final header = BackupFile(
      exportedAt: now.millisecondsSinceEpoch,
      appVersion: appVersion,
      deviceId: await deviceId(),
      repertoires: [
        for (final r in await repertoires.records())
          if (!r.deleted) r,
      ],
      runs: const [],
      settings: (await settings.load()).toJson(),
    );
    final runsJson = await runs.exportRunsJson();
    final bytes = await _encode(header, runsJson);
    return (fileName: backupFileName(now.toLocal()), bytes: bytes);
  }

  /// Unpacks [bytes] on an isolate and checks them in SQLite; throws a
  /// [CodecError] when they are not a readable backup. Runs stay JSON
  /// until the import.
  Future<RawBackup> read(Uint8List bytes) async {
    final text = await _unpack(bytes);
    return await queries.inspect(text);
  }

  /// Imports [backup]: a merge (like sync), or with [replace] everything
  /// local is replaced. Either way it is one transaction: on any failure
  /// the local data stays as it was, and "Replace all" throws
  /// [RestoreAborted] before changing anything when a repertoire of the
  /// backup does not import. [restoreSettings] also applies its settings.
  Future<MergeReport> import(
    RawBackup backup, {
    required bool replace,
    required bool restoreSettings,
  }) async {
    final MergeReport report;
    try {
      report = await applier.apply(
        remote: backup.header.repertoires,
        backupDoc: backup.docId,
        replaceAll: replace,
      );
    } finally {
      await queries.clear();
    }
    if (restoreSettings) {
      final restored = {
        for (final e in backup.header.settings.entries)
          if (!_machineSettings.contains(e.key)) e.key: e.value,
      };
      await settings.update((current) {
        try {
          return AppSettings.fromJson({...current.toJson(), ...restored});
        } on Object {
          return current;
        }
      });
    }
    return report;
  }
}

/// The app's backup service.
final backupServiceProvider = Provider<BackupService>(
  (ref) => BackupService(
    repertoires: ref.watch(repertoireRepositoryProvider),
    runs: ref.watch(runRepositoryProvider),
    settings: ref.watch(settingsRepositoryProvider),
    applier: ref.watch(mergeApplierProvider),
    queries: BackupQueries(ref.watch(databaseProvider)),
    deviceId: () => ref.read(deviceIdProvider.future),
    clock: ref.watch(clockProvider),
  ),
);
