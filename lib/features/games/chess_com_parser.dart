import 'dart:convert';

import 'package:chess_core/chess_core.dart';
import 'package:drift/drift.dart';
import 'package:repertoire_trainer/core/db/app_database.dart';

/// chess.com result codes that are draws.
const _draws = {
  'agreed',
  'repetition',
  'stalemate',
  'insufficient',
  '50move',
  'timevsinsufficient',
};

/// Months (`YYYY/MM`) in an archive-list body, newest first.
List<String> parseArchiveList(String body) {
  final urls = (jsonDecode(body) as Map<String, dynamic>)['archives'];
  if (urls is! List) return const [];
  final months = <String>[];
  for (final u in urls) {
    final segments = Uri.tryParse('$u')?.pathSegments ?? const <String>[];
    if (segments.length < 2) continue;
    final y = segments[segments.length - 2];
    final m = segments.last;
    if (RegExp(r'^\d{4}$').hasMatch(y) && RegExp(r'^\d{2}$').hasMatch(m)) {
      months.add('$y/$m');
    }
  }
  return months..sort((a, b) => b.compareTo(a));
}

/// Input of [parseMonth] (sent to an isolate).
typedef MonthInput = ({String body, String username, int fetchedAt});

/// Rows for the standard-chess games of [input]'s month body that
/// its username played. Variants, set-up positions and games
/// whose PGN does not parse are skipped. Pure: runs in an isolate.
List<ImportedGamesCompanion> parseMonth(MonthInput input) {
  final user = input.username.toLowerCase();
  final games = (jsonDecode(input.body) as Map<String, dynamic>)['games'];
  if (games is! List) return const [];
  final out = <ImportedGamesCompanion>[];
  for (final g in games.whereType<Map<String, dynamic>>()) {
    final row = _row(g, user, input.fetchedAt);
    if (row != null) out.add(row);
  }
  return out;
}

ImportedGamesCompanion? _row(Map<String, dynamic> g, String user, int now) {
  if ((g['rules'] ?? 'chess') != 'chess') return null;
  final white = g['white'];
  final black = g['black'];
  final pgn = g['pgn'];
  final url = g['url'];
  final end = g['end_time'];
  if (white is! Map || black is! Map || pgn is! String || url is! String) {
    return null;
  }
  if (end is! int) return null;
  final userWhite = '${white['username']}'.toLowerCase() == user;
  if (!userWhite && '${black['username']}'.toLowerCase() != user) {
    return null;
  }
  final parsed = parsePlayedGame(pgn);
  if (parsed == null || parsed.ucis.isEmpty) return null;
  final mine = '${(userWhite ? white : black)['result']}';
  final theirs = '${(userWhite ? black : white)['result']}';
  final result = mine == 'win'
      ? 'win'
      : _draws.contains(mine)
      ? 'draw'
      : 'loss';
  final id = g['uuid'] is String
      ? g['uuid'] as String
      : Uri.parse(url).pathSegments.last;
  return ImportedGamesCompanion.insert(
    id: 'chesscom:$id',
    username: user,
    url: url,
    endTime: end,
    timeClass: '${g['time_class'] ?? 'unknown'}',
    timeControl: '${g['time_control'] ?? '-'}',
    rated: g['rated'] == true,
    userWhite: userWhite,
    result: result,
    resultDetail: result == 'win' ? theirs : mine,
    whiteName: '${white['username']}',
    blackName: '${black['username']}',
    whiteRating: (white['rating'] as num?)?.toInt() ?? 0,
    blackRating: (black['rating'] as num?)?.toInt() ?? 0,
    eco: Value(parsed.eco),
    opening: Value(
      parsed.opening ??
          openingFromEcoUrl(g['eco'] is String ? g['eco'] as String : null),
    ),
    ucis: parsed.ucis.join(' '),
    sans: parsed.sans.join(' '),
    clocks: Value(parsed.clocks?.join(',')),
    chessComWhiteAccuracy: Value(_accuracy(g['accuracies'], 'white')),
    chessComBlackAccuracy: Value(_accuracy(g['accuracies'], 'black')),
    pgn: pgn,
    fetchedAt: now,
  );
}

double? _accuracy(Object? accuracies, String side) {
  if (accuracies is! Map) return null;
  final v = accuracies[side];
  return v is num ? v.toDouble() : null;
}
