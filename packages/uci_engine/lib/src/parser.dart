import 'package:meta/meta.dart';

/// A UCI score: centipawns or mate in [mate] moves, from the side to move.
@immutable
final class EngineScore {
  /// Centipawns.
  const new cp(int this.cp) : mate = null;

  /// Mate in [mate] moves (negative: the side to move gets mated).
  const new mate(int this.mate) : cp = null;

  /// Centipawns, or null for a mate score.
  final int? cp;

  /// Moves to mate, or null for a centipawn score.
  final int? mate;

  /// The same score from the other side's point of view.
  EngineScore get negated =>
      cp != null ? EngineScore.cp(-cp!) : EngineScore.mate(-mate!);

  @override
  bool operator ==(Object other) =>
      other is EngineScore && other.cp == cp && other.mate == mate;

  @override
  int get hashCode => Object.hash(cp, mate);

  @override
  String toString() => cp != null ? 'cp $cp' : 'mate $mate';
}

/// One parsed `info` line that carries a score.
@immutable
final class SearchInfo {
  /// Creates the info.
  const new({
    required this.depth,
    required this.multiPv,
    required this.score,
    required this.pv,
    this.selDepth,
    this.nodes,
    this.nps,
    this.timeMs,
    this.bound = false,
  });

  /// Search depth.
  final int depth;

  /// Selective depth.
  final int? selDepth;

  /// Which principal variation (1-based).
  final int multiPv;

  /// Score from the side to move.
  final EngineScore score;

  /// True for `lowerbound`/`upperbound` scores (not final; ignored for
  /// judgements).
  final bool bound;

  /// Nodes searched.
  final int? nodes;

  /// Nodes per second.
  final int? nps;

  /// Search time.
  final int? timeMs;

  /// The variation, UCI moves.
  final List<String> pv;
}

/// `bestmove` line.
@immutable
final class BestMove {
  /// Creates it.
  const new(this.move, {this.ponder});

  /// The move, or null for `(none)` (no legal moves).
  final String? move;

  /// The expected reply.
  final String? ponder;
}

/// Parses an `info` line; null when it has no score (currmove, string, ...)
/// or no pv.
SearchInfo? parseInfo(String line) {
  final t = line.trim().split(RegExp(r'\s+'));
  if (t.isEmpty || t.first != 'info') return null;
  int? depth;
  int? selDepth;
  var multiPv = 1;
  EngineScore? score;
  var bound = false;
  int? nodes;
  int? nps;
  int? time;
  List<String>? pv;
  int? intAt(int i) => i < t.length ? int.tryParse(t[i]) : null;
  for (var i = 1; i < t.length; i++) {
    switch (t[i]) {
      case 'depth':
        depth = intAt(++i);
      case 'seldepth':
        selDepth = intAt(++i);
      case 'multipv':
        multiPv = intAt(++i) ?? 1;
      case 'nodes':
        nodes = intAt(++i);
      case 'nps':
        nps = intAt(++i);
      case 'time':
        time = intAt(++i);
      case 'score':
        final kind = i + 1 < t.length ? t[i + 1] : null;
        final value = intAt(i + 2);
        if (value == null) return null;
        score = switch (kind) {
          'cp' => EngineScore.cp(value),
          'mate' => EngineScore.mate(value),
          _ => null,
        };
        i += 2;
        if (i + 1 < t.length &&
            (t[i + 1] == 'lowerbound' || t[i + 1] == 'upperbound')) {
          bound = true;
          i++;
        }
      case 'pv':
        pv = t.sublist(i + 1);
        i = t.length;
      case 'string':
        return null;
    }
  }
  if (depth == null || score == null || pv == null || pv.isEmpty) {
    return null;
  }
  return SearchInfo(
    depth: depth,
    selDepth: selDepth,
    multiPv: multiPv,
    score: score,
    bound: bound,
    nodes: nodes,
    nps: nps,
    timeMs: time,
    pv: pv,
  );
}

/// Parses a `bestmove` line; null for other lines.
BestMove? parseBestMove(String line) {
  final t = line.trim().split(RegExp(r'\s+'));
  if (t.isEmpty || t.first != 'bestmove' || t.length < 2) return null;
  final move = t[1] == '(none)' ? null : t[1];
  final ponder = t.length >= 4 && t[2] == 'ponder' ? t[3] : null;
  return BestMove(move, ponder: ponder);
}

/// The side to move of [fen] (`w` or `b`) without parsing the position.
bool whiteToMove(String fen) {
  final parts = fen.trim().split(RegExp(r'\s+'));
  return parts.length < 2 || parts[1] != 'b';
}
