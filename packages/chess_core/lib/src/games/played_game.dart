import 'package:chess_core/src/pgn/pgn_reader.dart';
import 'package:chess_core/src/tree/line_key.dart';
import 'package:dartchess/dartchess.dart';

/// A played game (one PGN mainline) reduced to what Game Review stores:
/// UCI and SAN moves, remaining clock per ply when the PGN has `%clk`.
final class PlayedGame {
  /// Creates a game.
  const new({
    required this.ucis,
    required this.sans,
    this.clocks,
    this.eco,
    this.opening,
  });

  /// Moves in UCI (castling as king two squares), from the standard start
  /// position.
  final List<String> ucis;

  /// The same moves in SAN.
  final List<String> sans;

  /// Remaining clock after each ply in tenths of a second, or null when
  /// any ply lacks a `%clk` comment.
  final List<int>? clocks;

  /// ECO code from the `ECO` tag.
  final String? eco;

  /// Opening name from the `Opening` tag, else from chess.com's `ECOUrl`.
  final String? opening;
}

final _clkRe = RegExp(r'\[%clk\s+(\d+):(\d{1,2}):(\d{1,2})(?:\.(\d))?\]');

/// Parses the first game of [pgn]. Null when it is unreadable, has an
/// illegal move, or is not standard chess from the start position.
PlayedGame? parsePlayedGame(String pgn) {
  final read = readPgn(pgn);
  if (read.games.isEmpty) return null;
  final game = read.games.first;
  final h = game.headers;
  final variant = h['Variant']?.trim().toLowerCase();
  if (variant != null && variant != 'standard' && variant != 'chess') {
    return null;
  }
  final fen = h['FEN']?.trim();
  if (fen != null && fen.isNotEmpty && fen != kInitialFEN) return null;
  Position position = Chess.initial;
  final ucis = <String>[];
  final sans = <String>[];
  List<int>? clocks = <int>[];
  for (var m = game.root.children.firstOrNull; m != null;) {
    final move = position.parseSan(m.san);
    if (move == null) return null;
    final (after, san) = position.makeSan(move);
    ucis.add(normalizeUci(move.uci, isCastling: san.startsWith('O-O')));
    sans.add(san);
    position = after;
    final clk = clocks == null ? null : _clock(m.comments);
    clocks = clk == null ? null : (clocks!..add(clk));
    m = m.children.firstOrNull;
  }
  return PlayedGame(
    ucis: ucis,
    sans: sans,
    clocks: clocks == null || clocks.isEmpty ? null : clocks,
    eco: _tag(h['ECO']),
    opening: _tag(h['Opening']) ?? openingFromEcoUrl(h['ECOUrl']),
  );
}

String? _tag(String? v) {
  final t = v?.trim();
  return t == null || t.isEmpty || t == '?' ? null : t;
}

int? _clock(List<String> comments) {
  for (final c in comments) {
    final m = _clkRe.firstMatch(c);
    if (m != null) {
      final s =
          int.parse(m[1]!) * 3600 + int.parse(m[2]!) * 60 + int.parse(m[3]!);
      return s * 10 + int.parse(m[4] ?? '0');
    }
  }
  return null;
}

/// The opening name in a chess.com `ECOUrl`, without its trailing move
/// list: `.../openings/Caro-Kann-Defense-Advance-Variation-3...c5` gives
/// "Caro-Kann Defense Advance Variation". Hyphens inside names such as
/// "Caro-Kann" cannot be told apart from word breaks, so known compound
/// names are restored.
String? openingFromEcoUrl(String? url) {
  if (url == null) return null;
  final slug = Uri.tryParse(url.trim())?.pathSegments.lastOrNull;
  if (slug == null || slug.isEmpty) return null;
  final words = <String>[];
  for (final w in slug.split('-')) {
    if (w.isEmpty) continue;
    if (RegExp(r'^\d').hasMatch(w)) break;
    words.add(w);
  }
  if (words.isEmpty) return null;
  var name = words.join(' ');
  for (final c in _compounds) {
    name = name.replaceAll(c.replaceAll('-', ' '), c);
  }
  return name;
}

const _compounds = [
  'Caro-Kann',
  'Nimzo-Indian',
  'Bogo-Indian',
  'Nimzo-Larsen',
  'Smith-Morra',
  'Max-Lange',
];
