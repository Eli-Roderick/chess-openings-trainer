import 'dart:async';

import 'package:chess_core/chess_core.dart';
import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart' hide File;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:repertoire_trainer/app/layout/adaptive_layout.dart';
import 'package:repertoire_trainer/app/routes.dart';
import 'package:repertoire_trainer/app/shortcuts.dart';
import 'package:repertoire_trainer/core/audio/sound_service.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/core/engine/engine_providers.dart';
import 'package:repertoire_trainer/core/haptics/haptics_service.dart';
import 'package:repertoire_trainer/core/settings/app_settings.dart';
import 'package:repertoire_trainer/features/board/board_appearance.dart';
import 'package:repertoire_trainer/features/board/board_position.dart';
import 'package:repertoire_trainer/features/board/comment_panel.dart';
import 'package:repertoire_trainer/features/board/eval_bar.dart';
import 'package:repertoire_trainer/features/board/free_move.dart';
import 'package:repertoire_trainer/features/board/move_tree_view.dart';
import 'package:repertoire_trainer/features/board/repertoire_board.dart';
import 'package:repertoire_trainer/l10n/gen/app_localizations.dart';
import 'package:uci_engine/uci_engine.dart';

/// Browse (01-product-spec §9) without the Analysis toggle (P06).
class BrowseScreen extends ConsumerWidget {
  /// Browses repertoire [id], starting at node [initialNode] (`?node=`),
  /// then [initialFree] moves of free exploration; [analysis] starts with
  /// the engine on (Play on's Analyse).
  const new({
    required this.id,
    super.key,
    this.initialNode,
    this.initialFree = const [],
    this.analysis = false,
  });

  /// Repertoire id.
  final String id;

  /// Node to start at (root when null or unknown).
  final int? initialNode;

  /// Free-exploration moves after [initialNode].
  final List<FreeMove> initialFree;

  /// Start with analysis on.
  final bool analysis;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tree = ref.watch(repertoireTreeProvider(id));
    final name = ref
        .watch(repertoireSummariesProvider)
        .value
        ?.where((s) => s.id == id)
        .firstOrNull
        ?.name;
    return switch (tree) {
      AsyncData(:final value) => BrowseView(
        tree: value,
        title: name ?? l10n.browseTitle,
        initialNode: initialNode,
        initialFree: initialFree,
        analysis: analysis,
      ),
      AsyncError(:final error) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.loadError('$error'))),
      ),
      _ => Scaffold(
        appBar: AppBar(title: Text(name ?? l10n.browseTitle)),
        body: const Center(child: CircularProgressIndicator()),
      ),
    };
  }
}

/// Browse on a loaded [tree].
class BrowseView extends ConsumerStatefulWidget {
  /// Creates the view.
  const new({
    required this.tree,
    required this.title,
    super.key,
    this.initialNode,
    this.initialFree = const [],
    this.analysis = false,
  });

  /// The repertoire.
  final RepertoireTree tree;

  /// App bar title.
  final String title;

  /// Start node id.
  final int? initialNode;

  /// Free-exploration moves after the start node.
  final List<FreeMove> initialFree;

  /// Start with analysis on.
  final bool analysis;

  @override
  ConsumerState<BrowseView> createState() => _BrowseViewState();
}

const _phoneBarWidth = 14.0;

class _BrowseViewState extends ConsumerState<BrowseView> {
  late TreeNode _node = _start();
  late final _free = <FreeMove>[...widget.initialFree];
  late Side _orientation = widget.tree.userSide;
  final _board = RepertoireBoardController();

  // Analysis (01-product-spec §9): on while [_analysis]; [_update] belongs
  // to [_analysedFen].
  late bool _analysis = widget.analysis;
  StreamSubscription<AnalysisUpdate>? _analysisSub;

