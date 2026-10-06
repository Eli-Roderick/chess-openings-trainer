import 'package:chess_core/src/training/attribution.dart';
import 'package:chess_core/src/tree/repertoire_tree.dart';
import 'package:chess_core/src/tree/tree_node.dart';
import 'package:meta/meta.dart';

/// What a re-import changes (docs/plan/03-data-model.md §5,
/// docs/plan/01-product-spec.md §13).
@immutable
final class ReimportDiff {
  /// Creates a diff.
  new({
    required List<String> unchanged,
    required Map<String, List<String>> extended,
    required List<String> removed,
    required List<String> added,
    required this.commentChanges,
  }) : unchanged = List.unmodifiable(unchanged),
       extended = Map.unmodifiable(extended),
       removed = List.unmodifiable(removed),
       added = List.unmodifiable(added);

  /// Keys present in both versions (stats kept).
  final List<String> unchanged;

  /// Old key → new keys extending it (history carried over).
  final Map<String, List<String>> extended;

  /// Old keys that are gone (stats archived).
  final List<String> removed;

  /// New keys that neither match nor extend an old line.
  final List<String> added;

  /// User moves present in both versions whose comment changed.
  final int commentChanges;
}

/// Compares the old and new lines of a re-import. [commentChanges] is
/// usually [countCommentChanges] of the two trees.
ReimportDiff diffReimport({
  required List<LineRef> oldLines,
  required List<LineRef> newLines,
  int commentChanges = 0,
}) {
  final index = LineIndex(newLines);
  final unchanged = <String>[];
  final extended = <String, List<String>>{};
  final removed = <String>[];
  for (final old in oldLines) {
    switch (index.attribute(ucis: old.ucis, lineKey: old.key)) {
      case DirectAttribution():
        unchanged.add(old.key);
      case InheritedAttribution(:final keys):
        extended[old.key] = keys;
      case ArchivedAttribution():
        removed.add(old.key);
    }
  }
  final matched = {...unchanged, for (final ks in extended.values) ...ks};
  return ReimportDiff(
    unchanged: unchanged,
    extended: extended,
    removed: removed,
    added: [
      for (final l in newLines)
        if (!matched.contains(l.key)) l.key,
    ],
    commentChanges: commentChanges,
  );
}

/// Number of user moves present in both trees (same move sequence) whose
/// parsed comment differs.
int countCommentChanges(RepertoireTree oldTree, RepertoireTree newTree) {
  String pathKey(TreeNode n) => n.path.map((p) => p.uci).join(' ');
  final oldByPath = {for (final n in oldTree.nodes.skip(1)) pathKey(n): n};
  var changes = 0;
  for (final n in newTree.nodes.skip(1)) {
    if (!n.isUserMove) continue;
    final old = oldByPath[pathKey(n)];
    if (old != null && old.comment != n.comment) changes++;
  }
  return changes;
}
