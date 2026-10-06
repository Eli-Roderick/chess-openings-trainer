import 'dart:convert';

import 'package:meta/meta.dart';

/// Severity of a report item.
enum ReportLevel {
  /// Blocks the import.
  error,

  /// Imported, but something should be fixed in the PGN.
  warning,

  /// For information only.
  info,
}

/// Every import report code with its level and message template
/// (docs/plan/07-comment-format.md §6). Placeholders are `{name}`.
enum ReportCode {
  /// Syntax error.
  parseError(
    'E-PARSE',
    ReportLevel.error,
    'PGN syntax error in game {g} near {path}: {detail}',
  ),

  /// Game does not start from the initial position, or is not standard chess.
  startError(
    'E-START',
    ReportLevel.error,
    'Game {g} does not start from the initial position',
  ),

  /// Illegal or ambiguous SAN.
  illegalMove(
    'E-ILLEGAL',
    ReportLevel.error,
    'Illegal or ambiguous move {san} at {path}',
  ),

  /// Null move (`--`).
  nullMove('E-NULL', ReportLevel.error, 'Null move at {path}'),

  /// No moves at all.
  empty('E-EMPTY', ReportLevel.error, 'No moves found'),

  /// File larger than 10 MB.
  size('E-SIZE', ReportLevel.error, 'File is larger than 10 MB'),

  /// Two different lines produced the same key.
  keyCollision(
    'E-KEY-COLLISION',
    ReportLevel.error,
    'Internal line-key collision; please report',
  ),

  /// User move without a comment.
  noComment('W-NO-COMMENT', ReportLevel.warning, '{move} has no comment'),

  /// User move with a comment but no `%why`.
  noWhy('W-NO-WHY', ReportLevel.warning, '{move} has a comment but no [%why]'),

  /// Tags could not be parsed.
  malformed(
    'W-MALFORMED',
    ReportLevel.warning,
    '{move}: comment tags are malformed; shown as plain text',
  ),

  /// A text tag appears twice.
  duplicateTag(
    'W-DUP-TAG',
    ReportLevel.warning,
    '{move}: [%{tag}] appears twice; texts joined',
  ),

  /// Text outside tags.
  looseText(
    'W-LOOSE-TEXT',
    ReportLevel.warning,
    '{move}: text outside tags added to Why',
  ),

  /// A text field over 400 characters.
  long(
    'W-LONG',
    ReportLevel.warning,
    '{move}: [%{tag}] is {n} characters (max 400 recommended)',
  ),

  /// Unknown `[%name ...]` tag.
  unknownTag(
    'W-UNKNOWN-TAG',
    ReportLevel.warning,
    '{move}: unknown tag [%{tag}] ignored',
  ),

  /// Invalid `%cal` / `%csl` entry.
  badShape(
    'W-BAD-SHAPE',
    ReportLevel.warning,
    "{move}: invalid arrow/square '{entry}' ignored",
  ),

  /// Same move with different comments in two games.
  conflict(
    'W-CONFLICT',
    ReportLevel.warning,
    "{move} has different comments in games {a} and {b}; kept game {a}'s",
  ),

  /// Same move twice among siblings in one game.
  duplicateVariation(
    'W-DUP-VARIATION',
    ReportLevel.warning,
    '{move} appears twice as a variation; merged',
  ),

  /// Variation-start comment attached to the following user move.
  commentBefore(
    'W-COMMENT-BEFORE',
    ReportLevel.warning,
    '{move}: comment placed before the move; attached to it',
  ),

  /// A line with none of the user's moves.
  noUserMove(
    'W-NO-USER-MOVE',
    ReportLevel.warning,
    'Line {path} contains none of your moves; it is skipped in training',
  ),

  /// More than 5,000 lines.
  large(
    'W-LARGE',
    ReportLevel.warning,
    '{n} lines: import and browsing will be slower',
  ),

  /// Untagged comment used as Why.
  plain('I-PLAIN', ReportLevel.info, '{move}: plain comment used as Why'),

  /// Variation-start comment that could not be attached (P01 addition, see
  /// docs/DECISIONS.md D-38).
  commentBeforeIgnored(
    'I-COMMENT-BEFORE-IGNORED',
    ReportLevel.info,
    '{move}: comment placed before the move was ignored',
  ),

  /// Comments on opponent moves (aggregated).
  opponentComments(
    'I-OPP-COMMENT',
    ReportLevel.info,
    '{n} comments on opponent moves are kept but not shown',
  ),

