import 'package:chess_core/chess_core.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:repertoire_trainer/core/db/app_database.dart';
import 'package:repertoire_trainer/core/db/repositories/repertoire_repository.dart';
import 'package:repertoire_trainer/core/db/repositories/run_repository.dart';
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
  });

  /// Repertoires whose record changed locally.
  final Set<String> changedIds;

  /// What was rebuilt, deleted and derived again.
  final MergeEffects effects;

  /// Runs added.
  final int insertedRuns;

  /// Repertoires whose PGN did not import (kept without a tree change).
  final Set<String> failedTrees;
}

/// Applies merged repertoires and runs (sync pull and backup import,
/// docs/plan/06-sync.md §4 step 2): records, tombstones and runs in one
/// transaction, then derived stats again.
final class MergeApplier {
  /// Creates the applier.
  new({
    required this.db,
    required this.repertoires,
    required this.runs,
    required this.stats,
    required this.buildTree,
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

  /// Merges [remote] repertoires and [incoming] runs into the database;
  /// the runs of backup document [backupDoc] (`BackupQueries`) are added in
  /// SQLite. Inserted runs count as synced at [syncedAt] if given.
  Future<MergeReport> apply({
    required List<RepertoireRecord> remote,
    List<RunRecord> incoming = const [],
    int? backupDoc,
    int? syncedAt,
  }) async {
    final local = await repertoires.records();
    final before = {for (final r in local) r.id: r};
    final merge = mergeRepertoires(local, remote);
    final planned = mergeEffects(before, merge);
    // Trees are built before the transaction (isolate imports).
    final trees = <String, RepertoireTree>{};
    final failed = <String>{};
    for (final id in planned.rebuildTrees) {
      final tree = await buildTree(merge.winners[id]!);
      if (tree == null) {
        _log.warning('Stored PGN of $id does not import; tree kept');
        failed.add(id);
      } else {
        trees[id] = tree;
      }
    }
    final deleted = {
      for (final e in merge.winners.entries)
        if (e.value.deleted) e.key,
    };
    final candidates = runsToInsert(
      incoming,
      knownIds: const {},
      deletedRepertoires: deleted,
    );
    var inserted = const <RunRecord>[];
    var bulk = const <String, int>{};
    await db.transaction(() async {
      for (final id in merge.changedIds) {
        final old = before[id];
        // A PGN that fails to import: an existing repertoire keeps its old
        // tree but takes the winning name and flags; one without a tree
        // here is not added.
        if (failed.contains(id) && (old == null || old.deleted)) continue;
        await repertoires.putRecord(merge.winners[id]!, tree: trees[id]);
      }
      for (final id in planned.deleteRepertoires) {
        await repertoires.purge(id);
      }
      inserted = await runs.insertIfAbsent(candidates, syncedAt: syncedAt);
      if (backupDoc != null) {
        bulk = await runs.importBackupRuns(backupDoc, syncedAt: syncedAt);
      }
    });
    final effects = mergeEffects(
      before,
      merge,
      newRuns: {for (final r in inserted) r.repertoireId, ...bulk.keys},
    );
    for (final id in effects.rederive) {
      final winner = merge.winners[id];
      // Runs of a repertoire not known yet wait for its record.
      if (winner == null || winner.deleted || failed.contains(id)) continue;
      await stats.rebuildRepertoire(id);
    }
    return MergeReport(
      changedIds: merge.changedIds,
      effects: effects,
      insertedRuns: inserted.length + bulk.values.fold(0, (a, b) => a + b),
      failedTrees: failed,
    );
  }
}
