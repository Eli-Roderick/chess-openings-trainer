import 'package:chess_core/src/pgn/move_comment.dart';
import 'package:chess_core/src/tree/line.dart';
import 'package:chess_core/src/tree/rows.dart';
import 'package:chess_core/src/tree/tree_node.dart';
import 'package:dartchess/dartchess.dart';

/// An imported repertoire as an in-memory tree with its lines
/// (docs/plan/03-data-model.md §6).
final class RepertoireTree {
  /// Creates a tree from already-built parts. [nodes] must be in preorder
  /// with `nodes[i].id == i`.
  new({
    required this.root,
    required this.userSide,
    required List<TreeNode> nodes,
    required List<Line> lines,
    this.description,
  }) : nodes = List.unmodifiable(nodes),
       lines = List.unmodifiable(lines),
       _byKey = {for (final l in lines) l.key: l};

  /// Rebuilds a tree from database rows in O(n).
  ///
  /// Throws [FormatException] if the rows are not a preorder tree.
  factory fromRows(
    RepertoireRows rows, {
    required Side userSide,
    String? description,
  }) {
    final nodes = <TreeNode>[];
    for (final r in rows.nodes) {
      if (r.nodeId != nodes.length) {
        throw FormatException('node ${r.nodeId} out of preorder');
      }
      final parentId = r.parentId;
      if (parentId != null && (parentId < 0 || parentId >= nodes.length)) {
        throw FormatException('node ${r.nodeId}: bad parent $parentId');
      }
      final parent = parentId == null ? null : nodes[parentId];
      if ((parent == null) != (r.nodeId == 0)) {
        throw FormatException('node ${r.nodeId}: bad parent $parentId');
      }
      if (parent != null && parent.children.length != r.childIndex) {
        throw FormatException('node ${r.nodeId}: bad childIndex');
      }
      final comment = MoveComment(
        why: r.why,
        plan: r.plan,
        watch: r.watch,
        alt: r.alt,
        shapes: r.shapes,
      );
      final node = TreeNode(
        id: r.nodeId,
        parent: parent,
        ply: r.ply,
        san: r.san,
        uci: r.uci,
        fen: r.fen,
        isUserMove: r.isUserMove,
        comment: comment.isEmpty ? null : comment,
        rawComment: r.rawComment,
        nags: r.nags,
      );
      parent?.addChild(node);
      nodes.add(node);
    }
    if (nodes.isEmpty) throw const FormatException('no root row');
    final lines = [
      for (final l in rows.lines)
        Line(
          key: l.lineKey,
          ucis: l.ucis,
          path: nodes[l.leafNodeId].path,
          branchPly: l.branchPly,
          label: l.label,
          ordinal: l.ordinal,
        ),
    ];
    return RepertoireTree(
      root: nodes.first,
      userSide: userSide,
      nodes: nodes,
      lines: lines,
      description: description,
    );
  }

  /// The initial position.
  final TreeNode root;

  /// The repertoire's colour.
  final Side userSide;

  /// All nodes, indexed by id (preorder).
  final List<TreeNode> nodes;

  /// All lines in preorder of their leaves.
  final List<Line> lines;

  /// Comment before the first move of the first game, if any.
  final String? description;

  final Map<String, Line> _byKey;

  /// The node with [id].
  TreeNode node(int id) => nodes[id];

  /// The line with [key], or null.
  Line? lineByKey(String key) => _byKey[key];

  /// Flattens the tree for the database.
  RepertoireRows toRows() => RepertoireRows(
    nodes: [
      for (final n in nodes)
        NodeRow(
          nodeId: n.id,
          parentId: n.parent?.id,
          ply: n.ply,
          san: n.san,
          uci: n.uci,
          fen: n.fen,
          isUserMove: n.isUserMove,
          childIndex: n.childIndex,
          why: n.comment?.why,
          plan: n.comment?.plan,
          watch: n.comment?.watch,
          alt: n.comment?.alt,
          shapes: n.comment?.shapes ?? const [],
          rawComment: n.rawComment,
          nags: n.nags,
        ),
    ],
    lines: [
      for (final l in lines)
        LineRow(
          lineKey: l.key,
          leafNodeId: l.leaf.id,
          ordinal: l.ordinal,
          plies: l.plies,
          userMoveCount: l.userMoveCount,
          branchPly: l.branchPly,
          label: l.label,
          ucis: l.ucis,
        ),
    ],
  );
}