  /// Lines ending with an opponent move (aggregated).
  endsWithOpponent(
    'I-ENDS-OPP',
    ReportLevel.info,
    '{n} lines end with an opponent move',
  ),

  /// NAGs present (aggregated).
  nags('I-NAG', ReportLevel.info, r'NAGs (!, ?, $n) are ignored'),

  /// Several games merged.
  merged('I-MERGED', ReportLevel.info, '{n} games merged into one repertoire');

  new(this.id, this.level, this.template);

  /// The code as written in the spec, e.g. `W-NO-WHY`.
  final String id;

  /// Severity.
  final ReportLevel level;

  /// Message template with `{name}` placeholders.
  final String template;

  /// Fills [template] with [params].
  String format(Map<String, Object> params) => template.replaceAllMapped(
    RegExp(r'\{(\w+)\}'),
    (m) => params[m[1]]?.toString() ?? m[0]!,
  );
}

/// One finding of an import.
@immutable
final class ReportItem {
  /// Creates an item; [message] is [code]'s template filled with [params].
  new(
    this.code, {
    Map<String, Object> params = const {},
    this.nodePath = const [],
    this.gameIndex,
    this.details = const [],
  }) : message = code.format(params);

  /// The code.
  final ReportCode code;

  /// The rendered message.
  final String message;

  /// SAN moves from the start position to the move concerned (empty if not
  /// about one move).
  final List<String> nodePath;

  /// Zero-based index of the game concerned, if any.
  final int? gameIndex;

  /// Expandable details of an aggregated item (e.g. the lines for I-ENDS-OPP).
  final List<String> details;

  /// The item's level.
  ReportLevel get level => code.level;

  /// JSON form.
  Map<String, Object?> toJson() => {
    'code': code.id,
    'level': level.name,
    'message': message,
    'nodePath': nodePath,
    if (gameIndex != null) 'gameIndex': gameIndex,
    if (details.isNotEmpty) 'details': details,
  };

  @override
  String toString() => '${code.id} $message';
}

/// The result of validating/importing a PGN.
@immutable
final class ImportReport {
  /// Creates a report.
  new({
    required List<ReportItem> items,
    this.games = 0,
    this.lines = 0,
    this.userMoves = 0,
    this.opponentMoves = 0,
    this.commentedUserMoves = 0,
    this.maxDepth = 0,
  }) : items = List.unmodifiable(items);

  /// All findings in the order they were found.
  final List<ReportItem> items;

  /// Number of games in the file.
  final int games;

  /// Number of lines (leaves) in the merged tree.
  final int lines;

  /// Number of distinct user-move nodes.
  final int userMoves;

  /// Number of distinct opponent-move nodes.
  final int opponentMoves;

  /// User-move nodes with a non-empty Why.
  final int commentedUserMoves;

  /// Deepest ply.
  final int maxDepth;

  /// Items of level error.
  List<ReportItem> get errors => _of(ReportLevel.error);

  /// Items of level warning.
  List<ReportItem> get warnings => _of(ReportLevel.warning);

  /// Items of level info.
  List<ReportItem> get infos => _of(ReportLevel.info);

  /// True if the import is blocked.
  bool get hasErrors => items.any((i) => i.level == ReportLevel.error);

  List<ReportItem> _of(ReportLevel level) => [
    for (final i in items)
      if (i.level == level) i,
  ];

  /// Human-readable report, used by "Copy report" and the CLI.
  String toPlainText() {
    final b = StringBuffer()
      ..writeln(
        'Games: $games, lines: $lines, your moves: $userMoves '
        '($commentedUserMoves commented), opponent moves: $opponentMoves, '
        'max depth: $maxDepth plies',
      );
    for (final (title, list) in [
      ('Errors', errors),
      ('Warnings', warnings),
      ('Info', infos),
    ]) {
      b.writeln('$title (${list.length})');
      for (final i in list) {
        b.writeln('  ${i.code.id} ${i.message}');
        for (final d in i.details) {
          b.writeln('    $d');
        }
      }
    }
    return b.toString();
  }

  /// JSON form (CLI `--json`).
  Map<String, Object?> toJson() => {
    'counts': {
      'games': games,
      'lines': lines,
      'userMoves': userMoves,
      'opponentMoves': opponentMoves,
      'commentedUserMoves': commentedUserMoves,
      'maxDepth': maxDepth,
      'errors': errors.length,
      'warnings': warnings.length,
      'infos': infos.length,
    },
    'items': [for (final i in items) i.toJson()],
  };

  /// [toJson] encoded with indentation.
  String toJsonString() => const JsonEncoder.withIndent('  ').convert(toJson());
}
