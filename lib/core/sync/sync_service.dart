import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:chess_core/chess_core.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:repertoire_trainer/app/version.dart';
import 'package:repertoire_trainer/core/db/merge_applier.dart';
import 'package:repertoire_trainer/core/db/repositories/repertoire_repository.dart';
import 'package:repertoire_trainer/core/db/repositories/run_repository.dart';
import 'package:repertoire_trainer/core/db/repositories/sync_state_repository.dart';
import 'package:repertoire_trainer/core/sync/drive_transport.dart';
import 'package:repertoire_trainer/core/sync/io_codec.dart';

final _log = Logger('SyncService');

/// Format generation of sync file names (06 §3).
const syncPrefix = 'rt1-';

/// `rt1-<deviceId>-meta.json.gz`.
String metaFileName(String deviceId) => '$syncPrefix$deviceId-meta.json.gz';

/// `rt1-<deviceId>-runs-<YYYY-MM>.jsonl.gz`.
String runsFileName(String deviceId, String month) =>
    '$syncPrefix$deviceId-runs-$month.jsonl.gz';

final _fileName = RegExp(
  r'^rt1-(.+)-(meta\.json\.gz|runs-\d{4}-\d{2}\.jsonl\.gz)$',
);

/// The writing device of a sync file, or null for other files.
String? deviceOfFile(String name) => _fileName.firstMatch(name)?.group(1);

// Isolate entry points take only their data: a closure inside a method
// would capture (and try to send) everything in scope.
Future<MetaFile> _decodeMeta(Uint8List bytes) =>
    Isolate.run(() => syncCodec.decodeMeta(bytes));

Future<List<RunRecord>> _decodeRunLog(Uint8List bytes) =>
    Isolate.run(() => syncCodec.decodeRunLog(bytes));

Future<Uint8List> _encodeMeta(MetaFile meta) =>
    Isolate.run(() => syncCodec.encodeMeta(meta));

Future<Uint8List> _encodeRunLog(List<RunRecord> runs) =>
    Isolate.run(() => syncCodec.encodeRunLog(runs));

/// Something a sync could not read (06 §7): the file is skipped.
@immutable
final class SyncWarning {
  /// Creates it.
  const new({required this.deviceId, required this.newerSchema});

  /// The device that wrote the file.
  final String deviceId;

  /// Written by a newer app version (else corrupt).
  final bool newerSchema;
}

/// What a sync did.
@immutable
final class SyncReport {
  /// Creates it.
  const new({
    required this.downloaded,
    required this.uploaded,
    required this.merge,
    required this.updatedFromOtherDevice,
    this.warnings = const [],
  });

  /// Files downloaded.
  final int downloaded;

  /// Files uploaded.
  final int uploaded;

  /// The merge of what was downloaded.
  final MergeReport merge;

  /// Names of known repertoires another device changed (the SnackBar).
  final List<String> updatedFromOtherDevice;

  /// Files skipped.
  final List<SyncWarning> warnings;
}

/// `sync_state` keys.
abstract final class SyncKeys {
  /// md5 of a processed remote file: `sync.md5.<name>`.
  static String md5(String name) => 'sync.md5.$name';

  /// Hash of the last uploaded meta content.
  static const metaHash = 'sync.metaHash';
}

/// What the sync controller runs (a fake in trigger tests).
abstract interface class Syncer {
  /// One sync.
  Future<SyncReport> sync();

  /// Deletes every device's sync files.
  Future<int> deleteCloudData();
}

/// The sync algorithm (docs/plan/06-sync.md §4): pull other devices'
/// changed files, merge, push this device's meta and unsynced months.
/// Decoding and encoding run on isolates; every step is idempotent, so a
/// failed sync is simply run again.
final class SyncService implements Syncer {
  /// Creates the service.
  new({
    required this.connect,
    required this.refreshAuth,
    required this.applier,
    required this.repertoires,
    required this.runs,
    required this.state,
    required this.deviceId,
    required this.clock,
    this.deviceName = '',
    Future<void> Function(Duration)? wait,
  }) : _wait = wait ?? Future<void>.delayed;

  /// An authorized transport.
  final Future<DriveTransport> Function() connect;

  /// After a 401: refresh the token (throws when sign-in is needed).
  final Future<void> Function() refreshAuth;

  /// Merge into the database.
  final MergeApplier applier;

  /// Repertoires.
  final RepertoireRepository repertoires;

  /// Runs.
  final RunRepository runs;

  /// md5 cache and meta hash.
  final SyncStateRepository state;

  /// This device.
  final Future<String> Function() deviceId;

  /// Time.
  final Clock clock;

  /// Shown in meta files.
  final String deviceName;

  final Future<void> Function(Duration) _wait;

  Future<SyncReport>? _running;

  /// Runs a sync; while one runs, callers share it (single flight).
  @override
  Future<SyncReport> sync() =>
      _running ??= _syncWithAuth().whenComplete(() => _running = null);

