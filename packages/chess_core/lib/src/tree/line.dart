import 'package:chess_core/src/tree/tree_node.dart';
import 'package:meta/meta.dart';

/// A root-to-leaf path of a repertoire tree (docs/plan/03-data-model.md §6).
@immutable
final class Line {
  /// Creates a line.
  new({
    required this.key,
    required this.ucis,
    required List<TreeNode> path,
    required this.branchPly,
    required this.label,
    required this.ordinal,
  }) : path = List.unmodifiable(path);

  /// Line key (16 hex chars).
  final String key;

  /// Space-separated UCI sequence from the initial position.
  final String ucis;

  /// Nodes from the first move to the leaf (root excluded).
  final List<TreeNode> path;

  /// Start ply for "Branch point" mode.
  final int branchPly;

  /// Display label.
  final String label;

  /// Preorder position of the leaf among all leaves (display order).
  final int ordinal;

  /// The last node.
  TreeNode get leaf => path.last;

  /// Number of plies.
  int get plies => path.length;

  /// Number of moves by the repertoire's side.
  int get userMoveCount => path.where((n) => n.isUserMove).length;

  @override
  String toString() => 'Line($key, $label)';
}
