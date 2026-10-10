import 'dart:async';

import 'package:chess_core/chess_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:repertoire_trainer/app/layout/adaptive_layout.dart';
import 'package:repertoire_trainer/app/routes.dart';
import 'package:repertoire_trainer/core/analysis/game_analyzer.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/features/games/eval_graph.dart';
import 'package:repertoire_trainer/features/games/game_review.dart';
import 'package:repertoire_trainer/features/games/move_marks.dart';
import 'package:repertoire_trainer/features/games/repertoire_link_panel.dart';
import 'package:repertoire_trainer/features/games/review_model.dart';
import 'package:repertoire_trainer/l10n/gen/app_localizations.dart';

/// Rows of the label table, in the order chess.com lists them.
const List<MoveLabel> _rows = [
  MoveLabel.brilliant,
  MoveLabel.great,
  MoveLabel.best,
  MoveLabel.excellent,
  MoveLabel.good,
  MoveLabel.book,
  MoveLabel.inaccuracy,
  MoveLabel.mistake,
  MoveLabel.miss,
  MoveLabel.blunder,
];

/// The first page of a game review: the win-chance graph with its key
/// moments, accuracy, the count of every classification and the
/// estimated game rating for both sides, then "Continue review" to the
/// board. Opening it starts the game's analysis, and the numbers fill in
/// as it runs.
class GameSummaryScreen extends ConsumerWidget {
  /// Creates the screen for [gameId].
  const new({required this.gameId, super.key});

  /// Stored game id.
  final String gameId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(reviewDataProvider(gameId));
    final data = async.value;
    if (data == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.gameReview)),
        body: Center(
          child: async.hasError
              ? Text(l10n.gameNotFound)
              : const CircularProgressIndicator(),
        ),
      );
    }
    final theme = Theme.of(context);
    final r = data.review;
    final game = data.game;
    final n = data.replay.length;
    final white = labelCounts(r.labels, white: true);
    final black = labelCounts(r.labels, white: false);

    Widget box(String text, {required bool dark, required bool user}) =>
        Expanded(
          child: Container(
            height: 52,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: dark ? const Color(0xFF454545) : const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(6),
              border: user
                  ? Border.all(color: theme.colorScheme.primary, width: 2)
                  : null,
            ),
            child: Text(
              text,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: dark ? Colors.white : const Color(0xFF202020),
              ),
            ),
          ),
        );

    Widget pair(String label, String left, String right, {String? key}) =>
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            key: key == null ? null : Key(key),
            children: [
              SizedBox(
                width: 96,
                child: Text(label, style: theme.textTheme.titleSmall),
              ),
              box(left, dark: false, user: game.userWhite),
              box(right, dark: true, user: !game.userWhite),
            ],
          ),
        );

    Widget name(String text, int rating, {required bool user}) => Expanded(
      child: Column(
        children: [
          Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: user ? FontWeight.w800 : null,
            ),
          ),
          Text('$rating', style: theme.textTheme.bodySmall),
        ],
      ),
    );

    Widget count(int value, MoveLabel label, {required bool white}) => Expanded(
      child: Text(
        '$value',
        key: Key('summary-${label.name}-${white ? 'w' : 'b'}'),
        textAlign: TextAlign.center,
        style: theme.textTheme.headlineSmall?.copyWith(
          color: labelColor(label),
          fontWeight: FontWeight.w800,
        ),
      ),
    );

    final table = Column(
      key: const Key('summary-table'),
      children: [
        for (final label in _rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              key: Key('summary-${label.name}'),
              children: [
                SizedBox(
                  width: 96,
                  child: Text(
                    labelName(l10n, label),
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                count(white[label] ?? 0, label, white: true),
                MoveMark(label, size: 28),
                count(black[label] ?? 0, label, white: false),
              ],
            ),
          ),
      ],
    );

    final content = ListView(
      padding: const EdgeInsets.fromLTRB(
        AdaptiveLayout.gutter,
        8,
        AdaptiveLayout.gutter,
        96,
      ),
      children: [
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n.summaryIntro,
              key: const Key('summary-intro'),
              style: theme.textTheme.titleMedium,
            ),
          ),
        ),
        if (!data.finished)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: LinearProgressIndicator(
              key: const Key('review-progress'),
              value: data.total == 0 ? null : data.done / data.total,
              semanticsLabel: l10n.reviewAnalysing(
                data.profile == AnalysisProfile.quick
                    ? l10n.analysisQuick
                    : l10n.analysisStandard,
                data.done,
                data.total,
              ),
            ),
          ),
        if (data.finished && data.capped > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              l10n.summaryCapped(data.capped),
              key: const Key('summary-capped'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 84,
            child: EvalGraph(
              key: const Key('eval-graph'),
              values: [for (final a in data.analyses) a?.score.white],
              ply: -1,
              dragSelect: false,
              marks: {
                for (final k in data.keys)
                  if (r.labels[k - 1] case final MoveLabel l) k: labelColor(l),
              },
              onSelect: (p) =>
                  context.push(Routes.gameBoard(gameId, ply: p.clamp(0, n))),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          key: const Key('summary-players'),
          children: [
            const SizedBox(width: 96),
            name(game.whiteName, game.whiteRating, user: game.userWhite),
            name(game.blackName, game.blackRating, user: !game.userWhite),
          ],
        ),
        pair(
          l10n.summaryAccuracy,
          _percent(data.finished ? r.whiteAccuracy : null),
          _percent(data.finished ? r.blackAccuracy : null),
          key: 'summary-accuracy',
        ),
        if (game.chessComWhiteAccuracy != null ||
            game.chessComBlackAccuracy != null)
          pair(
            l10n.summaryChessComAccuracy,
            _percent(game.chessComWhiteAccuracy),
            _percent(game.chessComBlackAccuracy),
            key: 'summary-chesscom-accuracy',
          ),
        const Divider(height: 24),
        table,
        const Divider(height: 24),
        pair(
          l10n.summaryRating,
          '${data.finished ? r.whitePerformance ?? '-' : '-'}',
          '${data.finished ? r.blackPerformance ?? '-' : '-'}',
          key: 'summary-rating',
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.gameReview),
        actions: [
          IconButton(
            key: const Key('rerun-review'),
            tooltip: l10n.rerunReview,
            icon: const Icon(Icons.refresh),
            onPressed: data.finished
                ? () => unawaited(_rerun(context, ref))
                : null,
          ),
          IconButton(
            key: const Key('open-repertoire-link'),
            tooltip: l10n.repertoireLink,
            icon: const Icon(Icons.account_tree_outlined),
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              builder: (_) => RepertoireLinkPanel(gameId: gameId),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AdaptiveLayout.maxContentWidth,
              ),
              child: content,
            ),
          ),
          Positioned(
            left: AdaptiveLayout.gutter,
            right: AdaptiveLayout.gutter,
            bottom: 12,
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AdaptiveLayout.maxContentWidth,
                  ),
                  child: FilledButton(
                    key: const Key('continue-review'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                    ),
                    onPressed: () => context.push(Routes.gameBoard(gameId)),
                    child: Text(l10n.continueReview),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension on GameSummaryScreen {
  /// Replaces the stored analysis after a confirmation: the review provider
  /// is rebuilt, finds no stored result and analyses the game again.
  Future<void> _rerun(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.rerunReviewTitle),
        content: Text(l10n.rerunReviewBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            key: const Key('rerun-confirm'),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.rerunConfirm),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(gamesRepositoryProvider).clearGame(gameId);
    ref.invalidate(reviewDataProvider(gameId));
  }
}

String _percent(double? v) => v == null ? '-' : v.toStringAsFixed(1);
