import 'package:chess_core/src/tree/tree_node.dart';

/// Renders consecutive moves as "1.e4 e5 2.Nf3 Nc6", starting with
/// "3...Bc5" when the first move is Black's.
String sanPath(List<TreeNode> nodes) => formatSanMoves([
  for (final n in nodes) n.san!,
], firstPly: nodes.isEmpty ? 1 : nodes.first.ply);

/// Renders SAN moves whose first move has ply [firstPly] (1 = White's first
/// move) with move numbers.
String formatSanMoves(List<String> sans, {int firstPly = 1}) {
  final b = StringBuffer();
  for (var k = 0; k < sans.length; k++) {
    final ply = firstPly + k;
    final moveNo = (ply + 1) ~/ 2;
    final white = ply.isOdd;
    if (k > 0) b.write(' ');
    if (white) {
      b.write('$moveNo.');
    } else if (k == 0) {
      b.write('$moveNo...');
    }
    b.write(sans[k]);
  }
  return b.toString();
}

/// Number of trailing plies shown in a line label.
const labelTailPlies = 4;

/// Line label (docs/plan/03-data-model.md §4): `[prefix + ": "] + tail`, the
/// tail being the last [labelTailPlies] plies with move numbers, preceded by
/// "…" when the line is longer.
String lineLabel(List<TreeNode> path, {String? prefix}) {
  final truncated = path.length > labelTailPlies;
  final tailNodes = truncated
      ? path.sublist(path.length - labelTailPlies)
      : path;
  final tail = '${truncated ? '…' : ''}${sanPath(tailNodes)}';
  return (prefix == null || prefix.isEmpty) ? tail : '$prefix: $tail';
}

/// Label prefix from a game's headers: `ChapterName`, else `Opening`, else
/// `Event` unless it is `?` or empty.
String? labelPrefix(Map<String, String> headers) {
  for (final key in ['ChapterName', 'Opening', 'Event']) {
    final v = headers[key]?.trim();
    if (v != null && v.isNotEmpty && v != '?') return v;
  }
  return null;
}
