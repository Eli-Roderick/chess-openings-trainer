import 'package:chess_core/src/tree/repertoire_tree.dart';
import 'package:chess_core/src/tree/tree_node.dart';

/// Who left the repertoire first.
enum LeftBy {
  /// The user played a move the repertoire does not have.
  user,

  /// The opponent played a reply the repertoire does not cover.
  opponent,

  /// The repertoire line ended; the game went on.
  repertoireEnd,

  /// The game ended inside the repertoire.
  gameEnd,
}

/// Where a played game leaves a repertoire.
final class RepertoireLink {
  /// Creates the link.
  const new({required this.node, required this.leftBy, this.played});

  /// The last position the game shared with the repertoire (the root when
  /// the first move already differs).
  final TreeNode node;

  /// Who left.
  final LeftBy leftBy;

  /// The move played after [node] (UCI); null for [LeftBy.gameEnd].
  final String? played;

  /// Plies the game followed the repertoire.
  int get ply => node.ply;

  /// The repertoire's moves at [node] (the book moves the game missed).
  List<TreeNode> get expected => node.children;
}

/// Follows [ucis] (castling as king two squares) through [tree].
RepertoireLink linkGame(RepertoireTree tree, List<String> ucis) {
  var node = tree.root;
  var i = 0;
  for (; i < ucis.length; i++) {
    TreeNode? next;
    for (final c in node.children) {
      if (c.uci == ucis[i]) {
        next = c;
        break;
      }
    }
    if (next == null) break;
    node = next;
  }
  if (i == ucis.length) {
    return RepertoireLink(node: node, leftBy: LeftBy.gameEnd);
  }
  return RepertoireLink(
    node: node,
    played: ucis[i],
    leftBy: node.isLeaf
        ? LeftBy.repertoireEnd
        : node.children.first.isUserMove
        ? LeftBy.user
        : LeftBy.opponent,
  );
}

/// The tree among [trees] the game follows longest, with its link; null
/// when [trees] is empty.
(RepertoireTree, RepertoireLink)? bestLink(
  Iterable<RepertoireTree> trees,
  List<String> ucis,
) {
  (RepertoireTree, RepertoireLink)? best;
  for (final t in trees) {
    final link = linkGame(t, ucis);
    if (best == null || link.ply > best.$2.ply) best = (t, link);
  }
  return best;
}
