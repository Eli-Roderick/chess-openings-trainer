import 'dart:async';

import 'package:chess_core/chess_core.dart';
import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart' hide File;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repertoire_trainer/app/layout/adaptive_layout.dart';
import 'package:repertoire_trainer/features/board/board_appearance.dart';
import 'package:repertoire_trainer/features/board/board_position.dart';
import 'package:repertoire_trainer/features/board/eval_bar.dart';
import 'package:repertoire_trainer/features/board/repertoire_board.dart';
import 'package:repertoire_trainer/features/games/game_review.dart';
import 'package:repertoire_trainer/features/games/move_marks.dart';
import 'package:repertoire_trainer/features/games/repertoire_link_panel.dart';
import 'package:repertoire_trainer/features/games/review_model.dart';
import 'package:repertoire_trainer/l10n/gen/app_localizations.dart';
import 'package:uci_engine/uci_engine.dart' show EngineScore;

const double _barWidth = 14;
const double _chipExtent = 72;

/// Retrying a key move: the position before it, the user to move.
final class _Retry {
  const new(this.ply, {this.wrong = 0, this.hint = false, this.solved});

  final int ply;
  final int wrong;
  final bool hint;

  /// The best move once found (SAN and the position after it).
  final ResolvedMove? solved;
}

/// White's point of view as the engine package's score type.
EngineScore engineScore(EvalScore s) {
  final mate = s.mate;
  if (mate != null) return EngineScore.mate(mate);
  final cp = s.cp!;
  if (cp.abs() >= 100000) return EngineScore.mate(cp > 0 ? 1 : -1);
  return EngineScore.cp(cp);
}

/// The board page of a game review: a coach card for the current move
/// (classification, evaluation, best move), the board with eval bar and the
/// move's mark on its square, the move strip and Show / Best / Retry /
/// Next. Fills in while the game is analysed.
class GameReviewScreen extends ConsumerStatefulWidget {
  /// Creates the screen for [gameId], starting at [initialPly].
  const new({required this.gameId, super.key, this.initialPly = 0});

  /// Stored game id.
  final String gameId;

  /// Position to open at.
  final int initialPly;

  @override
  ConsumerState<GameReviewScreen> createState() => _GameReviewScreenState();
}

class _GameReviewScreenState extends ConsumerState<GameReviewScreen> {
  final _board = RepertoireBoardController();
  final _strip = ScrollController();
  late int _ply = widget.initialPly;
  var _flipped = false;
  var _showBest = false;
  var _showLine = false;
  _Retry? _retry;

  @override
  void dispose() {
    _strip.dispose();
    super.dispose();
  }

  void _go(int ply, int length) {
    final next = ply.clamp(0, length);
    if (next == _ply && _retry == null) return;
    setState(() {
      _ply = next;
      _retry = null;
      _showBest = false;
      _showLine = false;
    });
    if (!_strip.hasClients) return;
    final target = next * _chipExtent - _strip.position.viewportDimension / 2;
    _strip.jumpTo(target.clamp(0, _strip.position.maxScrollExtent));
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
    final label = ply == 0 ? null : data.review.labels[ply - 1];
    final sans = game.sans.isEmpty ? const <String>[] : game.sans.split(' ');

    final board = RepertoireBoard(
      controller: _board,
      state: _boardState(data, ply, orientation, retry),
      onUserMove: (move, resolved, {required viaDrag}) =>
          _onRetryMove(data, resolved),
    );
    final score = retry == null ? data.analyses[ply]?.score : null;
    final played = ply == 0 || retry != null
        ? null
        : data.replay.moves[ply - 1];
    Widget boardWithBar(double side) {
      final size = side - _barWidth;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: _barWidth,
            height: size,
            child: RepaintBoundary(
              child: EvalBar(
                score: score == null ? null : engineScore(score),
                whiteAtBottom: orientation == Side.white,
              ),
            ),
          ),
          SizedBox.square(
            dimension: size,
            child: Stack(
              children: [
                Positioned.fill(child: board),
                if (played != null && label != null)
                  _Badge(
                    label: label,
                    square: played.to,
                    size: size,
                    orientation: orientation,
                  ),
              ],
            ),
          ),
        ],
      );
    }

    final coach = _CoachCard(
      data: data,
      ply: ply,
      retry: retry,
      showBest: _showBest,
      showLine: _showLine,
    );
    final strip = _MoveStrip(
      sans: sans,
      ply: ply,
      controller: _strip,
      onSelect: (p) => _go(p, n),
    );
    final actions = _Actions(
      data: data,
      ply: ply,
      retry: retry,
      showBest: _showBest,
      showLine: _showLine,
      onShow: () => setState(() => _showLine = !_showLine),
      onBest: () => setState(() => _showBest = !_showBest),
      onRetry: () => setState(() {
        _retry = _Retry(ply);
        _showBest = false;
        _showLine = false;
      }),
      onHint: () => setState(
        () => _retry = _Retry(ply, wrong: retry?.wrong ?? 0, hint: true),
      ),
      onExitRetry: () => setState(() => _retry = null),
      onNext: () {
        final next = nextKey(data.keys, ply);
        if (next == null) {
          Navigator.of(context).maybePop();
        } else {
          _go(next, n);
        }
      },
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
            title: Text(l10n.gameReview),
            actions: [
              IconButton(
                key: const Key('open-repertoire-link'),
                tooltip: l10n.repertoireLink,
                icon: const Icon(Icons.account_tree_outlined),
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => RepertoireLinkPanel(gameId: widget.gameId),
                ),
              ),
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
                  coach,
                  // The board takes the width, or less on a short screen.
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, c) => Align(
                        alignment: Alignment.topCenter,
                        child: boardWithBar(
                          c.maxWidth < c.maxHeight ? c.maxWidth : c.maxHeight,
                        ),
                      ),
                    ),
                  ),
                  strip,
                  actions,
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
                          children: [coach, strip, const Spacer(), actions],
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
    final best = ply == 0 ? null : parseUci(data.analyses[ply - 1]?.best ?? '');
    final played = ply == 0 ? null : replay.moves[ply - 1];
    return BoardViewState(
      fen: replay.fen(ply),
      orientation: orientation,
      lastMove: played,
      shapes: {
        if (_showBest && best != null)
          Arrow(
            color: shapeColor(ShapeColor.green),
            orig: best.from,
            dest: best.to,
          ),
      },
    );
  }
}