  /// Analysis updates arrive 10 times a second; only the eval bar and the
  /// lines listen, so the board and move list do not rebuild.
  final _update = ValueNotifier<AnalysisUpdate?>(null);
  String? _analysedFen;
  int? _analysedLines;

  @override
  void initState() {
    super.initState();
    if (_analysis) _syncAnalysis();
  }

  @override
  void dispose() {
    unawaited(_analysisSub?.cancel());
    _update.dispose();
    super.dispose();
  }

  /// Changes the position and keeps the analysis on it.
  void _change(VoidCallback fn) {
    setState(fn);
    _syncAnalysis();
  }

  void _syncAnalysis() {
    final lines =
        (ref.read(settingsProvider).value ?? const AppSettings()).analysisLines;
    if (!_analysis) {
      unawaited(_analysisSub?.cancel());
      _analysisSub = null;
      _analysedFen = null;
      return;
    }
    if (_analysedFen == _fen && _analysedLines == lines) return;
    unawaited(_analysisSub?.cancel());
    _analysedFen = _fen;
    _analysedLines = lines;
    _update.value = null;
    _analysisSub = ref
        .read(engineServiceProvider)
        .analyse(_fen, multiPv: lines)
        .listen(
          (u) {
            if (mounted) _update.value = u;
          },
          onError: (Object _) {
            if (mounted) setState(() => _analysis = false);
          },
        );
  }

  void _toggleAnalysis() {
    setState(() => _analysis = !_analysis);
    if (!_analysis) _update.value = null;
    _syncAnalysis();
  }

  /// Plays the first [count] moves of an engine line into free exploration.
  void _playPv(List<ResolvedMove> moves, int count) {
    _change(() {
      for (final m in moves.take(count)) {
        _free.add(FreeMove(uci: m.uci, san: m.san, fen: m.after.fen));
      }
    });
    _moved(moves[count - 1].san);
  }

  TreeNode _start() {
    final id = widget.initialNode;
    final tree = widget.tree;
    if (id == null || id < 0 || id >= tree.nodes.length) return tree.root;
    return tree.node(id);
  }

  String get _fen => _free.isEmpty ? _node.fen : _free.last.fen;

  Move? get _lastMove {
    final uci = _free.isNotEmpty ? _free.last.uci : _node.uci;
    return uci == null ? null : parseUci(uci);
  }

  void _moved(String san) {
    ref.read(soundServiceProvider).play(SoundType.forSan(san));
  }

  void _goTo(TreeNode node, {bool sound = false}) {
    _change(() {
      _free.clear();
      _node = node;
    });
    if (sound && node.san != null) _moved(node.san!);
  }

  void _back() {
    if (_free.isNotEmpty) {
      _change(_free.removeLast);
    } else if (_node.parent != null) {
      _goTo(_node.parent!);
    }
  }

  Future<void> _forward() async {
    if (_free.isNotEmpty) return;
    final children = _node.children;
    if (children.isEmpty) return;
    if (children.length == 1) return _goTo(children.single, sound: true);
    final choice = await _chooseChild(children);
    if (choice != null && mounted) _goTo(choice, sound: true);
  }

  void _first() => _goTo(widget.tree.root);

  void _last() {
    var n = _node;
    while (n.children.isNotEmpty) {
      n = n.children.first;
    }
    _goTo(n);
  }

  void _sibling(int delta) {
    final parent = _node.parent;
    if (_free.isNotEmpty || parent == null || parent.children.length < 2) {
      return;
    }
    final siblings = parent.children;
    final i = (siblings.indexOf(_node) + delta) % siblings.length;
    _goTo(siblings[i], sound: true);
  }

  void _flip() => setState(() => _orientation = _orientation.opposite);

  void _backToRepertoire() => _change(_free.clear);

