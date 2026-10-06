import 'package:chess_core/src/pgn/board_shape.dart';
import 'package:chess_core/src/pgn/move_comment.dart';
import 'package:chess_core/src/pgn/report.dart';
import 'package:dartchess/dartchess.dart';
import 'package:meta/meta.dart';

/// A finding of [parseComment], turned into a [ReportItem] by the importer
/// once the move path is known.
@immutable
final class CommentIssue {
  /// Creates an issue.
  const new(this.code, [this.params = const {}]);

  /// The report code.
  final ReportCode code;

  /// Template parameters other than `move` (e.g. `tag`, `n`, `entry`).
  final Map<String, Object> params;

  @override
  bool operator ==(Object other) =>
      other is CommentIssue &&
      other.code == code &&
      other.params.length == params.length &&
      params.entries.every((e) => other.params[e.key] == e.value);

  @override
  int get hashCode => Object.hash(code, Object.hashAllUnordered(params.keys));

  @override
  String toString() => 'CommentIssue(${code.id}, $params)';
}

/// Output of [parseComment].
@immutable
final class ParsedComment {
  /// Creates a result.
  const new(this.comment, this.issues);

  /// The parsed comment, or null when there is nothing in it.
  final MoveComment? comment;

  /// Warnings and infos found while parsing.
  final List<CommentIssue> issues;
}

/// The text tags, in canonical export order.
const textTags = ['why', 'plan', 'watch', 'alt'];

const _ignoredTags = {'eval', 'clk', 'emt'};

/// Over this many characters a text field gets W-LONG.
const maxFieldLength = 400;

final _ws = RegExp(r'\s+');
final _tagRe = RegExp(r'\[%([A-Za-z]+)\s+([^\[\]]*?)\s*\]');
final _markerRe = RegExp(r'\[%[A-Za-z]*');
final _arrowRe = RegExp(r'^([A-Za-z])([a-h][1-8])([a-h][1-8])$');
final _circleRe = RegExp(r'^([A-Za-z])([a-h][1-8])$');

/// Collapses whitespace runs to one space and trims.
String collapseWhitespace(String s) => s.replaceAll(_ws, ' ').trim();

/// Parses a raw move comment per docs/plan/07-comment-format.md §4.
///
/// [raw] is all comments after the move joined with a space, or null when the
/// move has no comment. Per-move warnings (everything except I-PLAIN and the
/// W-NO-* codes) are reported for every move; the importer drops them for
/// opponent moves. W-NO-WHY / W-NO-COMMENT are only produced when
/// [isUserMove] is true.
///
/// Clarification of §4 step 4 (docs/DECISIONS.md D-37): a comment is
/// malformed when text left over after removing every well-formed tag still
/// contains `[%`, not merely when no *text* tag matched, so a comment holding
/// only `[%cal ...]` or `[%clk ...]` is not malformed.
ParsedComment parseComment(String? raw, {required bool isUserMove}) {
  final issues = <CommentIssue>[];
  final input = raw == null ? '' : collapseWhitespace(raw);
  if (input.isEmpty) {
    if (isUserMove) {
      issues.add(
        CommentIssue(raw == null ? ReportCode.noComment : ReportCode.noWhy),
      );
    }
    return ParsedComment(null, issues);
  }

  final fields = <String, String>{};
  // Arrows first, then squares, so the order is canonical for round trips.
  final arrows = <BoardShape>[];
  final circles = <BoardShape>[];
  final leftover = input.replaceAllMapped(_tagRe, (m) {
    final name = m[1]!.toLowerCase();
    final text = m[2]!.trim();
    if (textTags.contains(name)) {
      final existing = fields[name];
      if (existing == null) {
        fields[name] = text;
      } else {
        issues.add(CommentIssue(ReportCode.duplicateTag, {'tag': name}));
        fields[name] = '$existing $text'.trim();
      }
    } else if (name == 'cal' || name == 'csl') {
      final isCal = name == 'cal';
      _parseShapes(
        text,
        arrows: isCal,
        into: isCal ? arrows : circles,
        issues: issues,
      );
    } else if (!_ignoredTags.contains(name)) {
      issues.add(CommentIssue(ReportCode.unknownTag, {'tag': name}));
    }
    return ' ';
  });
  final rest = collapseWhitespace(leftover);

  var why = fields['why'] ?? '';
  final hasTextTag = fields.isNotEmpty;
  if (rest.contains('[%')) {
    issues.add(const CommentIssue(ReportCode.malformed));
    final text = collapseWhitespace(
      rest.replaceAll(_markerRe, ' ').replaceAll(RegExp(r'[\[\]]'), ' '),
    );
    why = '$why $text'.trim();
  } else if (!hasTextTag) {
    if (rest.isNotEmpty) {
      issues.add(const CommentIssue(ReportCode.plain));
      why = _bracketsToParens(rest);
    }
  } else if (rest.isNotEmpty) {
    issues.add(const CommentIssue(ReportCode.looseText));
    why = '$why ${_bracketsToParens(rest)}'.trim();
  }
  fields['why'] = why;

  for (final tag in textTags) {
    final n = fields[tag]?.length ?? 0;
    if (n > maxFieldLength) {
      issues.add(CommentIssue(ReportCode.long, {'tag': tag, 'n': n}));
    }
  }

  final comment = MoveComment(
    why: fields['why'],
    plan: fields['plan'],
    watch: fields['watch'],
    alt: fields['alt'],
    shapes: [...arrows, ...circles],
  );
  if (isUserMove && comment.why == null) {
    issues.add(const CommentIssue(ReportCode.noWhy));
  }
  return ParsedComment(comment.isEmpty ? null : comment, issues);
}

