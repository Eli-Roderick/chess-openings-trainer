import 'dart:convert';

import 'package:chess_core/src/sync/records.dart';
import 'package:chess_core/src/training/run.dart';
import 'package:meta/meta.dart';

/// The winner of two versions of one repertoire (docs/plan/06-sync.md §1):
/// newer `updatedAt`, then larger `updatedBy`. Versions equal in both are
/// ordered by their JSON so every device picks the same one.
RepertoireRecord newerRecord(RepertoireRecord a, RepertoireRecord b) {
  if (a.updatedAt != b.updatedAt) return a.updatedAt > b.updatedAt ? a : b;
  final byDevice = a.updatedBy.compareTo(b.updatedBy);
  if (byDevice != 0) return byDevice > 0 ? a : b;
  return jsonEncode(a.toJson()).compareTo(jsonEncode(b.toJson())) >= 0 ? a : b;
}

/// Result of [mergeRepertoires].
@immutable
final class RepertoireMerge {
  /// Creates it.
  const new({required this.winners, required this.changedIds});

  /// Every repertoire after the merge, by id.
  final Map<String, RepertoireRecord> winners;

  /// Ids whose record differs from the local one (new ones included).
  final Set<String> changedIds;
}

/// Merges [remote] records into [local] ones, per record last writer
/// wins. Commutative, associative and idempotent on the winners.
RepertoireMerge mergeRepertoires(
  Iterable<RepertoireRecord> local,
  Iterable<RepertoireRecord> remote,
) {
  final before = {for (final r in local) r.id: r};
  final winners = {...before};
  for (final r in remote) {
    final current = winners[r.id];
    winners[r.id] = current == null ? r : newerRecord(current, r);
  }
  return RepertoireMerge(
    winners: winners,
    changedIds: {
      for (final e in winners.entries)
        if (before[e.key] != e.value) e.key,
    },
  );
}

/// What applying a merge must do to derived and local data, as data
/// (docs/plan/06-sync.md §4 step 2).
@immutable
final class MergeEffects {
  /// Creates it.
  const new({
    this.rebuildTrees = const {},
    this.deleteRepertoires = const {},
    this.rederive = const {},
  });

  /// Repertoires whose nodes and lines must be rebuilt from the PGN (new,
  /// changed PGN, or no longer deleted).
  final Set<String> rebuildTrees;

  /// Repertoires that became deleted: drop their nodes, lines, stats and
  /// runs.
  final Set<String> deleteRepertoires;

  /// Repertoires whose stats must be derived again.
  final Set<String> rederive;
}

/// The effects of [merge] given the records [before] it and the
/// repertoires that received new runs.
MergeEffects mergeEffects(
  Map<String, RepertoireRecord> before,
  RepertoireMerge merge, {
  Set<String> newRuns = const {},
}) {
  final rebuild = <String>{};
  final delete = <String>{};
  for (final id in merge.changedIds) {
    final winner = merge.winners[id]!;
    final old = before[id];
    if (winner.deleted) {
      if (old != null && !old.deleted) delete.add(id);
    } else if (old == null || old.deleted || old.pgnHash != winner.pgnHash) {
      rebuild.add(id);
    }
  }
  final deleted = {
    for (final e in merge.winners.entries)
      if (e.value.deleted) e.key,
  };
  return MergeEffects(
    rebuildTrees: rebuild,
    deleteRepertoires: delete,
    rederive: {...rebuild, ...newRuns.difference(deleted)},
  );
}

/// Runs of [incoming] to store: unknown ids (union by id) whose
/// repertoire is not deleted. Runs of repertoires not known yet are kept.
List<RunRecord> runsToInsert(
  Iterable<RunRecord> incoming, {
  required Set<String> knownIds,
  required Set<String> deletedRepertoires,
}) {
  final seen = {...knownIds};
  return [
    for (final r in incoming)
      if (!deletedRepertoires.contains(r.repertoireId) && seen.add(r.id)) r,
  ];
}