  void _onUserMove(
    NormalMove move,
    ResolvedMove resolved, {
    required bool viaDrag,
  }) {
    ref.read(hapticsServiceProvider).light();
    if (_free.isEmpty) {
      final child = _node.children
          .where((c) => c.uci == resolved.uci)
          .firstOrNull;
      if (child != null) return _goTo(child, sound: true);
    }
    _change(
      () => _free.add(
        FreeMove(uci: resolved.uci, san: resolved.san, fen: resolved.after.fen),
      ),
    );
    _moved(resolved.san);
  }

  Future<TreeNode?> _chooseChild(List<TreeNode> children) {
    final l10n = AppLocalizations.of(context);
    return showModalBottomSheet<TreeNode>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(title: Text(l10n.chooseMove)),
            for (final c in children)
              ListTile(
                key: Key('fork-choice-${c.uci}'),
                title: Text(formatSanMoves([c.san!], firstPly: c.ply)),
                subtitle: switch (c.comment?.why) {
                  final why? when c.isUserMove && why.isNotEmpty => Text(
                    why.length > 60 ? '${why.substring(0, 60)}…' : why,
                  ),
                  _ => null,
                },
                onTap: () => Navigator.of(context).pop(c),
              ),
          ],
        ),
      ),
    );
  }

  void _leave() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(Routes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final showArrows = ref.watch(
      settingsProvider.select((s) => s.value?.showCommentArrows ?? true),
    );
    ref.listen(
      settingsProvider.select((s) => s.value?.analysisLines),
      (_, _) => _syncAnalysis(),
    );
    final engineAvailable = ref.watch(
      engineStatusProvider.select((s) => s.value?.isAvailable ?? true),
    );
    if (!engineAvailable && _analysis) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _analysis) _toggleAnalysis();
      });
    }
    final commentNode = _free.isEmpty && _node.isUserMove ? _node : null;
    final evalBar = RepaintBoundary(
      child: ValueListenableBuilder(
        valueListenable: _update,
        builder: (context, update, _) => EvalBar(
          score: update?.lines.firstOrNull?.score,
          whiteAtBottom: _orientation == Side.white,
        ),
      ),
    );
    final analysisPanel = _analysis
        ? RepaintBoundary(
            child: ValueListenableBuilder(
              valueListenable: _update,
              builder: (context, update, _) => _AnalysisLines(
                update: update,
                fen: _fen,
                ply: _node.ply + _free.length,
                onPlay: _playPv,
              ),
            ),
          )
        : null;
    final board = RepertoireBoard(
      controller: _board,
      state: BoardViewState(
        fen: _fen,
        orientation: _orientation,
        movable: PlayerSide.both,
        lastMove: _lastMove,
        shapes: showArrows && commentNode?.comment != null
            ? boardShapes(commentNode!.comment!.shapes)
            : const {},
      ),
      onUserMove: _onUserMove,
    );
    final placeholder = switch (_node) {
      final n when n.san == null => l10n.browseStart,
      final n =>
        '${formatSanMoves([n.san!], firstPly: n.ply)} · '
            '${l10n.opponentMoveNoComment}',
    };
    final screenHeight = MediaQuery.sizeOf(context).height;

    Widget info({double? maxHeight}) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_free.isNotEmpty) _exploration(l10n),
        if (_free.isEmpty)
          CommentPanel(
            node: commentNode,
            placeholder: placeholder,
            maxHeight: maxHeight,
          ),
      ],
    );
    final moves = MoveTreeView(
      root: widget.tree.root,
      current: _node.id,
      onSelect: _goTo,
    );
    final nav = _NavBar(
      onFirst: _first,
      onBack: _back,
      onForward: _forward,
      onLast: _last,
    );
    // Swipes only below the board, so dragging pieces keeps working.
    Widget swipeArea(Widget child) => GestureDetector(
      key: const Key('swipe-area'),
      behavior: HitTestBehavior.translucent,
      onHorizontalDragEnd: (d) {
        final v = d.primaryVelocity ?? 0;
        if (v < -200) {
          _forward().ignore();
        } else if (v > 200) {
          _back();
        }
      },
      child: child,
    );

    return Shortcuts(
      shortcuts: browseShortcuts,
      child: Actions(
        actions: {
          FlipBoardIntent: CallbackAction<FlipBoardIntent>(
            onInvoke: (_) => _flip(),
          ),
          BackIntent: CallbackAction<BackIntent>(onInvoke: (_) => _back()),
          ForwardIntent: CallbackAction<ForwardIntent>(
            onInvoke: (_) => _forward(),
          ),
          FirstIntent: CallbackAction<FirstIntent>(onInvoke: (_) => _first()),
          LastIntent: CallbackAction<LastIntent>(onInvoke: (_) => _last()),
          SiblingIntent: CallbackAction<SiblingIntent>(
            onInvoke: (i) => _sibling(i.delta),
          ),
          LeaveIntent: CallbackAction<LeaveIntent>(onInvoke: (_) => _leave()),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            appBar: AppBar(
              toolbarHeight: 48,
              title: Text(widget.title),
              actions: [
                IconButton(
                  key: const Key('analysis-toggle'),
                  tooltip: engineAvailable
                      ? l10n.analysisToggle
                      : l10n.engineUnavailable,
                  isSelected: _analysis,
                  icon: const Icon(Icons.insights_outlined),
                  selectedIcon: const Icon(Icons.insights),
                  onPressed: engineAvailable ? _toggleAnalysis : null,
                ),
                IconButton(
                  key: const Key('flip-board'),
                  tooltip: l10n.flipBoard,
                  icon: const Icon(Icons.swap_vert),
                  onPressed: _flip,
                ),
              ],
            ),
            body: SafeArea(
              child: AdaptiveLayout(
                phone: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_analysis)
                      // The eval bar sits at the board's left edge.
                      LayoutBuilder(
                        builder: (context, c) => SizedBox(
                          height: c.maxWidth - _phoneBarWidth,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              evalBar,
                              Expanded(child: board),
                            ],
                          ),
                        ),
                      )
                    else
                      AspectRatio(aspectRatio: 1, child: board),
                    Expanded(
                      child: swipeArea(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ?analysisPanel,
                            info(maxHeight: screenHeight * 0.35),
                            const Divider(height: 1),
                            Expanded(child: moves),
                          ],
                        ),
                      ),
                    ),
                    nav,
                  ],
                ),
                wide: LayoutBuilder(
                  builder: (context, c) {
                    final side = c.maxHeight < c.maxWidth * 0.62
                        ? c.maxHeight
                        : c.maxWidth * 0.62;
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox.square(dimension: side, child: board),
                        if (_analysis) SizedBox(height: side, child: evalBar),
                        Expanded(
                          child: swipeArea(
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ?analysisPanel,
                                info(maxHeight: c.maxHeight * 0.4),
                                const Divider(height: 1),
                                Expanded(child: moves),
                                nav,
                              ],
                            ),
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
      ),
    );
  }

  Widget _exploration(AppLocalizations l10n) {
    final firstPly = _node.ply + 1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            formatSanMoves([for (final m in _free) m.san], firstPly: firstPly),
            key: const Key('free-moves'),
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                l10n.exploring,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              ActionChip(
                key: const Key('back-to-repertoire'),
                avatar: const Icon(Icons.undo, size: 18),
                label: Text(l10n.backToRepertoire),
                onPressed: _backToRepertoire,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  const new({
    required this.onFirst,
    required this.onBack,
    required this.onForward,
    required this.onLast,
  });

  final VoidCallback onFirst;
  final VoidCallback onBack;
  final VoidCallback onForward;
  final VoidCallback onLast;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Material(
      elevation: 2,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            key: const Key('nav-first'),
            tooltip: l10n.browseFirst,
            icon: const Icon(Icons.first_page),
            onPressed: onFirst,
          ),
          IconButton(
            key: const Key('nav-back'),
            tooltip: l10n.browseBack,
            icon: const Icon(Icons.chevron_left),
            onPressed: onBack,
          ),
          IconButton(
            key: const Key('nav-forward'),
            tooltip: l10n.browseForward,
            icon: const Icon(Icons.chevron_right),
            onPressed: onForward,
          ),
          IconButton(
            key: const Key('nav-last'),
            tooltip: l10n.browseLast,
            icon: const Icon(Icons.last_page),
            onPressed: onLast,
          ),
        ],
      ),
    );
  }
}

