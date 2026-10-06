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
import 'package:repertoire_trainer/core/haptics/haptics_service.dart';
import 'package:repertoire_trainer/features/board/board_appearance.dart';
import 'package:repertoire_trainer/features/board/board_position.dart';
import 'package:repertoire_trainer/features/board/comment_panel.dart';
import 'package:repertoire_trainer/features/board/move_tree_view.dart';
import 'package:repertoire_trainer/features/board/repertoire_board.dart';
import 'package:repertoire_trainer/l10n/gen/app_localizations.dart';

/// A move played off the repertoire in free exploration (never saved).
@immutable
final class FreeMove {
  /// Creates the move.
  const new({required this.uci, required this.san, required this.fen});

  /// UCI as the tree writes it.
  final String uci;

  /// SAN.
  final String san;

  /// Position after the move.
  final String fen;
}

/// Browse (01-product-spec §9) without the Analysis toggle (P06).
class BrowseScreen extends ConsumerWidget {
  /// Browses repertoire [id], starting at node [initialNode] (`?node=`).
  const new({required this.id, super.key, this.initialNode});

  /// Repertoire id.
  final String id;

  /// Node to start at (root when null or unknown).
  final int? initialNode;

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
  });

  /// The repertoire.
  final RepertoireTree tree;

  /// App bar title.
  final String title;

  /// Start node id.
  final int? initialNode;

  @override
  ConsumerState<BrowseView> createState() => _BrowseViewState();
}

class _BrowseViewState extends ConsumerState<BrowseView> {
  late TreeNode _node = _start();
  final _free = <FreeMove>[];
  late Side _orientation = widget.tree.userSide;
  final _board = RepertoireBoardController();

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
    setState(() {
      _free.clear();
      _node = node;
    });
    if (sound && node.san != null) _moved(node.san!);
  }

  void _back() {
    if (_free.isNotEmpty) {
      setState(_free.removeLast);
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

  void _backToRepertoire() => setState(_free.clear);

  void _onUserMove(NormalMove move, ResolvedMove resolved) {
    ref.read(hapticsServiceProvider).light();
    if (_free.isEmpty) {
      final child = _node.children
          .where((c) => c.uci == resolved.uci)
          .firstOrNull;
      if (child != null) return _goTo(child, sound: true);
    }
    setState(
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
    final commentNode = _free.isEmpty && _node.isUserMove ? _node : null;
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
                    AspectRatio(aspectRatio: 1, child: board),
                    Expanded(
                      child: swipeArea(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
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
                        Expanded(
                          child: swipeArea(
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
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