/// The move's mark on the corner of its destination square.
class _Badge extends StatelessWidget {
  const new({
    required this.label,
    required this.square,
    required this.size,
    required this.orientation,
  });

  final MoveLabel label;
  final Square square;
  final double size;
  final Side orientation;

  @override
  Widget build(BuildContext context) {
    final cell = size / 8;
    final file = square.file.value;
    final rank = square.rank.value;
    final white = orientation == Side.white;
    final badge = cell * 0.46;
    return Positioned(
      left: (white ? file : 7 - file) * cell + cell - badge * 0.8,
      top: (white ? 7 - rank : rank) * cell - badge * 0.2,
      child: IgnorePointer(child: MoveMark(label, size: badge)),
    );
  }
}

/// The current move's title, evaluation and a line of detail.
class _CoachCard extends StatelessWidget {
  const new({
    required this.data,
    required this.ply,
    required this.retry,
    required this.showBest,
    required this.showLine,
  });

  final ReviewData data;
  final int ply;
  final _Retry? retry;
  final bool showBest;
  final bool showLine;

  String _san(int p) => data.game.sans.split(' ')[p - 1];

  String? _bestSan(int p) {
    final best = data.analyses[p - 1]?.best;
    if (best == null) return null;
    final line = resolvePv(data.replay.fen(p - 1), [best], max: 1);
    return line.isEmpty ? null : line.first.san;
  }

