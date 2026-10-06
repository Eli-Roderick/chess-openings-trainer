import 'dart:async';

import 'package:chess_core/chess_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:repertoire_trainer/app/layout/adaptive_layout.dart';
import 'package:repertoire_trainer/app/routes.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/core/settings/app_settings.dart';
import 'package:repertoire_trainer/features/stats/stats_data.dart';
import 'package:repertoire_trainer/features/stats/stats_providers.dart';
import 'package:repertoire_trainer/features/stats/stats_screen.dart';
import 'package:repertoire_trainer/l10n/gen/app_localizations.dart';

/// The mark of a grade in run histories (✓ ½ ✗ ?, D-89).
String gradeMark(GradeResult r) => switch (r) {
  GradeResult.correct => '✓',
  GradeResult.comparable => '½',
  GradeResult.wrong => '✗',
  GradeResult.hint => '?',
};

/// Line detail (01-product-spec §11): numbers, weak and SRS state, run
/// history, per-move errors; archived lines read-only.
class LineDetailScreen extends ConsumerWidget {
  /// Line [lineKey] of repertoire [id].
  const new({required this.id, required this.lineKey, super.key});

  /// The repertoire.
  final String id;

  /// The line.
  final String lineKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final data = ref.watch(repertoireStatsProvider(id)).value;
    final all = ref.watch(lineStatsProvider(id)).value;
    final history = ref.watch(lineHistoryProvider((id, lineKey)));
    final settings = ref.watch(settingsProvider).value ?? const AppSettings();
    if (data == null || all == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.lineDetail)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final line = data.tree.lineByKey(lineKey);
    final stats = all.where((s) => s.lineKey == lineKey).firstOrNull;
    final sans = line != null
        ? [for (final n in line.path) n.san!]
        : sansOf(data.ucisByKey[lineKey] ?? '');
    final locale = Localizations.localeOf(context).toLanguageTag();
    String date(String day) =>
        DateFormat.yMMMd(locale).format(DateTime.parse(day));
    final srs = stats?.srs;
    final weak = stats?.weak;
    Widget row(String label, String value, {Key? key}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label)),
          const SizedBox(width: 12),
          Flexible(
            flex: 2,
            child: Text(
              value,
              key: key,
              textAlign: TextAlign.end,
              style: theme.textTheme.titleSmall,
            ),
          ),
        ],
      ),
    );
    Widget header(String text) => Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 8),
      child: Text(text, style: theme.textTheme.titleMedium),
    );
    final runs = history.value ?? const <RunRecord>[];
    final errors = plyErrors(runs);
    return Scaffold(
      appBar: AppBar(title: Text(data.labelOf(lineKey))),
      body: ListView(
        key: const Key('line-detail'),
        padding: const EdgeInsets.symmetric(
          horizontal: AdaptiveLayout.gutter,
          vertical: 16,
        ),
        children: [
          if (line == null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Chip(
                key: const Key('archived-chip'),
                label: Text(l10n.notInCurrentPgn),
              ),
            ),
          Text(formatSanMoves(sans), key: const Key('line-san')),
          const SizedBox(height: 12),
          row(
            l10n.statsAccuracy,
            percentOf(stats?.accuracy),
            key: const Key('line-accuracy'),
          ),
          row(l10n.statsRuns, '${stats?.runCount ?? 0}'),
          row(
            l10n.weakPool,
            weak == null || !weak.inPool
                ? l10n.notWeak
                : l10n.weakCleanRuns(
                    weak.cleanStreak,
                    settings.weakExitCleanRuns,
                  ),
            key: const Key('line-weak'),
          ),
          if (srs != null && line != null)
            row(l10n.srsState, switch (srs.phase) {
              SrsPhase.fresh => l10n.srsNew,
              _ => l10n.srsStateValue(
                date(srs.dueDay!),
                srs.intervalDays,
                srs.ease.toStringAsFixed(2),
              ),
            }, key: const Key('line-srs')),
          if (line != null) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  key: const Key('drill-this-line'),
                  icon: const Icon(Icons.play_arrow),
                  label: Text(l10n.drillThisLine),
                  onPressed: () => unawaited(
                    context.push(
                      Routes.train(
                        id,
                        mode: RunMode.single.name,
                        line: lineKey,
                      ),
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  key: const Key('browse-this-line'),
                  icon: const Icon(Icons.menu_book_outlined),
                  label: Text(l10n.browseThisLine),
                  onPressed: () => unawaited(
                    context.push(Routes.browse(id, node: line.leaf.id)),
                  ),
                ),
              ],
            ),
          ],
          header(l10n.moveErrors),
          if (errors.isEmpty)
            Text(l10n.noRunsYet)
          else
            for (final e in errors)
              if (e.ply <= sans.length)
                row(
                  formatSanMoves([sans[e.ply - 1]], firstPly: e.ply),
                  l10n.missedCount(e.misses, e.attempts),
                ),
          header(l10n.runHistory),
          if (history.isLoading && runs.isEmpty)
            const LinearProgressIndicator()
          else if (runs.isEmpty)
            Text(l10n.noRunsYet)
          else
            for (final r in runs.reversed)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  '${date(r.localDay)} · ${_modeName(l10n, r.mode)}'
                  '${r.completed ? '' : ' · ${l10n.abandoned}'}',
                ),
                subtitle: Text(
                  r.grades.map((g) => gradeMark(g.result)).join(' '),
                  key: const Key('run-marks'),
                ),
                trailing: Text(
                  r.gradedCount == 0 ? '-' : percentOf(r.accuracy),
                ),
              ),
        ],
      ),
    );
  }
}

String _modeName(AppLocalizations l10n, RunMode mode) => switch (mode) {
  RunMode.random => l10n.modeRandom,
  RunMode.weak => l10n.modeWeak,
  RunMode.srs => l10n.modeSrs,
  RunMode.single => l10n.modeSingle,
};
