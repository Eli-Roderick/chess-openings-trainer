import 'package:chess_core/chess_core.dart';
import 'package:flutter/material.dart';

/// One item of a [MoveRow].
sealed class MoveRowItem {
  const new();
}

/// A move; [numbered] when it shows its move number ("5." or "5...").
final class MoveItem extends MoveRowItem {
  /// Creates the item.
  const new(this.node, {required this.numbered});

  /// The move.
  final TreeNode node;

  /// Whether the move number is shown.
  final bool numbered;

  /// "5.Nf3", "5...Nc6" or "Nc6".
  String get text {
    final san = node.san!;
    if (!numbered && node.ply.isEven) return san;
    return formatSanMoves([san], firstPly: node.ply);
  }
}

/// Collapse/expand toggle of the fork at [fork] (a position with several
/// moves), with the number of [variations] below it.
final class ForkToggle extends MoveRowItem {
  /// Creates the toggle.
  const new(this.fork, {required this.collapsed, required this.variations});

  /// The position with several children.
  final TreeNode fork;

  /// Whether its variations are hidden.
  final bool collapsed;

  /// Number of variations (children beyond the first).
  final int variations;
}

/// A row of the variation text: the main line or one variation, indented
/// by [depth].
final class MoveRow {
  /// Creates the row.
  const new(this.depth, this.items);

  /// Indentation level (0 = main line).
  final int depth;

  /// Moves and toggles.
  final List<MoveRowItem> items;
}

/// The whole tree as rows (01-product-spec §9): the main line first; at a
/// fork the first child continues the row, each other child starts an
/// indented variation row, and the main line resumes on a new row. Forks
/// in `collapsed` (node ids) hide their variations.
final class MoveRows {
  /// Flattens the tree under [root].
  factory build(TreeNode root, {Set<int> collapsed = const {}}) {
    final rows = <MoveRow>[];
    final rowOf = <int, int>{};
    var items = <MoveRowItem>[];
    var depth = 0;

    void flush() {
      if (items.isNotEmpty) rows.add(MoveRow(depth, items));
      items = <MoveRowItem>[];
    }

    void add(TreeNode node, {required bool numbered}) {
      rowOf[node.id] = rows.length;
      items.add(MoveItem(node, numbered: numbered || node.ply.isOdd));
    }

    void continueFrom(TreeNode position) {
      var p = position;
      var numbered = items.isEmpty;
      while (p.children.isNotEmpty) {
        final main = p.children.first;
        add(main, numbered: numbered);
        numbered = false;
        if (p.children.length > 1) {
          final hidden = collapsed.contains(p.id);
          items.add(
            ForkToggle(p, collapsed: hidden, variations: p.children.length - 1),
          );
          numbered = true;
          if (!hidden) {
            flush();
            final outer = depth;
            for (final alt in p.children.skip(1)) {
              depth = outer + 1;
              add(alt, numbered: true);
              continueFrom(alt);
              flush();
            }
            depth = outer;
          }
        }
        p = main;
      }
    }

    continueFrom(root);
    flush();
    return MoveRows._(rows, rowOf);
  }

  new _(this.rows, this._rowOf);

  /// The rows.
  final List<MoveRow> rows;
  final Map<int, int> _rowOf;

  /// Row index of [nodeId], or null if hidden by a collapsed fork.
  int? rowOf(int nodeId) => _rowOf[nodeId];
}

/// The move list: virtualized rows of `MoveRows` with collapsible forks,
/// the `current` node highlighted and scrolled into view; tapping a move
/// calls [onSelect].
class MoveTreeView extends StatefulWidget {
  /// Creates the view.
  const new({
    required this.root,
    required this.current,
    required this.onSelect,
    super.key,
  });

  /// The tree root.
  final TreeNode root;

  /// The highlighted node id.
  final int current;

  /// Called with a tapped move.
  final ValueChanged<TreeNode> onSelect;

  /// Test hook: called whenever a row is built.
  @visibleForTesting
  static void Function(int row)? debugOnRowBuild;

  @override
  State<MoveTreeView> createState() => _MoveTreeViewState();
}

