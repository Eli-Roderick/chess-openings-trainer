import 'package:chess_core/src/pgn/comment_parser.dart';
import 'package:chess_core/src/tree/repertoire_tree.dart';
import 'package:chess_core/src/tree/tree_node.dart';

/// Exports [tree] as one PGN game: mainline plus variations, comments
/// re-serialized in canonical tag order (`why plan watch alt cal csl`) and
/// NAGs as `$n`.
///
/// Used for round-trip tests and generated PGNs; the app's "Export PGN"
/// writes the stored original text instead.
String exportPgn(
  RepertoireTree tree, {
  Map<String, String> headers = const {},
}) => exportPgnFromRoot(
  tree.root,
  headers: headers,
  description: tree.description,
);

/// Exports the tree under [root]; see [exportPgn].
String exportPgnFromRoot(
  TreeNode root, {
  Map<String, String> headers = const {},
  String? description,
}) {
  final b = StringBuffer();
  headers.forEach((k, v) {
    final escaped = v.replaceAll(r'\', r'\\').replaceAll('"', r'\"');
    b.writeln('[$k "$escaped"]');
  });
  if (headers.isNotEmpty) b.writeln();

  final tokens = <String>[];
  if (description != null) tokens.add('{${_safe(description)}}');
  _writeLine(root, tokens, forceNumber: true);
  tokens.add('*');

  var lineLength = 0;
  var glue = false; // no space after '('
  for (final t in tokens) {
    final attach = glue || t == ')'; // no space before ')'
    if (!attach && lineLength > 0 && lineLength + 1 + t.length > 79) {
      b.writeln();
      lineLength = 0;
    } else if (!attach && lineLength > 0) {
      b.write(' ');
      lineLength++;
    }
    b.write(t);
    lineLength += t.length;
    glue = t == '(';
  }
  b.writeln();
  return b.toString();
}

String _safe(String text) => text.replaceAll('}', ')');

/// Writes the mainline below [parent], with each move's variations right
/// after it.
void _writeLine(
  TreeNode parent,
  List<String> tokens, {
  required bool forceNumber,
}) {
  var node = parent;
  var needNumber = forceNumber;
  while (node.children.isNotEmpty) {
    final main = node.children.first;
    needNumber = _writeMove(main, tokens, needNumber: needNumber);
    for (final alt in node.children.skip(1)) {
      tokens.add('(');
      final after = _writeMove(alt, tokens, needNumber: true);
      _writeLine(alt, tokens, forceNumber: after);
      tokens.add(')');
      needNumber = true;
    }
    node = main;
  }
}

/// Writes one move with its NAGs and comment; returns whether the next move
/// needs a move number (a Black move after a comment, NAG or variation).
bool _writeMove(TreeNode n, List<String> tokens, {required bool needNumber}) {
  final moveNo = (n.ply + 1) ~/ 2;
  final white = n.ply.isOdd;
  if (white) {
    tokens.add('$moveNo.');
  } else if (needNumber) {
    tokens.add('$moveNo...');
  }
  tokens.add(n.san!);
  for (final nag in n.nags) {
    tokens.add('\$$nag');
  }
  final comment = n.comment;
  if (comment != null) tokens.add('{${formatComment(comment)}}');
  return comment != null || n.nags.isNotEmpty;
}
