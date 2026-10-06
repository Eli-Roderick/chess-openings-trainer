import 'dart:math';

import 'package:chess_core/src/pgn/move_comment.dart';
import 'package:chess_core/src/pgn/pgn_exporter.dart';
import 'package:chess_core/src/tree/line_key.dart';
import 'package:chess_core/src/tree/tree_node.dart';
import 'package:dartchess/dartchess.dart';

/// Generates a legal repertoire PGN with exactly [lines] lines (fewer only if
/// the tree runs out of legal branches) of [depth] plies, deterministic for
/// a given [seed]. Every [userSide] move carries a short tagged comment.
///
/// Used by benchmarks and tests (`tool/gen_synthetic_pgn.dart`).
String generateSyntheticPgn({
  required int lines,
  required int depth,
  required int seed,
  Side userSide = Side.white,
}) {
  final rng = Random(seed);
  final root = _GNode(null, Chess.initial, '', '');
  final internal = <_GNode>[];

  void extend(_GNode from) {
    var node = from;
    while (node.ply < depth) {
      final moves = node.unusedMoves();
      if (moves.isEmpty) return;
      internal.add(node);
      node = node.add(moves[_pick(rng, moves.length)]);
    }
  }

  extend(root);
  var leaves = 1;
  var attempts = 0;
  while (leaves < lines && attempts < lines * 50) {
    attempts++;
    final from = internal[rng.nextInt(internal.length)];
    final moves = from.unusedMoves();
    if (moves.isEmpty) continue;
    extend(from.add(moves[_pick(rng, moves.length)]));
    leaves++;
  }

  var id = 0;
  TreeNode build(_GNode g, TreeNode? parent) {
    final isUser = g.ply > 0 && g.ply.isOdd == (userSide == Side.white);
    final node = TreeNode(
      id: id++,
      parent: parent,
      ply: g.ply,
      san: g.parent == null ? null : g.san,
      uci: g.parent == null ? null : g.uci,
      fen: g.position.fen,
      isUserMove: isUser,
      comment: isUser
          ? MoveComment(
              why:
                  'Synthetic move ${g.ply}: ${g.san} keeps the pieces '
                  'coordinated and prepares the next step of the plan.',
            )
          : null,
    );
    parent?.addChild(node);
    for (final c in g.children) {
      build(c, node);
    }
    return node;
  }

  return exportPgnFromRoot(
    build(root, null),
    headers: {
      'Event': 'Synthetic repertoire',
      'ChapterName': 'Synthetic $lines x $depth seed $seed',
    },
  );
}

/// Picks an index, preferring the first entries of a list sorted by
/// [_plausibility], so lines look roughly like openings.
int _pick(Random rng, int n) {
  final x = rng.nextDouble();
  return (x * x * x * n).floor();
}

final class _GNode {
  new(this.parent, this.position, this.san, this.uci)
    : ply = parent == null ? 0 : parent.ply + 1;

  final _GNode? parent;
  final Position position;
  final String san;
  final String uci;
  final int ply;
  final List<_GNode> children = [];

  /// Legal moves not yet played from here, as (SAN, UCI, position).
  List<(String, String, Position)> unusedMoves() {
    final used = {for (final c in children) c.uci};
    final out = <(String, String, Position)>[];
    final seen = <String>{};
    for (final MapEntry(key: from, value: targets)
        in position.legalMoves.entries) {
      for (final to in targets.squares) {
        final piece = position.board.pieceAt(from);
        final promotes =
            piece?.role == Role.pawn &&
            (to.rank.value == 0 || to.rank.value == 7);
        final move = NormalMove(
          from: from,
          to: to,
          promotion: promotes ? Role.queen : null,
        );
        if (!position.isLegal(move)) continue;
        final (after, san) = position.makeSan(move);
        final uci = normalizeUci(move.uci, isCastling: san.startsWith('O-O'));
        if (used.contains(uci) || !seen.add(uci)) continue;
        out.add((san, uci, after));
      }
    }
    out.sort((a, b) => _plausibility(b.$1, ply) - _plausibility(a.$1, ply));
    return out;
  }

  _GNode add((String, String, Position) m) {
    final (san, uci, after) = m;
    final child = _GNode(this, after, san, uci);
    children.add(child);
    return child;
  }
}

const _centre = {'d4', 'e4', 'd5', 'e5'};
const _wideCentre = {
  'c3',
  'c4',
  'c5',
  'c6',
  'd3',
  'd6',
  'e3',
  'e6',
  'f3',
  'f4',
  'f5',
  'f6',
};

/// Rough opening-likeness of a SAN move played at ply [ply] (higher is more
/// typical): central pawns, minor-piece development and castling first.
int _plausibility(String san, int ply) {
  if (san.startsWith('O-O')) return 6;
  final dest = RegExp('[a-h][1-8]').allMatches(san).last[0]!;
  var score = 0;
  if (_centre.contains(dest)) score += 3;
  if (_wideCentre.contains(dest)) score += 2;
  final piece = san[0];
  if (piece == 'N' || piece == 'B') score += 2;
  if (san.contains('x')) score += 1;
  if (piece == 'K') score -= 4;
  if ((piece == 'Q' || piece == 'R') && ply < 12) score -= 2;
  return score;
}