/// SAN of engine lines, cached: consecutive updates mostly repeat the same
/// lines, so each (position, line) is resolved once.
final _pvCache = <(String, String), List<ResolvedMove>>{};

List<ResolvedMove> _cachedPv(String fen, List<String> pv) {
  final key = (fen, pv.take(12).join(' '));
  final hit = _pvCache[key];
  if (hit != null) return hit;
  if (_pvCache.length > 64) _pvCache.clear();
  return _pvCache[key] = resolvePv(fen, pv);
}

/// Engine lines under the board: "+0.35 d22" and up to 12 SAN moves per
/// line; tapping a move plays the line up to it into free exploration.
class _AnalysisLines extends ConsumerWidget {
  const new({
    required this.update,
    required this.fen,
    required this.ply,
    required this.onPlay,
  });

  final AnalysisUpdate? update;
  final String fen;

  /// Ply of the analysed position (its next move has ply + 1).
  final int ply;
  final void Function(List<ResolvedMove> moves, int count) onPlay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final lines =
        ref.watch(settingsProvider.select((s) => s.value?.analysisLines)) ?? 1;
    final mono = theme.textTheme.bodySmall?.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final update = this.update;
    // Constant height for the line count: the panel's height must not change
    // with every update, or the move list below re-lays out and rebuilds.
    final scale = MediaQuery.textScalerOf(context).scale(1);
    return SizedBox(
      height: (40 + 34.0 * lines) * scale,
      child: Padding(
        key: const Key('analysis-panel'),
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    update == null
                        ? l10n.analysing
                        : l10n.analysisDepth(update.depth),
                    key: const Key('analysis-depth'),
                    style: theme.textTheme.labelMedium,
                  ),
                ),
                SegmentedButton<int>(
                  key: const Key('analysis-lines'),
                  showSelectedIcon: false,
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  segments: [
                    for (var n = 1; n <= 3; n++)
                      ButtonSegment(value: n, label: Text('$n')),
                  ],
                  selected: {lines},
                  onSelectionChanged: (v) => unawaited(
                    ref
                        .read(settingsRepositoryProvider)
                        .update((s) => s.copyWith(analysisLines: v.single)),
                  ),
                ),
              ],
            ),
            if (update == null)
              const LinearProgressIndicator()
            else
              for (final (i, line) in update.lines.indexed)
                _PvRow(
                  key: Key('pv-$i'),
                  label: evalLabel(line.score),
                  moves: _cachedPv(fen, line.pv),
                  firstPly: ply + 1,
                  style: mono,
                  onPlay: onPlay,
                ),
          ],
        ),
      ),
    );
  }
}

class _PvRow extends StatelessWidget {
  const new({
    required this.label,
    required this.moves,
    required this.firstPly,
    required this.style,
    required this.onPlay,
    super.key,
  });

  final String label;
  final List<ResolvedMove> moves;
  final int firstPly;
  final TextStyle? style;
  final void Function(List<ResolvedMove> moves, int count) onPlay;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Text(
              label,
              style: style?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          for (final (i, m) in moves.indexed)
            InkWell(
              key: Key('pv-move-$i'),
              onTap: () => onPlay(moves, i + 1),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 6),
                child: Text(
                  i == 0 || (firstPly + i).isOdd
                      ? formatSanMoves([m.san], firstPly: firstPly + i)
                      : m.san,
                  style: style,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
