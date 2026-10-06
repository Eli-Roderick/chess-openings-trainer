import 'package:chess_core/src/tree/tree_node.dart';

/// Start ply for "Branch point" mode (docs/plan/04-algorithms.md §6): the ply
/// of the deepest fork on the line that still has a user move after it, or 0.
///
/// [path] is the line's nodes from the first move to the leaf (root
/// excluded); the root is reached through the first node's parent.
int branchPly(List<TreeNode> path) {
  if (path.isEmpty) return 0;
  final full = [path.first.parent!, ...path];
  // full[k] is the leaf; candidates are full[0 .. k-1].
  for (var i = full.length - 2; i >= 0; i--) {
    final fork = full[i];
    if (fork.children.length < 2) continue;
    for (var j = i + 1; j < full.length; j++) {
      if (full[j].isUserMove) return fork.ply;
    }
  }
  return 0;
}
