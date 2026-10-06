import 'dart:collection';

import 'package:chess_core/src/pgn/move_comment.dart';
import 'package:meta/meta.dart';

/// A position in a repertoire tree (docs/plan/03-data-model.md §6).
///
/// The root (ply 0, no move) holds the initial position. Nodes are created
/// parent-first by the importer or `RepertoireTree.fromRows`; the tree is not
/// modified after it is built.
final class TreeNode {
  /// Creates a node. Use [addChild] to build a tree.
  @internal
  new({
    required this.id,
    required this.parent,
    required this.ply,
    required this.fen,
    required this.isUserMove,
    this.san,
    this.uci,
    this.comment,
    this.rawComment,
    List<int> nags = const [],
  }) : nags = List.unmodifiable(nags);

  /// Preorder index, root 0 (`nodes.nodeId`).
  final int id;

  /// The previous position, or null for the root.
  final TreeNode? parent;

  /// Number of half-moves from the initial position.
  final int ply;

  /// SAN of the move leading here (null for the root).
  final String? san;

  /// UCI of the move leading here, castling as king two squares (null for
  /// the root).
  final String? uci;

  /// FEN of the position after the move.
  final String fen;

  /// True if the move leading here was played by the repertoire's side.
  final bool isUserMove;

  /// Parsed comment (also kept for opponent moves; the UI shows user moves'
  /// only).
  final MoveComment? comment;

  /// The original comment text (all comments after the move joined).
  final String? rawComment;

  /// NAGs, stored but not shown.
  final List<int> nags;

  final List<TreeNode> _children = [];

  /// Following moves in PGN order (mainline first).
  late final List<TreeNode> children = UnmodifiableListView(_children);

  /// Appends [child] (built with this node as parent) and returns it.
  @internal
  TreeNode addChild(TreeNode child) {
    assert(identical(child.parent, this), 'child must point to this parent');
    _children.add(child);
    return child;
  }

  /// True for the initial position.
  bool get isRoot => parent == null;

  /// True if no move follows.
  bool get isLeaf => _children.isEmpty;

  /// Index among the parent's children (0 for the root).
  int get childIndex => parent?._children.indexOf(this) ?? 0;

  /// Nodes from the first move to this one (empty for the root).
  List<TreeNode> get path {
    final out = <TreeNode>[];
    for (TreeNode? n = this; n != null && !n.isRoot; n = n.parent) {
      out.add(n);
    }
    return out.reversed.toList();
  }

  @override
  String toString() => 'TreeNode($id, ply $ply, ${san ?? 'root'})';
}