class _MoveTreeViewState extends State<MoveTreeView> {
  final _scroll = ScrollController();
  final _collapsed = <int>{};
  late MoveRows _rows = MoveRows.build(widget.root);
  _Layout? _layout;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reveal());
  }

  @override
  void didUpdateWidget(MoveTreeView old) {
    super.didUpdateWidget(old);
    if (!identical(old.root, widget.root)) _rebuildRows();
    if (old.current != widget.current) {
      _expandTo(widget.current);
      WidgetsBinding.instance.addPostFrameCallback((_) => _reveal());
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _rebuildRows() {
    _rows = MoveRows.build(widget.root, collapsed: _collapsed);
    _layout = null;
  }

  /// Opens collapsed forks that hide [nodeId].
  void _expandTo(int nodeId) {
    if (_rows.rowOf(nodeId) != null) return;
    var n = _find(widget.root, nodeId);
    var changed = false;
    while (n != null && n.parent != null) {
      if (_collapsed.remove(n.parent!.id)) changed = true;
      n = n.parent;
    }
    if (changed) _rebuildRows();
  }

  static TreeNode? _find(TreeNode root, int id) {
    final stack = [root];
    while (stack.isNotEmpty) {
      final n = stack.removeLast();
      if (n.id == id) return n;
      stack.addAll(n.children);
    }
    return null;
  }

  /// Scrolls so the current move is visible (lines have a fixed height, so
  /// its offset is exact and nothing in between is built).
  void _reveal() {
    final layout = _layout;
    if (!mounted || !_scroll.hasClients || layout == null) return;
    final line = layout.lineOf[widget.current];
    if (line == null) return;
    final position = _scroll.position;
    final top = line * layout.extent;
    final bottom = top + layout.extent;
    if (top >= position.pixels &&
        bottom <= position.pixels + position.viewportDimension) {
      return;
    }
    final target = (top - position.viewportDimension * 0.3).clamp(
      0.0,
      position.maxScrollExtent,
    );
    _scroll.jumpTo(target);
  }

  void _toggle(TreeNode fork) {
    setState(() {
      if (!_collapsed.remove(fork.id)) _collapsed.add(fork.id);
      _rebuildRows();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = theme.textTheme.bodyMedium?.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final scaler = MediaQuery.textScalerOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = _layout = _Layout.of(
          _rows,
          width: constraints.maxWidth,
          style: base,
          scaler: scaler,
          previous: _layout,
        );
        return ListView.builder(
          key: const Key('move-tree'),
          controller: _scroll,
          itemExtent: layout.extent,
          itemCount: layout.lines.length,
          itemBuilder: (context, index) {
            MoveTreeView.debugOnRowBuild?.call(index);
            final line = layout.lines[index];
            return Padding(
              padding: EdgeInsets.only(left: 8 + _Layout.indent * line.depth),
              child: Row(
                children: [
                  for (final (i, item) in line.items.indexed)
                    SizedBox(
                      width: line.widths[i],
                      child: switch (item) {
                        MoveItem() => _MoveChip(
                          key: ValueKey('move-${item.node.id}'),
                          text: item.text,
                          selected: item.node.id == widget.current,
                          style: line.depth == 0
                              ? base?.copyWith(fontWeight: FontWeight.w600)
                              : base,
                          onTap: () => widget.onSelect(item.node),
                        ),
                        ForkToggle() => Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            key: ValueKey('fork-${item.fork.id}'),
                            visualDensity: VisualDensity.compact,
                            iconSize: 18,
                            onPressed: () => _toggle(item.fork),
                            icon: item.collapsed
                                ? Text('+${item.variations}', style: base)
                                : const Icon(Icons.unfold_less),
                          ),
                        ),
                      },
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/// One display line: part of a [MoveRow] that fits the width.
final class _Line {
  const new(this.depth, this.items, this.widths);

  final int depth;
  final List<MoveRowItem> items;
  final List<double> widths;
}

/// [MoveRows] split into fixed-height lines that fit the available width,
/// so the list can use `itemExtent` (jumping far builds nothing in between).
final class _Layout {
  factory of(
    MoveRows rows, {
    required double width,
    required TextStyle? style,
    required TextScaler scaler,
    _Layout? previous,
  }) {
    final key = (rows, width, scaler);
    if (previous != null &&
        identical(previous.key.$1, rows) &&
        previous.key.$2 == width &&
        previous.key.$3 == scaler) {
      return previous;
    }
    // One measurement; token widths are estimated from their length (move
    // text uses tabular figures and short SAN, so this is close and cheap
    // for thousands of moves).
    const sample = '12...Qxd8+';
    final painter = TextPainter(
      text: TextSpan(text: sample, style: style),
      textDirection: TextDirection.ltr,
      textScaler: scaler,
    )..layout();
    final perChar = painter.width / sample.length;
    final extent = painter.height + 16 < 40 ? 40.0 : painter.height + 16;
    painter.dispose();
    final toggle = 40.0 * scaler.scale(1);
    double widthOf(MoveRowItem item) => switch (item) {
      MoveItem() => (item.text.length * perChar).ceilToDouble() + 12,
      ForkToggle() => toggle,
    };
    final lines = <_Line>[];
    final lineOf = <int, int>{};
    for (final row in rows.rows) {
      final free = width - 16 - indent * row.depth;
      var items = <MoveRowItem>[];
      var widths = <double>[];
      var used = 0.0;
      void flush() {
        lines.add(_Line(row.depth, items, widths));
        items = [];
        widths = [];
        used = 0;
      }

      for (final item in row.items) {
        final w = widthOf(item);
        if (items.isNotEmpty && used + w > free) flush();
        if (item is MoveItem) lineOf[item.node.id] = lines.length;
        items.add(item);
        widths.add(w);
        used += w;
      }
      if (items.isNotEmpty) flush();
    }
    return _Layout._(lines, lineOf, extent, key);
  }

  new _(this.lines, this.lineOf, this.extent, this.key);

  static const indent = 16.0;

  final List<_Line> lines;
  final Map<int, int> lineOf;
  final double extent;
  final (MoveRows, double, TextScaler) key;
}

class _MoveChip extends StatelessWidget {
  const new({
    required this.text,
    required this.selected,
    required this.style,
    required this.onTap,
    super.key,
  });

  final String text;
  final bool selected;
  final TextStyle? style;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        constraints: const BoxConstraints(minHeight: 32),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: selected
            ? BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(4),
              )
            : null,
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.fade,
          softWrap: false,
          style: selected
              ? style?.copyWith(color: scheme.onPrimaryContainer)
              : style,
        ),
      ),
    );
  }
}