  Future<SyncReport> _syncWithAuth() async {
    try {
      return await _sync();
    } on SyncAuthExpired {
      // One silent refresh, then the whole (idempotent) sync again.
      await refreshAuth();
      return await _sync();
    }
  }

  /// Quota errors: wait 2, 4, 8 s, then give up until the next trigger.
  Future<T> _retry<T>(Future<T> Function() call) async {
    for (var delay = 2; ; delay *= 2) {
      try {
        return await call();
      } on SyncRateLimited {
        if (delay > 8) rethrow;
        await _wait(Duration(seconds: delay));
      }
    }
  }

  Future<SyncReport> _sync() async {
    final me = await deviceId();
    final drive = await connect();
    final files = await _retry(drive.list);
    final mine = {
      for (final f in files)
        if (deviceOfFile(f.name) == me) f.name: f,
    };
    // 1. Pull: other devices' files whose content changed, metas first.
    final changed = <DriveFile>[];
    for (final f in files) {
      final device = deviceOfFile(f.name);
      if (device == null || device == me) continue;
      if (await state.get(SyncKeys.md5(f.name)) == f.md5) continue;
      changed.add(f);
    }
    changed.sort((a, b) {
      final am = a.name.endsWith('meta.json.gz') ? 0 : 1;
      final bm = b.name.endsWith('meta.json.gz') ? 0 : 1;
      return am != bm ? am - bm : a.name.compareTo(b.name);
    });
    final remoteReps = <RepertoireRecord>[];
    final remoteRuns = <RunRecord>[];
    final processed = <DriveFile>[];
    final warnings = <SyncWarning>[];
    for (final f in changed) {
      final bytes = await _retry(() => drive.download(f.id));
      final device = deviceOfFile(f.name)!;
      try {
        if (f.name.endsWith('meta.json.gz')) {
          final meta = await _decodeMeta(bytes);
          remoteReps.addAll(meta.repertoires);
        } else {
          remoteRuns.addAll(await _decodeRunLog(bytes));
        }
        processed.add(f);
      } on NewerSchema {
        warnings.add(SyncWarning(deviceId: device, newerSchema: true));
      } on CodecError catch (e) {
        _log.warning('Skipping ${f.name}: $e');
        warnings.add(SyncWarning(deviceId: device, newerSchema: false));
      }
    }
    // 2. Merge and apply effects (one transaction, then re-derivation).
    final before = {for (final r in await repertoires.records()) r.id: r};
    final merge = await applier.apply(
      remote: remoteReps,
      incoming: remoteRuns,
      syncedAt: clock.now().millisecondsSinceEpoch,
    );
    for (final f in processed) {
      await state.set(SyncKeys.md5(f.name), f.md5);
    }
    final after = {for (final r in await repertoires.records()) r.id: r};
    final updated = [
      for (final id in merge.changedIds)
        if (before[id] case final old? when !old.deleted)
          if (after[id] case final now? when now.updatedBy != me) now.name,
    ];
    // 3. Push: the meta when its content changed, then unsynced months.
    var uploaded = 0;
    final records = after.values.toList()..sort((a, b) => a.id.compareTo(b.id));
    final metaHash = sha256
        .convert(utf8.encode(jsonEncode([for (final r in records) r.toJson()])))
        .toString();
    final metaName = metaFileName(me);
    if (metaHash != await state.get(SyncKeys.metaHash) ||
        !mine.containsKey(metaName)) {
      final meta = MetaFile(
        deviceId: me,
        deviceName: deviceName,
        appVersion: appVersion,
        writtenAt: clock.now().millisecondsSinceEpoch,
        repertoires: records,
      );
      final bytes = await _encodeMeta(meta);
      await _upload(drive, mine[metaName], metaName, bytes);
      await state.set(SyncKeys.metaHash, metaHash);
      uploaded++;
    }
    for (final month in await runs.unsyncedMonths(me)) {
      final monthRuns = await runs.deviceRunsInMonth(me, month);
      final bytes = await _encodeRunLog(monthRuns);
      final name = runsFileName(me, month);
      await _upload(drive, mine[name], name, bytes);
      await runs.markSynced([
        for (final r in monthRuns) r.id,
      ], clock.now().millisecondsSinceEpoch);
      uploaded++;
    }
    return SyncReport(
      downloaded: changed.length,
      uploaded: uploaded,
      merge: merge,
      updatedFromOtherDevice: updated,
      warnings: warnings,
    );
  }

  Future<void> _upload(
    DriveTransport drive,
    DriveFile? existing,
    String name,
    Uint8List bytes,
  ) async {
    if (existing == null) {
      await _retry(() => drive.create(name, bytes));
    } else {
      await _retry(() => drive.update(existing.id, bytes));
    }
  }

  /// Deletes every sync file of every device (Settings → Delete cloud
  /// data); local data and caches of remote files are forgotten too.
  @override
  Future<int> deleteCloudData() async {
    final drive = await connect();
    final n = await _retry(() => drive.deleteAll(syncPrefix));
    await state.remove(SyncKeys.metaHash);
    return n;
  }
}
