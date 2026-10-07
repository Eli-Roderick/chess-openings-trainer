import 'package:chess_core/src/tree/tree_node.dart';
import 'package:dartchess/dartchess.dart';

/// A named opening.
typedef Opening = ({String eco, String name});

/// Board, side to move, castling and en passant: a FEN without the move
/// counters, so transpositions match.
String positionKey(String fen) => fen.split(' ').take(4).join(' ');

/// The lichess opening table (lichess-org/chess-openings, CC0): every
/// position on a named line, with the most specific name reaching it.
final class OpeningBook {
  /// Parses lines of `eco<TAB>name<TAB>uci uci ...` (the app's asset).
  factory parse(String tsv) {
    // A line ending at a position names it; otherwise the first line
    // passing through it does.
    final exact = <String, Opening>{};
    final passing = <String, Opening>{};
    for (final line in tsv.split('\n')) {
      final cols = line.split('\t');
      if (cols.length < 3 || cols[2].trim().isEmpty) continue;
      final opening = (eco: cols[0], name: cols[1]);
      final ucis = cols[2].trim().split(' ');
      Position p = Chess.initial;
      for (var i = 0; i < ucis.length; i++) {
        final m = Move.parse(ucis[i]);
        if (m == null || !p.isLegal(m)) break;
        p = playUci(p, m);
        final key = positionKey(p.fen);
        if (i == ucis.length - 1) {
          exact[key] = opening;
        } else {
          passing.putIfAbsent(key, () => opening);
        }
      }
    }
    return OpeningBook._({...passing, ...exact});
  }

  new _(this._names);

  final Map<String, Opening> _names;

  /// Number of positions.
  int get size => _names.length;

  /// The opening of [fen], if it is a book position.
  Opening? at(String fen) => _names[positionKey(fen)];
}

/// The book plies of a game (1-based): the longest start where every move
/// follows one of the repertoire [roots] or reaches a position of
/// [table]. [fens] holds the position after each ply.
Set<int> bookPlies(
  List<String> ucis,
  List<String> fens, {
  OpeningBook? table,
  Iterable<TreeNode> roots = const [],
}) {
  var nodes = roots.toList();
  final out = <int>{};
  for (var i = 0; i < ucis.length; i++) {
    nodes = [
      for (final n in nodes)
        for (final c in n.children)
          if (c.uci == ucis[i]) c,
    ];
    if (nodes.isEmpty && table?.at(fens[i]) == null) break;
    out.add(i + 1);
  }
  return out;
}

/// The deepest named opening the game passes through, from [table].
Opening? openingOf(List<String> fens, OpeningBook table) {
  Opening? found;
  for (final f in fens) {
    found = table.at(f) ?? found;
  }
  return found;
}

/// Plays [move] (castling may be written as king two squares).
Position playUci(Position p, Move move) =>
    p.play(move is NormalMove ? p.normalizeMove(move) : move);

/// FENs after each move of [ucis] (legal moves from the start position).
List<String> fensOf(List<String> ucis) {
  Position p = Chess.initial;
  return [for (final uci in ucis) (p = playUci(p, Move.parse(uci)!)).fen];
}
