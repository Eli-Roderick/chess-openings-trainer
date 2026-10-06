import 'package:chess_core/chess_core.dart';
import 'package:dartchess/dartchess.dart';

/// The position described by [fen].
Position positionFromFen(String fen) => Chess.fromSetup(Setup.parseFen(fen));

/// A legal move resolved against a position.
typedef ResolvedMove = ({String uci, String san, Position after});

/// Resolves [move] in [position]: SAN, the position after it and the UCI as
/// the repertoire tree stores it (castling as king two squares, `e1g1`,
/// whichever way the piece was moved). Null if the move is illegal.
ResolvedMove? resolveMove(Position position, NormalMove move) {
  final normalized = position.normalizeMove(move);
  if (!position.isLegal(normalized)) return null;
  final (after, san) = position.makeSan(normalized);
  return (
    uci: normalizeUci(normalized.uci, isCastling: san.startsWith('O-O')),
    san: san,
    after: after,
  );
}

/// Parses a tree UCI (`e2e4`, `e7e8q`, castling `e1g1`) as a board move.
NormalMove? parseUci(String uci) => switch (Move.parse(uci)) {
  final NormalMove m => m,
  _ => null,
};
