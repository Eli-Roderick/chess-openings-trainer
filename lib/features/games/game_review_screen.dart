import 'dart:async';

import 'package:chess_core/chess_core.dart';
import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart' hide File;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repertoire_trainer/app/layout/adaptive_layout.dart';
import 'package:repertoire_trainer/core/analysis/game_analyzer.dart';
import 'package:repertoire_trainer/features/board/board_appearance.dart';
import 'package:repertoire_trainer/features/board/board_position.dart';
import 'package:repertoire_trainer/features/board/eval_bar.dart';
import 'package:repertoire_trainer/features/board/repertoire_board.dart';
import 'package:repertoire_trainer/features/games/eval_graph.dart';
import 'package:repertoire_trainer/features/games/game_review.dart';
import 'package:repertoire_trainer/features/games/move_marks.dart';
import 'package:repertoire_trainer/features/games/review_model.dart';
import 'package:repertoire_trainer/l10n/gen/app_localizations.dart';
import 'package:uci_engine/uci_engine.dart' show EngineScore;

const double _barWidth = 14;
const double _rowExtent = 36;

/// Retrying a key move: the position before it, the user to move.
final class _Retry {
  const new(this.ply, {this.wrong = 0, this.hint = false, this.solved});

  final int ply;
  final int wrong;
  final bool hint;

  /// The best move once found (SAN and the position after it).
  final ResolvedMove? solved;
}

/// One game's review: board with eval bar, win-chance graph, the current
/// move's classification, a coach line, accuracy and performance for both
/// sides, and the move list. Fills in while the game is analysed.
class GameReviewScreen extends ConsumerStatefulWidget {
  /// Creates the screen for [gameId].
  const new({required this.gameId, super.key});

  /// Stored game id.
  final String gameId;

  @override
  ConsumerState<GameReviewScreen> createState() => _GameReviewScreenState();
}

class _GameReviewScreenState extends ConsumerState<GameReviewScreen> {
  final _board = RepertoireBoardController();
  final _list = ScrollController();
  var _ply = 0;
  var _flipped = false;
  _Retry? _retry;

  @override
  void dispose() {
    _list.dispose();
    super.dispose();
  }

  void _go(int ply, int length) {
    final next = ply.clamp(0, length);
    if (next == _ply && _retry == null) return;
    setState(() {
      _ply = next;
      _retry = null;
    });
    if (!_list.hasClients) return;
    final row = (next - 1).clamp(0, length) ~/ 2;
    final target = row * _rowExtent - _list.position.viewportDimension / 2;
    _list.jumpTo(target.clamp(0, _list.position.maxScrollExtent));
  }

  void _onRetryMove(ReviewData data, ResolvedMove resolved) {
    final retry = _retry;
    if (retry == null) return;
    final best = data.analyses[retry.ply - 1]?.best;
    if (resolved.uci == best) {
      setState(() => _retry = _Retry(retry.ply, solved: resolved));
      return;
    }
    if (parseUci(resolved.uci) case final NormalMove m) {
      unawaited(_board.flashError(m.to));
    }
    setState(
      () => _retry = _Retry(retry.ply, wrong: retry.wrong + 1, hint: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(reviewDataProvider(widget.gameId));
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
    final game = data.game;
    final n = data.replay.length;
    final ply = _ply.clamp(0, n);
    final userSide = game.userWhite ? Side.white : Side.black;
    final orientation = _flipped ? userSide.opposite : userSide;
    final retry = _retry;

    final board = RepertoireBoard(
      controller: _board,
      state: _boardState(data, ply, orientation, retry),
      onUserMove: (move, resolved, {required viaDrag}) =>
          _onRetryMove(data, resolved),
    );
    final score = retry == null ? data.analyses[ply]?.score : null;
    Widget boardWithBar(double side) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: _barWidth,
          height: side - _barWidth,
          child: RepaintBoundary(
            child: EvalBar(
              score: score == null ? null : _engineScore(score),
              whiteAtBottom: orientation == Side.white,
            ),
          ),
        ),
        SizedBox.square(dimension: side - _barWidth, child: board),
      ],
    );

