import 'package:chess_core/chess_core.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:repertoire_trainer/core/db/app_database.dart';
import 'package:repertoire_trainer/core/db/repositories/repertoire_repository.dart';
import 'package:repertoire_trainer/core/db/repositories/run_repository.dart';
import 'package:repertoire_trainer/core/db/repositories/snapshot_repository.dart';
import 'package:repertoire_trainer/core/db/stats_service.dart';

final _log = Logger('MergeApplier');

/// Builds the tree of a stored PGN (an isolate import in the app); null
/// when the PGN no longer imports.
typedef TreeBuilder = Future<RepertoireTree?> Function(RepertoireRecord record);

/// What a merge changed.
@immutable
final class MergeReport {
  /// Creates it.
  const new({
    required this.changedIds,
    required this.effects,
    required this.insertedRuns,
    this.failedTrees = const {},
    this.rejected = const [],
  });

  /// Repertoires whose record changed locally (rejected ones excluded).
  final Set<String> changedIds;

  /// What was rebuilt, deleted and derived again.
  final MergeEffects effects;

  /// Runs added.
  final int insertedRuns;

  /// Repertoires whose incoming PGN did not import: the local version
  /// (PGN, tree and record) was kept unchanged.
  final Set<String> failedTrees;

  /// The incoming versions that did not import (saved as rejected
  /// snapshots for inspection).
  final List<RepertoireRecord> rejected;
}

/// A "Replace all" restore was stopped before anything changed because
/// these incoming repertoires do not import.
final class RestoreAborted implements Exception {
  /// Creates it.
  const new(this.names);

  /// Names of the repertoires that do not import.
  final List<String> names;

  @override
  String toString() =>
      'Restore stopped; these do not import: '
      '${names.join(', ')}';
}

/// Applies merged repertoires and runs (sync pull and backup import,
/// docs/plan/06-sync.md §4 step 2). Every incoming PGN is imported first;
/// then records, tombstones, runs and the derived stats are written in one
/// transaction, so a failure at any step leaves the database as it was
/// (audit R1). Local versions that are replaced or deleted, and incoming
/// versions that do not import, are saved as snapshots (audit R2, R4).
final class MergeApplier {
  /// Creates the applier.
  new({
    required this.db,
    required this.repertoires,
    required this.runs,
    required this.stats,
    required this.buildTree,
    required this.clock,
    @visibleForTesting this.debugHook,
  });

  /// The database (transaction).
  final AppDatabase db;

  /// Repertoires.
  final RepertoireRepository repertoires;

  /// Runs.
  final RunRepository runs;

  /// Re-derivation.
  final StatsService stats;

  /// PGN → tree.
  final TreeBuilder buildTree;

  /// Snapshot times.
  final Clock clock;

  /// Called with each stage name (`trees`, `snapshots`, `records`, `runs`,
  /// `derive`); tests throw from it to check the rollback.
  final void Function(String stage)? debugHook;

  /// Merges [remote] repertoires and [incoming] runs into the database;
  /// the runs of backup document [backupDoc] (`BackupQueries`) are added in
  /// SQLite. Inserted runs count as synced at [syncedAt] if given. With
  /// [replaceAll], every local repertoire and run is deleted in the same
  /// transaction (backup "Replace all"); it throws [RestoreAborted] before
  /// changing anything when an incoming repertoire does not import.
  Future<MergeReport> apply({
    required List<RepertoireRecord> remote,
    List<RunRecord> incoming = const [],
    int? backupDoc,
    int? syncedAt,
    bool replaceAll = false,
  }) async {
    final existing = await repertoires.records();
    final local = replaceAll ? const <RepertoireRecord>[] : existing;
    final before = {for (final r in local) r.id: r};
    final merge = mergeRepertoires(local, remote);
    final planned = mergeEffects(before, merge);
    // Trees are built before the transaction (isolate imports).
    final trees = <String, RepertoireTree>{};
    final failed = <String>{};
    for (final id in planned.rebuildTrees) {
      RepertoireTree? tree;
      try {
        tree = await buildTree(merge.winners[id]!);
      } on Object catch (e, st) {
        _log.warning('Import of the incoming PGN of $id failed', e, st);
      }
      if (tree == null) {
        _log.warning('Incoming PGN of $id does not import; local kept');
        failed.add(id);
      } else {
        trees[id] = tree;
      }
    }
    if (replaceAll && failed.isNotEmpty) {
      throw RestoreAborted([for (final id in failed) merge.winners[id]!.name]);
    }
    debugHook?.call('trees');
    final rejected = [for (final id in failed) merge.winners[id]!];
    final changed = merge.changedIds.difference(failed);
    final deleted = {
      for (final e in merge.winners.entries)
        if (e.value.deleted && !failed.contains(e.key)) e.key,
    };
    final candidates = runsToInsert(
      incoming,
      knownIds: const {},
      deletedRepertoires: deleted,
    );
    final now = clock.now().millisecondsSinceEpoch;
    var inserted = const <RunRecord>[];
    var bulk = const <String, int>{};
    late MergeEffects effects;
    await db.transaction(() async {
      if (replaceAll) {
        for (final r in existing) {
          if (!r.deleted) {
            await saveSnapshot(db, r, SnapshotReason.restore, now: now);
          }
        }
      }
      for (final r in rejected) {
        await saveSnapshot(db, r, SnapshotReason.rejected, now: now);
      }
      for (final id in changed) {
        final old = before[id];
        final winner = merge.winners[id]!;
        if (old != null && !old.deleted) {
          if (winner.deleted) {
            await saveSnapshot(db, old, SnapshotReason.deleted, now: now);
          } else if (old.pgnHash != winner.pgnHash) {
            await saveSnapshot(db, old, SnapshotReason.replaced, now: now);
          }
        }
      }
      debugHook?.call('snapshots');
      if (replaceAll) await repertoires.deleteAll();
      // A PGN that fails to import changes nothing: an existing repertoire
      // keeps its whole record (PGN, hash and tree stay consistent), a new
      // one is not added.
      for (final id in changed) {
        await repertoires.putRecord(merge.winners[id]!, tree: trees[id]);
      }
      for (final id in planned.deleteRepertoires) {
        await repertoires.purge(id);
      }
      debugHook?.call('records');
      inserted = await runs.insertIfAbsent(candidates, syncedAt: syncedAt);
      if (backupDoc != null) {
        bulk = await runs.importBackupRuns(backupDoc, syncedAt: syncedAt);
      }
      debugHook?.call('runs');
      effects = mergeEffects(
        before,
        merge,
        newRuns: {for (final r in inserted) r.repertoireId, ...bulk.keys},
      );
      for (final id in effects.rederive) {
        final known = failed.contains(id) ? before[id] : merge.winners[id];
        // Runs of a repertoire not known yet wait for its record.
        if (known == null || known.deleted) continue;
        await stats.rebuildRepertoire(id);
        debugHook?.call('derive');
      }
    });
    return MergeReport(
      changedIds: changed,
      effects: MergeEffects(
        rebuildTrees: effects.rebuildTrees.difference(failed),
        deleteRepertoires: effects.deleteRepertoires,
        rederive: effects.rederive,
      ),
      insertedRuns: inserted.length + bulk.values.fold(0, (a, b) => a + b),
      failedTrees: failed,
      rejected: rejected,
    );
  }
}
