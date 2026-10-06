import 'package:dartchess/dartchess.dart' show Side;
import 'package:flutter/foundation.dart';

/// A move played off the repertoire (free exploration, a deviation, play
/// on); never saved.
@immutable
final class FreeMove {
  /// Creates the move.
  const new({required this.uci, required this.san, required this.fen});

  /// UCI as the tree writes it.
  final String uci;

  /// SAN.
  final String san;

  /// Position after the move.
  final String fen;
}

/// Where Play on vs engine starts (01-product-spec §8.2): the last
/// repertoire node reached and the off-book moves after it.
@immutable
final class PlayOnArgs {
  /// Creates the arguments.
  const new({
    required this.repertoireId,
    required this.nodeId,
    required this.nodeFen,
    required this.userSide,
    required this.orientation,
    this.moves = const [],
  });

  /// The repertoire.
  final String repertoireId;

  /// Last repertoire node reached.
  final int nodeId;

  /// Its position.
  final String nodeFen;

  /// Off-book moves after it (deviation, reply).
  final List<FreeMove> moves;

  /// The user's colour.
  final Side userSide;

  /// Board orientation.
  final Side orientation;

  /// The start position.
  String get fen => moves.isEmpty ? nodeFen : moves.last.fen;
}