    final graph = SizedBox(
      height: 56,
      child: EvalGraph(
        key: const Key('eval-graph'),
        values: [for (final a in data.analyses) a?.score.white],
        ply: ply,
        marks: {
          for (final k in data.keys)
            if (data.review.labels[k - 1] case final MoveLabel l)
              k: labelColor(l),
        },
        onSelect: (p) => _go(p, n),
      ),
    );
    final info = _InfoPanel(data: data, ply: ply, retry: retry);
    final moves = _MoveList(
      data: data,
      ply: ply,
      controller: _list,
      onSelect: (p) => _go(p, n),
    );
    final nav = _NavBar(
      data: data,
      ply: ply,
      retry: retry,
      onGo: (p) => _go(p, n),
      onRetry: () => setState(() => _retry = _Retry(ply)),
      onHint: () => setState(
        () => _retry = _Retry(ply, wrong: retry?.wrong ?? 0, hint: true),
      ),
      onExitRetry: () => setState(() => _retry = null),
    );

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
            _go(ply - 1, n),
        const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
            _go(ply + 1, n),
        const SingleActivator(LogicalKeyboardKey.home): () => _go(0, n),
        const SingleActivator(LogicalKeyboardKey.end): () => _go(n, n),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              l10n.gameReviewTitle(game.whiteName, game.blackName),
              overflow: TextOverflow.ellipsis,
            ),
            actions: [
              IconButton(
                key: const Key('review-flip'),
                tooltip: l10n.flipBoard,
                icon: const Icon(Icons.swap_vert),
                onPressed: () => setState(() => _flipped = !_flipped),
              ),
            ],
          ),
          body: SafeArea(
            child: AdaptiveLayout(
              phone: Column(
                children: [
                  _Summary(data: data),
                  LayoutBuilder(
                    builder: (context, c) => boardWithBar(c.maxWidth),
                  ),
                  graph,
                  info,
                  Expanded(child: moves),
                  nav,
                ],
              ),
              wide: LayoutBuilder(
                builder: (context, c) {
                  final side = c.maxHeight < c.maxWidth * 0.6
                      ? c.maxHeight
                      : c.maxWidth * 0.6;
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      boardWithBar(side),
                      Expanded(
                        child: Column(
                          children: [
                            _Summary(data: data),
                            graph,
                            info,
                            Expanded(child: moves),
                            nav,
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  BoardViewState _boardState(
    ReviewData data,
    int ply,
    Side orientation,
    _Retry? retry,
  ) {
    final replay = data.replay;
    if (retry != null) {
      final before = replay.fen(retry.ply - 1);
      final solved = retry.solved;
      if (solved != null) {
        return BoardViewState(
          fen: solved.after.fen,
          orientation: orientation,
          lastMove: parseUci(solved.uci),
        );
      }
      final best = parseUci(data.analyses[retry.ply - 1]?.best ?? '');
      return BoardViewState(
        fen: before,
        orientation: orientation,
        movable: retry.ply.isOdd ? PlayerSide.white : PlayerSide.black,
        lastMove: retry.ply > 1 ? replay.moves[retry.ply - 2] : null,
        highlights: {
          if (retry.hint && best != null) best.from: hintSquareColor,
        },
      );
    }
    final label = ply == 0 ? null : data.review.labels[ply - 1];
    final best = ply == 0 ? null : parseUci(data.analyses[ply - 1]?.best ?? '');
    final played = ply == 0 ? null : replay.moves[ply - 1];
    final showBest =
        best != null &&
        label != null &&
        label.index >= MoveLabel.excellent.index &&
        (best.from != played!.from || best.to != played.to);
    return BoardViewState(
      fen: replay.fen(ply),
      orientation: orientation,
      lastMove: played,
      shapes: {
        if (showBest)
          Arrow(
            color: shapeColor(ShapeColor.green),
            orig: best.from,
            dest: best.to,
          ),
      },
    );
  }
}

EngineScore _engineScore(EvalScore s) {
  final mate = s.mate;
  if (mate != null) return EngineScore.mate(mate);
  final cp = s.cp!;
  if (cp.abs() >= 100000) return EngineScore.mate(cp > 0 ? 1 : -1);
  return EngineScore.cp(cp);
}

String _percent(double? v) => v == null ? '-' : v.toStringAsFixed(1);

/// Accuracy and performance for both sides, and the analysis progress.
class _Summary extends StatelessWidget {
  const new({required this.data});

  final ReviewData data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final r = data.review;
    Widget side(String name, double? accuracy, int? performance) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, overflow: TextOverflow.ellipsis),
          Text(
            l10n.gameAccuracy(_percent(accuracy)),
            style: theme.textTheme.titleMedium,
          ),
          Text(
            l10n.reviewPerformance(performance?.toString() ?? '-'),
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AdaptiveLayout.gutter,
        4,
        AdaptiveLayout.gutter,
        4,
      ),
      child: Column(
        children: [
          Row(
            key: const Key('review-summary'),
            children: [
              side(data.game.whiteName, r.whiteAccuracy, r.whitePerformance),
              side(data.game.blackName, r.blackAccuracy, r.blackPerformance),
            ],
          ),
          if (!data.finished)
            Padding(
              padding: const EdgeInsets.only(top: 4),
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
        ],
      ),
    );
  }
}

/// The current move's classification, the best move, time spent and the
/// coach line (or the retry prompt).
class _InfoPanel extends StatelessWidget {
  const new({required this.data, required this.ply, required this.retry});

  final ReviewData data;
  final int ply;
  final _Retry? retry;

  String _san(int p) => data.game.sans.split(' ')[p - 1];

  String? _bestSan(int p) {
    final best = data.analyses[p - 1]?.best;
    if (best == null) return null;
    final line = resolvePv(data.replay.fen(p - 1), [best], max: 1);
    return line.isEmpty ? null : line.first.san;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final lines = <Widget>[];
    final retry = this.retry;
    if (retry != null) {
      final solved = retry.solved;
      lines.add(
        Text(
          solved != null
              ? l10n.retryCorrect(solved.san)
              : retry.wrong > 0
              ? l10n.retryWrong
              : l10n.retryPrompt(_san(retry.ply)),
          key: const Key('retry-message'),
          style: theme.textTheme.titleSmall,
        ),
      );
    } else if (ply == 0) {
      lines.add(Text(l10n.reviewStart, style: theme.textTheme.titleSmall));
    } else {
      final label = data.review.labels[ply - 1];
      final move = '${moveNumber(ply)} ${_san(ply)}';
      final best = label != null && label.index >= MoveLabel.excellent.index
          ? _bestSan(ply)
          : null;
      final spent = secondsSpent(data.clocks, data.game.timeControl, ply);
      lines.add(
        Row(
          children: [
            if (label != null) ...[
              MoveMark(label, size: 20),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                [
                  if (label != null)
                    l10n.reviewMoveLabel(
                      moveNumber(ply),
                      _san(ply),
                      labelName(l10n, label),
                    )
                  else
                    move,
                  if (best != null && best != _san(ply))
                    l10n.reviewBestWas(best),
                ].join('. '),
                key: const Key('review-move-info'),
                style: theme.textTheme.titleSmall,
              ),
            ),
            if (spent != null)
              Text(
                l10n.reviewTimeSpent(spent.toStringAsFixed(1)),
                style: theme.textTheme.bodySmall,
              ),
          ],
        ),
      );
    }
    if (retry == null) {
      final turn = turningPoint(data.review, userWhite: data.game.userWhite);
      final label = turn == null ? null : data.review.labels[turn - 1];
      lines.add(
        Text(
          turn == null || label == null
              ? (data.finished ? l10n.reviewCleanGame : '')
              : l10n.reviewTurningPoint(
                  moveNumber(turn),
                  _san(turn),
                  labelName(l10n, label),
                  _bestSan(turn) ?? '-',
                ),
          key: const Key('review-coach'),
          style: theme.textTheme.bodySmall,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AdaptiveLayout.gutter,
        8,
        AdaptiveLayout.gutter,
        4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: lines,
      ),
    );
  }
}

/// Virtualised move list, one fixed-height row per full move.
class _MoveList extends StatelessWidget {
  const new({
    required this.data,
    required this.ply,
    required this.controller,
    required this.onSelect,
  });

  final ReviewData data;
  final int ply;
  final ScrollController controller;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final sans = data.game.sans.isEmpty
        ? const <String>[]
        : data.game.sans.split(' ');
    final theme = Theme.of(context);
    Widget cell(int p) {
      if (p > sans.length) return const Expanded(child: SizedBox());
      final label = data.review.labels[p - 1];
      final selected = p == ply;
      return Expanded(
        child: InkWell(
          key: Key('review-move-$p'),
          onTap: () => onSelect(p),
          child: Container(
            height: _rowExtent,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            color: selected ? theme.colorScheme.secondaryContainer : null,
            child: Row(
              children: [
                if (label != null) ...[
                  MoveMark(label),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(sans[p - 1], overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      key: const Key('review-moves'),
      controller: controller,
      itemExtent: _rowExtent,
      itemCount: (sans.length + 1) ~/ 2,
      itemBuilder: (context, row) => Row(
        children: [
          SizedBox(
            width: 44,
            child: Padding(
              padding: const EdgeInsets.only(left: AdaptiveLayout.gutter),
              child: Text('${row + 1}.', style: theme.textTheme.bodySmall),
            ),
          ),
          cell(row * 2 + 1),
          cell(row * 2 + 2),
        ],
      ),
    );
  }
}

/// Move navigation, key-move jumps and retry.
class _NavBar extends StatelessWidget {
  const new({
    required this.data,
    required this.ply,
    required this.retry,
    required this.onGo,
    required this.onRetry,
    required this.onHint,
    required this.onExitRetry,
  });

  final ReviewData data;
  final int ply;
  final _Retry? retry;
  final ValueChanged<int> onGo;
  final VoidCallback onRetry;
  final VoidCallback onHint;
  final VoidCallback onExitRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final n = data.replay.length;
    final retry = this.retry;
    if (retry != null) {
      return Material(
        elevation: 2,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (retry.solved == null)
              TextButton.icon(
                key: const Key('retry-hint'),
                onPressed: retry.hint ? null : onHint,
                icon: const Icon(Icons.lightbulb_outline),
                label: Text(l10n.hint),
              ),
            TextButton.icon(
              key: const Key('retry-exit'),
              onPressed: onExitRetry,
              icon: const Icon(Icons.close),
              label: Text(l10n.retryExit),
            ),
          ],
        ),
      );
    }
    final previous = previousKey(data.keys, ply);
    final next = nextKey(data.keys, ply);
    final label = ply == 0 ? null : data.review.labels[ply - 1];
    final canRetry =
        label != null &&
        retryLabels.contains(label) &&
        whiteMoved(ply) == data.game.userWhite &&
        data.analyses[ply - 1]?.best != null;
    return Material(
      elevation: 2,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            key: const Key('nav-first'),
            tooltip: l10n.browseFirst,
            icon: const Icon(Icons.first_page),
            onPressed: ply > 0 ? () => onGo(0) : null,
          ),
          IconButton(
            key: const Key('nav-prev-key'),
            tooltip: l10n.previousKeyMove,
            icon: const Icon(Icons.keyboard_double_arrow_left),
            onPressed: previous == null ? null : () => onGo(previous),
          ),
          IconButton(
            key: const Key('nav-back'),
            tooltip: l10n.browseBack,
            icon: const Icon(Icons.chevron_left),
            onPressed: ply > 0 ? () => onGo(ply - 1) : null,
          ),
          IconButton(
            key: const Key('retry-move'),
            tooltip: l10n.retryMove,
            icon: const Icon(Icons.replay),
            onPressed: canRetry ? onRetry : null,
          ),
          IconButton(
            key: const Key('nav-forward'),
            tooltip: l10n.browseForward,
            icon: const Icon(Icons.chevron_right),
            onPressed: ply < n ? () => onGo(ply + 1) : null,
          ),
          IconButton(
            key: const Key('nav-next-key'),
            tooltip: l10n.nextKeyMove,
            icon: const Icon(Icons.keyboard_double_arrow_right),
            onPressed: next == null ? null : () => onGo(next),
          ),
          IconButton(
            key: const Key('nav-last'),
            tooltip: l10n.browseLast,
            icon: const Icon(Icons.last_page),
            onPressed: ply < n ? () => onGo(n) : null,
          ),
        ],
      ),
    );
  }
}
