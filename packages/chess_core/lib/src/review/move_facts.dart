import 'dart:math' as math;

import 'package:dartchess/dartchess.dart';

/// Piece values in pawns for material and exchanges (king large for SEE).
int pieceValue(Role role) => switch (role) {
  Role.pawn => 1,
  Role.knight => 3,
  Role.bishop => 3,
  Role.rook => 5,
  Role.queen => 9,
  Role.king => 100,
};

/// Board facts about one played move that the classifier needs
/// (classification-research.md §5), computed from the position before it.
final class MoveFacts {
  /// Creates the facts.
  const new({
    required this.forced,
    required this.inCheck,
    required this.capture,
    required this.recapture,
    required this.easyCapture,
    required this.fleesCheaperAttacker,
    required this.capturedValue,
    required this.hangingValue,
  });

  /// The only legal move.
  final bool forced;

  /// The mover was in check.
  final bool inCheck;

  /// The move captures.
  final bool capture;

  /// It captures on the square where the previous move captured.
  final bool recapture;

  /// It captures an undefended piece, or one worth at least the capturer.
  final bool easyCapture;

  /// The moved piece stood attacked by a cheaper enemy piece.
  final bool fleesCheaperAttacker;

  /// Pawns' worth the move captured (0 for none).
  final int capturedValue;

  /// Afterwards, the most the opponent wins by static exchange on one of
  /// the mover's pieces (knight or bigger) that was not already attacked
  /// as badly before the move; 0 when none newly hangs. A check or a
  /// retreat that leaves an earlier threat standing is not a sacrifice.
  final int hangingValue;

  /// The move leaves a piece hanging for more than it took, by at least
  /// [minPawns]: the static half of the sacrifice test.
  bool sacrificesPiece({int minPawns = 2}) =>
      hangingValue - capturedValue >= minPawns;
}

/// Facts for [move] in [before]; [previousCapture] is the square the
/// previous move captured on (null when it did not capture).
MoveFacts moveFacts(
  Position before,
  NormalMove move, {
  Square? previousCapture,
}) {
  final board = before.board;
  final mover = before.turn;
  final piece = board.pieceAt(move.from)!;
  final captured = board.pieceAt(move.to);
  final enPassant =
      piece.role == Role.pawn &&
      captured == null &&
      move.from.file != move.to.file;
  final capture = (captured != null && captured.color != mover) || enPassant;
  var legal = 0;
  for (final targets in before.legalMoves.values) {
    legal += targets.size;
  }
  final defenders = board.attacksTo(
    move.to,
    mover.opposite,
    occupied: board.occupied.withoutSquare(move.from),
  );
  final easy =
      capture &&
      (defenders.isEmpty ||
          pieceValue(captured?.role ?? Role.pawn) >= pieceValue(piece.role));
  final attackers = board.attacksTo(move.from, mover.opposite);
  final flees = attackers.squares.any(
    (s) => pieceValue(board.roleAt(s)!) < pieceValue(piece.role),
  );
  final after = before.play(move);
  return MoveFacts(
    forced: legal == 1,
    inCheck: before.isCheck,
    capture: capture,
    recapture: capture && previousCapture == move.to,
    easyCapture: easy,
    fleesCheaperAttacker: flees,
    capturedValue: capture ? pieceValue(captured?.role ?? Role.pawn) : 0,
    hangingValue: _newlyHanging(board, after.board, mover, move),
  );
}

int _newlyHanging(Board before, Board after, Side mover, NormalMove move) {
  var worst = 0;
  for (final s in after.bySide(mover).squares) {
    final role = after.roleAt(s)!;
    if (role == Role.pawn || role == Role.king) continue;
    final now = see(after, s, mover.opposite);
    if (now <= worst) continue;
    // Another piece that was already attacked as badly is not newly given
    // up; the moved piece always is (it could have gone elsewhere).
    final was = s == move.to ? 0 : see(before, s, mover.opposite);
    worst = math.max(worst, now - math.max(0, was));
  }
  return worst;
}

/// Static exchange evaluation: material [attacker] wins (in pawns) by
/// capturing on [square] and exchanging with least-valuable pieces first
/// (x-rays included; pins ignored). 0 when nothing attacks it.
int see(Board board, Square square, Side attacker) {
  final target = board.roleAt(square);
  if (target == null) return 0;
  var occupied = board.occupied;
  final gains = <int>[pieceValue(target)];
  var side = attacker;
  var from = _leastValuable(board, square, side, occupied);
  while (from != null) {
    final value = pieceValue(board.roleAt(from)!);
    occupied = occupied.withoutSquare(from);
    side = side.opposite;
    gains.add(value - gains.last);
    from = _leastValuable(board, square, side, occupied);
  }
  // gains[i] is the balance after capture i, assuming capture i+1 follows.
  for (var i = gains.length - 2; i > 0; i--) {
    gains[i - 1] = -math.max(-gains[i - 1], gains[i]);
  }
  return gains.length == 1 ? 0 : gains.first;
}

Square? _leastValuable(
  Board board,
  Square square,
  Side side,
  SquareSet occupied,
) {
  Square? best;
  var bestValue = 1 << 20;
  final attackers = board
      .attacksTo(square, side, occupied: occupied)
      .intersect(occupied);
  for (final s in attackers.squares) {
    final v = pieceValue(board.roleAt(s)!);
    if (v < bestValue) {
      bestValue = v;
      best = s;
    }
  }
  return best;
}

/// Material of [side] in pawns; [piecesOnly] leaves pawns out.
int material(Board board, Side side, {bool piecesOnly = false}) {
  var total = 0;
  for (final s in board.bySide(side).squares) {
    final role = board.roleAt(s)!;
    if (role == Role.king || (piecesOnly && role == Role.pawn)) continue;
    total += pieceValue(role);
  }
  return total;
}

/// The most [side] wins by static exchange on any enemy piece but the
/// king; 0 when nothing is attacked profitably.
int bestCapture(Board board, Side side) {
  var best = 0;
  for (final s in board.bySide(side.opposite).squares) {
    if (board.roleAt(s) == Role.king) continue;
    best = math.max(best, see(board, s, side));
  }
  return best;
}

/// Whether the engine line [pv] (UCI, from [after], the position after the
/// mover's move) settles with the mover at least [minPawns] down and with
/// less piece material relative to the opponent: a real sacrifice, not a
/// pawn grab. At most [plies] plies are played. Both ends are settled by
/// static exchange, so an exchange the line stops in the middle of does
/// not count, and neither does material a check made the mover lose
/// anyway.
bool pvSacrifice(
  Position before,
  Position after,
  List<String> pv, {
  int minPawns = 2,
  int plies = 8,
}) {
  final mover = before.turn;
  int balance(Board b, {bool pieces = false}) =>
      material(b, mover, piecesOnly: pieces) -
      material(b, mover.opposite, piecesOnly: pieces);
  var p = after;
  for (final uci in pv.take(plies)) {
    final parsed = Move.parse(uci);
    if (parsed is! NormalMove) break;
    final m = p.normalizeMove(parsed) as NormalMove;
    if (!p.isLegal(m)) break;
    p = p.play(m);
  }
  // Answering a check cannot save a piece that was already lost; any
  // other move could have, so giving it up is a choice.
  final start =
      balance(before.board) -
      (before.isCheck ? bestCapture(before.board, mover.opposite) : 0);
  final end =
      balance(p.board) +
      (p.turn == mover
          ? bestCapture(p.board, mover)
          : -bestCapture(p.board, mover.opposite));
  return start - end >= minPawns &&
      balance(p.board, pieces: true) < balance(before.board, pieces: true);
}
