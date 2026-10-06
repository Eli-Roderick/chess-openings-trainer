import 'dart:async';
import 'dart:math' as math;

import 'package:chess_core/chess_core.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:repertoire_trainer/app/layout/adaptive_layout.dart';
import 'package:repertoire_trainer/app/routes.dart';
import 'package:repertoire_trainer/app/theme/colors.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/core/errors/describe_error.dart';
import 'package:repertoire_trainer/features/stats/stats_data.dart';
import 'package:repertoire_trainer/features/stats/stats_providers.dart';
import 'package:repertoire_trainer/l10n/gen/app_localizations.dart';

/// "84 %" or "-".
String percentOf(double? accuracy) =>
    accuracy == null ? '-' : '${accuracyPercent(accuracy)} %';

/// Repertoire stats (01-product-spec §11): summary tiles, accuracy chart,
/// worst lines, most-missed moves, deviation replies.
class StatsScreen extends ConsumerWidget {
  /// Stats of repertoire [id].
  const new({required this.id, super.key});

  /// The repertoire.
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final name = ref
        .watch(repertoireSummariesProvider)
        .value
        ?.where((s) => s.id == id)
        .firstOrNull
        ?.name;
    final data = ref.watch(repertoireStatsProvider(id));
    final stats = ref.watch(lineStatsProvider(id));
    return Scaffold(
      appBar: AppBar(
        title: Text(name == null ? l10n.stats : l10n.statsOf(name)),
      ),
      body: switch ((data, stats)) {
        (AsyncValue(:final error?), _) || (_, AsyncValue(:final error?)) =>
          Center(child: Text(l10n.loadError(describeError(error)))),
        (AsyncValue(value: final d?), AsyncValue(value: final s?)) =>
          _StatsBody(id: id, data: d, stats: s),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _StatsBody extends ConsumerWidget {
  const new({required this.id, required this.data, required this.stats});

  final String id;
  final RepertoireStatsData data;
  final List<LineStats> stats;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final today = ref.watch(todayProvider);
    final streak = ref.watch(streakProvider).value;
    final tree = data.tree;
    final current = [
      for (final s in stats)
        if (!s.archived && tree.lineByKey(s.lineKey) != null) s,
    ];
    final trainable = tree.lines.where((l) => l.userMoveCount > 0).length;
    final trained = current.where((s) => s.runCount > 0).length;
    final worst = current.where((s) => s.accuracy != null).toList()
      ..sort((a, b) => a.accuracy!.compareTo(b.accuracy!));
    final tiles = [
      (
        'tile-accuracy',
        l10n.statsAccuracy,
        percentOf(overallAccuracy(current.map((s) => s.accuracy))),
      ),
      ('tile-coverage', l10n.statsCoverage, '$trained / $trainable'),
      (
        'tile-weak',
        l10n.statsWeak,
        '${current.where((s) => s.weak.inPool).length}',
      ),
      (
        'tile-due',
        l10n.statsDue,
        '${current.where((s) => s.srs.isDueOn(today)).length}',
      ),
      ('tile-runs', l10n.statsRuns, '${data.completedRuns}'),
      ('tile-streak', l10n.statsStreak, '${streak?.current ?? 0}'),
    ];
    Widget header(String text) => Padding(
      padding: const EdgeInsets.fromLTRB(0, 24, 0, 8),
      child: Text(text, style: theme.textTheme.titleMedium),
    );
    return ListView(
      key: const Key('stats-list'),
      padding: const EdgeInsets.symmetric(
        horizontal: AdaptiveLayout.gutter,
        vertical: 16,
      ),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (key, label, value) in tiles)
              _Tile(key: Key(key), label: label, value: value),
          ],
        ),
        header(l10n.accuracyOverTime),
        _AccuracyChart(daily: data, today: today),
        header(l10n.worstLines),
        if (worst.isEmpty)
          Text(l10n.noRunsYet)
        else
          for (final s in worst.take(10))
            ListTile(
              key: Key('worst-${s.lineKey}'),
              contentPadding: EdgeInsets.zero,
              title: Text(data.labelOf(s.lineKey)),
              trailing: Text(percentOf(s.accuracy)),
              onTap: () => context.push(Routes.lineStats(id, s.lineKey)),
            ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            key: const Key('show-all-lines'),
            onPressed: () => context.push(Routes.lineList(id)),
            child: Text(l10n.showAll),
          ),
        ),
        header(l10n.mostMissedMoves),
        if (data.missed.isEmpty)
          Text(l10n.noMissedMoves)
        else
          for (final m in data.missed)
            ListTile(
              key: Key('missed-${m.node.id}'),
              contentPadding: EdgeInsets.zero,
              title: Text(
                l10n.missedOf(
                  formatSanMoves([m.node.san!], firstPly: m.node.ply),
                  m.misses,
                  m.attempts,
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(Routes.browse(id, node: m.node.id)),
            ),
        if (data.deviations.count > 0) ...[
          header(l10n.deviationReplies),
          Text(
            l10n.deviationRepliesSummary(
              data.deviations.count,
              accuracyPercent(data.deviations.rate!),
            ),
            key: const Key('deviation-summary'),
          ),
          for (final e in data.deviations.recent)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                e.event.passed ? Icons.check_circle : Icons.cancel,
                color: e.event.passed
                    ? AppColors.success
                    : AppColors.text(context).warning,
              ),
              title: Text(data.labelOf(e.lineKey)),
              subtitle: Text(
                DateFormat.yMMMd(
                  Localizations.localeOf(context).toLanguageTag(),
                ).format(DateTime.fromMillisecondsSinceEpoch(e.finishedAt)),
              ),
              trailing: Text(e.event.passed ? l10n.goodReply : l10n.inaccurate),
            ),
        ],
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const new({required this.label, required this.value, super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 112,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                key: const Key('tile-value'),
                style: theme.textTheme.titleLarge,
              ),
              Text(label, style: theme.textTheme.labelMedium),
            ],
          ),
        ),
      ),
    );
  }
}