  String _title(AppLocalizations l10n, MoveLabel label, String san) =>
      switch (label) {
        MoveLabel.book => l10n.moveTitleBook(san),
        MoveLabel.forced => l10n.moveTitleForced(san),
        MoveLabel.brilliant => l10n.moveTitleBrilliant(san),
        MoveLabel.great => l10n.moveTitleGreat(san),
        MoveLabel.best => l10n.moveTitleBest(san),
        MoveLabel.excellent => l10n.moveTitleExcellent(san),
        MoveLabel.good => l10n.moveTitleGood(san),
        MoveLabel.inaccuracy => l10n.moveTitleInaccuracy(san),
        MoveLabel.mistake => l10n.moveTitleMistake(san),
        MoveLabel.blunder => l10n.moveTitleBlunder(san),
        MoveLabel.miss => l10n.moveTitleMiss(san),
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final retry = this.retry;
    MoveLabel? label;
    String title;
    String? detail;
    if (retry != null) {
      final solved = retry.solved;
      title = solved != null
          ? l10n.retryCorrect(solved.san)
          : retry.wrong > 0
          ? l10n.retryWrong
          : l10n.retryPrompt(_san(retry.ply));
    } else if (ply == 0) {
      title = l10n.reviewStart;
    } else {
      label = data.review.labels[ply - 1];
      final san = _san(ply);
      title = label == null ? san : _title(l10n, label, san);
      final best = _bestSan(ply);
      if (label == MoveLabel.book && data.game.opening != null) {
        detail = l10n.reviewOpening(data.game.opening!);
      } else if (label != null &&
          label.index >= MoveLabel.good.index &&
          best != null &&
          best != san) {
        detail = l10n.reviewBestWas(best);
      }
    }
    String? line;
    if (showLine && ply > 0 && retry == null) {
      final pv = data.analyses[ply - 1]?.pv ?? const <String>[];
      final moves = resolvePv(data.replay.fen(ply - 1), pv, max: 8);
      if (moves.isNotEmpty) {
        line = l10n.reviewLine(moves.map((m) => m.san).join(' '));
      }
    }
    final score = retry == null ? data.analyses[ply]?.score : null;
    final spent = retry == null && ply > 0
        ? secondsSpent(data.clocks, data.game.timeControl, ply)
        : null;
    return Card(
      key: const Key('coach-card'),
      margin: const EdgeInsets.fromLTRB(
        AdaptiveLayout.gutter,
        8,
        AdaptiveLayout.gutter,
        8,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (label != null) ...[
                  MoveMark(label, size: 28),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Text(
                    title,
                    key: const Key('review-move-info'),
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                if (spent != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      l10n.reviewTimeSpent(spent.toStringAsFixed(1)),
                      key: const Key('review-time'),
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                if (score != null)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      child: Text(
                        evalLabel(engineScore(score)),
                        key: const Key('review-eval'),
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                  ),
              ],
            ),
            if (detail != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(detail, key: const Key('review-detail')),
              ),
            if (line != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  line,
                  key: const Key('review-line'),
                  style: theme.textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Horizontal move strip: `1. d4  c6  2. Bf4`, the current ply underlined.
class _MoveStrip extends StatelessWidget {
  const new({
    required this.sans,
    required this.ply,
    required this.controller,
    required this.onSelect,
  });

  final List<String> sans;
  final int ply;
  final ScrollController controller;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          IconButton(
            key: const Key('nav-back'),
            tooltip: l10n.browseBack,
            icon: const Icon(Icons.chevron_left),
            onPressed: ply > 0 ? () => onSelect(ply - 1) : null,
          ),
          Expanded(
            child: ListView.builder(
              key: const Key('review-moves'),
              controller: controller,
              scrollDirection: Axis.horizontal,
              itemExtent: _chipExtent,
              itemCount: sans.length,
              itemBuilder: (context, i) {
                final p = i + 1;
                final selected = p == ply;
                return InkWell(
                  key: Key('review-move-$p'),
                  onTap: () => onSelect(p),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: 2,
                          color: selected
                              ? theme.colorScheme.primary
                              : Colors.transparent,
                        ),
                      ),
                    ),
                    child: Text(
                      p.isOdd ? '${(p + 1) ~/ 2}. ${sans[i]}' : sans[i],
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: selected ? FontWeight.w800 : null,
                        color: p > ply
                            ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                            : null,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          IconButton(
            key: const Key('nav-forward'),
            tooltip: l10n.browseForward,
            icon: const Icon(Icons.chevron_right),
            onPressed: ply < sans.length ? () => onSelect(ply + 1) : null,
          ),
        ],
      ),
    );
  }
}

/// Show / Best / Retry and the Next button (or the retry controls).
class _Actions extends StatelessWidget {
  const new({
    required this.data,
    required this.ply,
    required this.retry,
    required this.showBest,
    required this.showLine,
    required this.onShow,
    required this.onBest,
    required this.onRetry,
    required this.onHint,
    required this.onExitRetry,
    required this.onNext,
  });

  final ReviewData data;
  final int ply;
  final _Retry? retry;
  final bool showBest;
  final bool showLine;
  final VoidCallback onShow;
  final VoidCallback onBest;
  final VoidCallback onRetry;
  final VoidCallback onHint;
  final VoidCallback onExitRetry;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final retry = this.retry;
    Widget button(Key key, IconData icon, String text, VoidCallback? tap) =>
        Expanded(
          child: TextButton(
            key: key,
            onPressed: tap,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon),
                Text(text, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        );
    if (retry != null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
        child: Row(
          children: [
            if (retry.solved == null)
              button(
                const Key('retry-hint'),
                Icons.lightbulb_outline,
                l10n.hint,
                retry.hint ? null : onHint,
              ),
            button(
              const Key('retry-exit'),
              Icons.close,
              l10n.retryExit,
              onExitRetry,
            ),
          ],
        ),
      );
    }
    final label = ply == 0 ? null : data.review.labels[ply - 1];
    final best = ply == 0 ? null : data.analyses[ply - 1]?.best;
    final canRetry =
        label != null &&
        retryLabels.contains(label) &&
        whiteMoved(ply) == data.game.userWhite &&
        best != null;
    final next = nextKey(data.keys, ply);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      child: Row(
        children: [
          button(
            const Key('review-show'),
            Icons.visibility_outlined,
            l10n.reviewShow,
            best == null ? null : onShow,
          ),
          button(
            const Key('review-best'),
            Icons.star_border,
            l10n.reviewBest,
            best == null ? null : onBest,
          ),
          button(
            const Key('retry-move'),
            Icons.replay,
            l10n.reviewRetry,
            canRetry ? onRetry : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: FilledButton(
              key: const Key('review-next'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              onPressed: onNext,
              child: Text(next == null ? l10n.backToSummary : l10n.reviewNext),
            ),
          ),
        ],
      ),
    );
  }
}