void _parseShapes(
  String text, {
  required bool arrows,
  required List<BoardShape> into,
  required List<CommentIssue> issues,
}) {
  for (final entry in text.split(',')) {
    final e = entry.trim();
    if (e.isEmpty) continue;
    final shape = arrows ? _arrow(e) : _circle(e);
    if (shape == null) {
      issues.add(CommentIssue(ReportCode.badShape, {'entry': e}));
    } else {
      into.add(shape);
    }
  }
}

BoardShape? _arrow(String e) {
  final m = _arrowRe.firstMatch(e);
  if (m == null) return null;
  final color = ShapeColor.fromCode(m[1]!);
  final from = Square.parse(m[2]!);
  final to = Square.parse(m[3]!);
  if (color == null || from == null || to == null || from == to) return null;
  return ArrowShape(color, from, to);
}

BoardShape? _circle(String e) {
  final m = _circleRe.firstMatch(e);
  if (m == null) return null;
  final color = ShapeColor.fromCode(m[1]!);
  final sq = Square.parse(m[2]!);
  if (color == null || sq == null) return null;
  return CircleShape(color, sq);
}

/// Serializes [comment] in canonical tag order `why plan watch alt cal csl`.
/// Characters that would break the PGN (`[ ] { }`) are replaced by
/// parentheses.
String formatComment(MoveComment comment) {
  String clean(String s) => _bracketsToParens(s);
  final parts = <String>[
    if (comment.why != null) '[%why ${clean(comment.why!)}]',
    if (comment.plan != null) '[%plan ${clean(comment.plan!)}]',
    if (comment.watch != null) '[%watch ${clean(comment.watch!)}]',
    if (comment.alt != null) '[%alt ${clean(comment.alt!)}]',
  ];
  final arrows = comment.shapes.whereType<ArrowShape>().map((s) => s.pgn);
  final circles = comment.shapes.whereType<CircleShape>().map((s) => s.pgn);
  if (arrows.isNotEmpty) parts.add('[%cal ${arrows.join(',')}]');
  if (circles.isNotEmpty) parts.add('[%csl ${circles.join(',')}]');
  return parts.join(' ');
}

String _bracketsToParens(String s) =>
    s.replaceAll(RegExp(r'[\[{]'), '(').replaceAll(RegExp(r'[\]}]'), ')');
