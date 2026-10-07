import 'package:chess_core/chess_core.dart';
import 'package:repertoire_trainer/core/db/app_database.dart';
import 'package:repertoire_trainer/core/db/merge_applier.dart';
import 'package:repertoire_trainer/core/db/repositories/repertoire_repository.dart';
import 'package:repertoire_trainer/core/db/repositories/snapshot_repository.dart';
import 'package:repertoire_trainer/core/db/stats_service.dart';

/// A saved version that cannot be restored.
final class VersionNotRestorable implements Exception {
  /// Creates it.
  const new(this.reason);

  /// Why (for the log; the screen shows its own text).
  final String reason;

  @override
  String toString() => 'Version not restorable: $reason';
}

/// Restores saved versions and deleted repertoires, and empties the trash
/// (audit R4). Every restore is one transaction with its re-derivation.
final class RecoveryService {
  /// Creates the service.
  new({
    required this.db,
    required this.repertoires,
    required this.snapshots,
    required this.stats,
    required this.buildTree,
    required this.clock,
    required this.deviceId,
  });

  /// The database (transactions).
  final AppDatabase db;

  /// Repertoires.
  final RepertoireRepository repertoires;

  /// Saved versions.
  final SnapshotRepository snapshots;

  /// Re-derivation.
  final StatsService stats;

  /// PGN → tree.
  final TreeBuilder buildTree;

  /// Time.
  final Clock clock;

  /// This device.
  final Future<String> Function() deviceId;

  /// Makes saved version [snapshotId] the current version of its
  /// repertoire (undeleting it if needed). The replaced version is saved
  /// first. Runs are kept; stats are derived again. Throws
  /// [VersionNotRestorable] for a rejected version or one that does not
  /// import.
  Future<void> restoreVersion(int snapshotId) async {
    final s = await snapshots.get(snapshotId);
    if (s == null) throw const VersionNotRestorable('unknown version');
    if (s.reason == SnapshotReason.rejected) {
      throw const VersionNotRestorable('rejected version');
    }
    RepertoireTree? tree;
    try {
      tree = await buildTree(s.record);
    } on Object catch (e) {
      throw VersionNotRestorable('does not import: $e');
    }
    if (tree == null) throw const VersionNotRestorable('does not import');
    final current = await repertoires.get(s.repertoireId);
    final device = await deviceId();
    final now = clock.now().millisecondsSinceEpoch;
    // Newer than the current record, so sync spreads the restore.
    final at = current != null && current.updatedAt >= now
        ? current.updatedAt + 1
        : now;
    await db.transaction(() async {
      if (current != null &&
          !current.deleted &&
          current.pgnHash != s.record.pgnHash) {
        await saveSnapshot(
          db,
          repertoireRecordOf(current),
          SnapshotReason.reimport,
          now: now,
        );
      }
      await repertoires.putRecord(
        s.record.copyWith(
          name: current?.name ?? s.record.name,
          createdAt: current?.createdAt ?? s.record.createdAt,
          updatedAt: at,
          updatedBy: device,
          deleted: false,
        ),
        tree: tree,
      );
      await stats.rebuildRepertoire(s.repertoireId);
    });
  }

  /// Brings deleted repertoire [repertoireId] back: with its stats when
  /// its data is still on this device, else from its newest saved
  /// version.
  Future<void> restoreDeleted(String repertoireId) async {
    if ((await repertoires.lineRefs(repertoireId)).isNotEmpty &&
        await repertoires.get(repertoireId) != null) {
      await repertoires.undoDelete(repertoireId);
      return;
    }
    final latest = await snapshots.latestRestorable(repertoireId);
    if (latest == null) throw const VersionNotRestorable('no saved version');
    await restoreVersion(latest.id);
  }

  /// Deletes repertoire [repertoireId] for good: its tree, runs, stats and
  /// saved versions (the sync tombstone stays).
  Future<void> deleteForever(String repertoireId) => db.transaction(() async {
    if (await repertoires.get(repertoireId) != null) {
      await repertoires.purge(repertoireId);
    }
    await snapshots.deleteForRepertoire(repertoireId);
  });
}