/// Daily accuracy with a 7-day moving average, runs per day below
/// (01-product-spec §11.2).
class _AccuracyChart extends StatefulWidget {
  const new({required this.daily, required this.today});

  final RepertoireStatsData daily;
  final String today;

  @override
  State<_AccuracyChart> createState() => _AccuracyChartState();
}

class _AccuracyChartState extends State<_AccuracyChart> {
  ChartRange _range = ChartRange.days30;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final days = chartDays(widget.daily.daily, widget.today, _range);
    final chips = Wrap(
      spacing: 8,
      children: [
        for (final (range, label) in [
          (ChartRange.days30, l10n.range30),
          (ChartRange.days90, l10n.range90),
          (ChartRange.all, l10n.rangeAll),
        ])
          ChoiceChip(
            key: Key('range-${range.name}'),
            label: Text(label),
            selected: _range == range,
            onSelected: (_) => setState(() => _range = range),
          ),
      ],
    );
    if (days.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [chips, const SizedBox(height: 8), Text(l10n.noRunsYet)],
      );
    }
    FlSpot spot(int i, double? v) =>
        v == null ? FlSpot.nullSpot : FlSpot(i.toDouble(), v * 100);
    final maxRuns = days.map((d) => d.runs).fold(1, math.max);
    final maxX = (days.length - 1).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        chips,
        const SizedBox(height: 12),
        SizedBox(
          key: const Key('accuracy-chart'),
          height: 180,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: maxX == 0 ? 1 : maxX,
              minY: 0,
              maxY: 100,
              lineTouchData: const LineTouchData(enabled: false),
              gridData: const FlGridData(drawVerticalLine: false),
              borderData: FlBorderData(show: false),
              titlesData: const FlTitlesData(
                topTitles: AxisTitles(),
                rightTitles: AxisTitles(),
                bottomTitles: AxisTitles(),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 25,
                    reservedSize: 32,
                  ),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    for (var i = 0; i < days.length; i++)
                      spot(i, days[i].accuracy),
                  ],
                  color: scheme.primary.withValues(alpha: 0.5),
                  barWidth: 1,
                ),
                LineChartBarData(
                  spots: [
                    for (var i = 0; i < days.length; i++)
                      spot(i, days[i].movingAverage),
                  ],
                  color: scheme.primary,
                  barWidth: 3,
                  dotData: const FlDotData(show: false),
                ),
              ],
            ),
            duration: Duration.zero,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          key: const Key('runs-chart'),
          height: 48,
          child: Padding(
            padding: const EdgeInsets.only(left: 32),
            child: BarChart(
              BarChartData(
                maxY: maxRuns.toDouble(),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: const FlTitlesData(show: false),
                barTouchData: const BarTouchData(enabled: false),
                barGroups: [
                  for (var i = 0; i < days.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: days[i].runs.toDouble(),
                          color: scheme.secondary,
                          width: math.max(1, 240 / days.length),
                        ),
                      ],
                    ),
                ],
              ),
              duration: Duration.zero,
            ),
          ),
        ),
      ],
    );
  }
}

/// All lines with sort and filter (§11.3 "Show all").
class LineListScreen extends ConsumerStatefulWidget {
  /// Lines of repertoire [id].
  const new({required this.id, super.key});

  /// The repertoire.
  final String id;

