import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Line identity (docs/plan/03-data-model.md §3): the first 16 hex characters
/// of SHA-256 of the space-separated UCI sequence.
String lineKey(String ucis) =>
    sha256.convert(utf8.encode(ucis)).toString().substring(0, 16);

const _castlingKingTo = {
  'e1h1': 'e1g1',
  'e1a1': 'e1c1',
  'e8h8': 'e8g8',
  'e8a8': 'e8c8',
};

/// Normalizes a UCI move: lower case, and castling written as king-takes-rook
/// (`e1h1`, as dartchess represents it) becomes king two squares (`e1g1`).
///
/// [isCastling] must be true only for castling moves, because `e1h1` is also
/// a legal non-castling rook-file move for other pieces.
String normalizeUci(String uci, {required bool isCastling}) {
  final lower = uci.toLowerCase();
  if (!isCastling) return lower;
  return _castlingKingTo[lower] ?? lower;
}
