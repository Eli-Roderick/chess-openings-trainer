import 'package:chess_core/chess_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show FutureProviderFamily;
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/core/db/stats_queries.dart';
import 'package:repertoire_trainer/features/stats/stats_data.dart';

/// Everything the stats screen shows that is not in `line_stats`
/// (P10 task 1), loaded together.
@immutable
final class RepertoireStatsData {
  /// Creates it.
  const new({
    required this.tree,
    required this.daily,
    required this.missed,
    required this.deviations,
    required this.completedRuns,
    required this.ucisByKey,
  });

  /// The repertoire.
  final RepertoireTree tree;

  /// Completed runs per day.
  final List<DailyAggregate> daily;

  /// Most-missed user moves.
  final List<MissedMove> missed;

  /// Deviation replies.
  final DeviationSummary deviations;

  /// Completed runs.
  final int completedRuns;

  /// Move sequence per line key with runs (archived labels).
  final Map<String, String> ucisByKey;

  /// Label of [key]: the current line's, or one built from its moves.
  String labelOf(String key) =>
      tree.lineByKey(key)?.label ??
      switch (ucisByKey[key]) {
        final ucis? => ucisLabel(ucis),
        null => key,
      };
}

/// Stats data of a repertoire; reloads whenever its line stats change
/// (after every stored run).
final FutureProviderFamily<RepertoireStatsData, String>
repertoireStatsProvider = FutureProvider.family<RepertoireStatsData, String>((
  ref,
  id,
) async {
  ref.watch(lineStatsProvider(id));
  final queries = ref.watch(statsQueriesProvider);
  final tree = await ref.watch(repertoireTreeProvider(id).future);
  final (daily, misses, deviations, runs, ucis) = await (
    queries.daily(id),
    queries.plyMisses(id),
    queries.deviations(id),
    queries.completedRuns(id),
    queries.ucisByKey(id),
  ).wait;
  return RepertoireStatsData(
    tree: tree,
    daily: daily,
    missed: mostMissed(tree, misses),
    deviations: deviations,
    completedRuns: runs,
    ucisByKey: ucis,
  );
});

/// The run history of one line (current or archived), oldest first.
final FutureProviderFamily<List<RunRecord>, (String, String)>
lineHistoryProvider = FutureProvider.family<List<RunRecord>, (String, String)>((
  ref,
  args,
) async {
  final (id, key) = args;
  ref.watch(lineStatsProvider(id));
  final runs = ref.watch(runRepositoryProvider);
  final refs = await ref.watch(lineRefsProvider(id).future);
  final index = LineIndex(refs);
  final current = refs.where((l) => l.key == key).firstOrNull;
  final candidates = current == null
      ? await runs.runsForKey(id, key)
      : await runs.runsAlong(id, current.ucis);
  return lineHistory(index, key, candidates);
});
