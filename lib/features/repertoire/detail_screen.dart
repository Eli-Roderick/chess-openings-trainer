import 'package:chess_core/chess_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:repertoire_trainer/app/layout/adaptive_layout.dart';
import 'package:repertoire_trainer/app/routes.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/core/settings/app_settings.dart';
import 'package:repertoire_trainer/features/board/repertoire_actions.dart';
import 'package:repertoire_trainer/l10n/gen/app_localizations.dart';

/// Numbers shown on the detail screen (01-product-spec §6).
@immutable
final class RepertoireDetailCounts {
  /// Creates counts.
  const new({
    required this.trained,
    required this.total,
    required this.newAvailableToday,
  });

  /// Derives the counts from line stats, lines and settings for [today].
  factory from({
    required List<LineStats> stats,
    required List<LineRef> lines,
    required AppSettings settings,
    required String today,
  }) {
    final current = {for (final l in lines) l.key: l};
    final byKey = {for (final s in stats) s.lineKey: s};
    final trained = [
      for (final l in lines)
        if ((byKey[l.key]?.runCount ?? 0) > 0) l,
    ].length;
    final newToday = stats
        .where((s) => !s.archived && s.srs.firstSeenDay == today)
        .length;
    final fresh = [
      for (final l in lines)
        if (l.isTrainable &&
            (byKey[l.key]?.srs ?? SrsState.initial).phase == SrsPhase.fresh)
          l,
    ].length;
    final allowed = (settings.srsNewPerDay - newToday).clamp(0, 1 << 30);
    return RepertoireDetailCounts(
      trained: trained,
      total: current.length,
      newAvailableToday: allowed < fresh ? allowed : fresh,
    );
  }

  /// Lines with at least one eligible run.
  final int trained;

  /// Current lines.
  final int total;

  /// New lines SRS may still introduce today.
  final int newAvailableToday;
}

/// Repertoire detail (01-product-spec §6). Train, Browse and Stats open
/// their screens (built in P05-P10).
class RepertoireDetailScreen extends ConsumerWidget {
  /// Detail of repertoire [id].
  const new({required this.id, super.key});

  /// Repertoire id.
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final summaries = ref.watch(repertoireSummariesProvider);
    final summary = summaries.value?.where((s) => s.id == id).firstOrNull;
    if (summary == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: summaries.isLoading
              ? const CircularProgressIndicator()
              : Text(l10n.loadError('not found')),
        ),
      );
    }
    final stats = ref.watch(lineStatsProvider(id)).value ?? const [];
    final lines = ref.watch(lineRefsProvider(id)).value ?? const [];
    final settings = ref.watch(settingsProvider).value ?? const AppSettings();
    final counts = RepertoireDetailCounts.from(
      stats: stats,
      lines: lines,
      settings: settings,
      today: ref.watch(todayProvider),
    );
    final accuracy = summary.accuracy;
    final messenger = ScaffoldMessenger.of(context);

    Future<void> onMenu(_Menu item) async {
      switch (item) {
        case _Menu.rename:
          await renameRepertoire(
            context,
            ref,
            id: id,
            currentName: summary.name,
          );
        case _Menu.reimport:
          await context.push(Routes.reimport(id));
          ref.invalidate(lineRefsProvider(id));
        case _Menu.export:
          await exportRepertoirePgn(context, ref, id: id);
        case _Menu.delete:
          final deleted = await deleteRepertoire(
            context,
            ref,
            id: id,
            name: summary.name,
            messenger: messenger,
          );
          if (deleted && context.mounted) context.go(Routes.home);
        case _Menu.validate:
          await context.push(Routes.validate(id));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(summary.name),
        actions: [
          PopupMenuButton<_Menu>(
            key: const Key('detail-menu'),
            onSelected: onMenu,
            itemBuilder: (context) => [
              for (final m in _Menu.values)
                PopupMenuItem(
                  key: Key('detail-${m.name}'),
                  value: m,
                  child: Text(m.label(l10n)),
                ),
            ],
          ),
        ],
      ),
      body: AdaptiveLayout(
        phone: ListView(
          padding: const EdgeInsets.all(AdaptiveLayout.gutter),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    _Row(
                      l10n.colourLabel,
                      summary.color.name == 'white'
                          ? l10n.colorWhite
                          : l10n.colorBlack,
                    ),
                    _Row(
                      l10n.reportLines,
                      '${summary.lineCount}',
                      key: const Key('detail-lines'),
                    ),
                    _Row(
                      l10n.detailAccuracy,
                      accuracy == null
                          ? l10n.notTrained
                          : l10n.accuracyValue(accuracyPercent(accuracy)),
                    ),
                    _Row(
                      l10n.detailCoverage,
                      l10n.detailCoverageValue(counts.trained, counts.total),
                    ),
                    _Row(l10n.detailWeak, '${summary.weakCount}'),
                    _Row(l10n.detailDue, '${summary.dueCount}'),
                    _Row(l10n.detailNewToday, '${counts.newAvailableToday}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              key: const Key('train'),
              icon: const Icon(Icons.play_arrow),
              label: Text(l10n.train),
              onPressed: () => context.push(Routes.train(id)),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    key: const Key('browse'),
                    icon: const Icon(Icons.account_tree_outlined),
                    label: Text(l10n.browse),
                    onPressed: () => context.push(Routes.browse(id)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    key: const Key('stats'),
                    icon: const Icon(Icons.insights_outlined),
                    label: Text(l10n.stats),
                    onPressed: () => context.push(Routes.stats(id)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const new(this.label, this.value, {super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        Text(value, style: Theme.of(context).textTheme.titleSmall),
      ],
    ),
  );
}

enum _Menu {
  rename,
  reimport,
  export,
  delete,
  validate;

  String label(AppLocalizations l10n) => switch (this) {
    rename => l10n.rename,
    reimport => l10n.reimport,
    export => l10n.exportPgn,
    delete => l10n.delete,
    validate => l10n.validateStored,
  };
}