  @override
  ConsumerState<LineListScreen> createState() => _LineListState();
}

/// Sort orders of the line list.
enum LineSort {
  /// Lowest accuracy first (untrained last).
  accuracy,

  /// Most recently played first.
  lastPlayed,

  /// Most runs first.
  runs,

  /// Repertoire order.
  order,
}

/// Filters of the line list.
enum LineFilter {
  /// Current lines.
  all,

  /// Weak pool only.
  weak,

  /// Never trained.
  untrained,

  /// Removed by a re-import.
  archived,
}

class _LineListState extends ConsumerState<LineListScreen> {
  LineSort _sort = LineSort.accuracy;
  LineFilter _filter = LineFilter.all;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dataValue = ref.watch(repertoireStatsProvider(widget.id));
    final statsValue = ref.watch(lineStatsProvider(widget.id));
    final data = dataValue.value;
    final stats = statsValue.value;
    if (data == null || stats == null) {
      final error = dataValue.error ?? statsValue.error;
      return Scaffold(
        appBar: AppBar(title: Text(l10n.allLines)),
        body: Center(
          child: error == null
              ? const CircularProgressIndicator()
              : Text(l10n.loadError(describeError(error))),
        ),
      );
    }
    final tree = data.tree;
    final byKey = {for (final s in stats) s.lineKey: s};
    // Every current line (untrained ones have no stats row) plus archived
    // keys with runs.
    final rows = <({String key, LineStats? stats, int order, bool archived})>[
      for (final l in tree.lines)
        if (l.userMoveCount > 0)
          (key: l.key, stats: byKey[l.key], order: l.ordinal, archived: false),
      for (final s in stats)
        if (tree.lineByKey(s.lineKey) == null)
          (key: s.lineKey, stats: s, order: 1 << 30, archived: true),
    ];
    final shown =
        rows
            .where(
              (r) => switch (_filter) {
                LineFilter.all => !r.archived,
                LineFilter.weak =>
                  !r.archived && (r.stats?.weak.inPool ?? false),
                LineFilter.untrained =>
                  !r.archived && (r.stats?.runCount ?? 0) == 0,
                LineFilter.archived => r.archived,
              },
            )
            .toList()
          ..sort((a, b) {
            final c = switch (_sort) {
              LineSort.accuracy => (a.stats?.accuracy ?? 2).compareTo(
                b.stats?.accuracy ?? 2,
              ),
              LineSort.lastPlayed => (b.stats?.lastPlayedAt ?? 0).compareTo(
                a.stats?.lastPlayedAt ?? 0,
              ),
              LineSort.runs => (b.stats?.runCount ?? 0).compareTo(
                a.stats?.runCount ?? 0,
              ),
              LineSort.order => 0,
            };
            return c != 0 ? c : a.order.compareTo(b.order);
          });
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.allLines),
        actions: [
          PopupMenuButton<LineSort>(
            key: const Key('line-sort'),
            tooltip: l10n.sortBy,
            icon: const Icon(Icons.sort),
            initialValue: _sort,
            onSelected: (v) => setState(() => _sort = v),
            itemBuilder: (context) => [
              for (final (v, label) in [
                (LineSort.accuracy, l10n.sortAccuracy),
                (LineSort.lastPlayed, l10n.sortLastPlayed),
                (LineSort.runs, l10n.sortRuns),
                (LineSort.order, l10n.sortOrder),
              ])
                PopupMenuItem(
                  key: Key('sort-${v.name}'),
                  value: v,
                  child: Text(label),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AdaptiveLayout.gutter,
              vertical: 8,
            ),
            child: Wrap(
              spacing: 8,
              children: [
                for (final (v, label) in [
                  (LineFilter.all, l10n.filterAll),
                  (LineFilter.weak, l10n.filterWeak),
                  (LineFilter.untrained, l10n.filterUntrained),
                  (LineFilter.archived, l10n.filterArchived),
                ])
                  ChoiceChip(
                    key: Key('filter-${v.name}'),
                    label: Text(label),
                    selected: _filter == v,
                    onSelected: (_) => setState(() => _filter = v),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              key: const Key('line-list'),
              itemCount: shown.length,
              itemBuilder: (context, i) {
                final r = shown[i];
                final s = r.stats;
                return ListTile(
                  key: Key('line-${r.key}'),
                  title: Text(data.labelOf(r.key)),
                  subtitle: Text(
                    s == null || s.runCount == 0
                        ? l10n.notTrained
                        : l10n.lineRunsCount(s.runCount),
                  ),
                  trailing: Text(percentOf(s?.accuracy)),
                  onTap: () => unawaited(
                    context.push(Routes.lineStats(widget.id, r.key)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
