import 'package:chess_core/src/pgn/board_shape.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

/// The parsed structured comment of a move
/// (docs/plan/07-comment-format.md §3). Empty strings are normalized to null.
@immutable
final class MoveComment {
  /// Creates a comment; blank text fields become null.
  new({
    String? why,
    String? plan,
    String? watch,
    String? alt,
    List<BoardShape> shapes = const [],
  }) : why = _blankToNull(why),
       plan = _blankToNull(plan),
       watch = _blankToNull(watch),
       alt = _blankToNull(alt),
       shapes = List.unmodifiable(shapes);

  /// Why this move is played here ("Why").
  final String? why;

  /// What the move prepares ("Plan").
  final String? plan;

  /// The opponent's threat or trick to look out for ("Watch out").
  final String? watch;

  /// Other moves and why this one is preferred ("Alternatives").
  final String? alt;

  /// Arrows and highlighted squares.
  final List<BoardShape> shapes;

  /// True when no field carries anything.
  bool get isEmpty =>
      why == null &&
      plan == null &&
      watch == null &&
      alt == null &&
      shapes.isEmpty;

  static String? _blankToNull(String? s) =>
      (s == null || s.trim().isEmpty) ? null : s;

  static const _shapesEq = ListEquality<BoardShape>();

  @override
  bool operator ==(Object other) =>
      other is MoveComment &&
      other.why == why &&
      other.plan == plan &&
      other.watch == watch &&
      other.alt == alt &&
      _shapesEq.equals(other.shapes, shapes);

  @override
  int get hashCode =>
      Object.hash(why, plan, watch, alt, _shapesEq.hash(shapes));

  @override
  String toString() =>
      'MoveComment(why: $why, plan: $plan, watch: $watch, alt: $alt, '
      'shapes: $shapes)';
}
