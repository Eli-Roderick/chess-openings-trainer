import 'package:dartchess/dartchess.dart';
import 'package:meta/meta.dart';

/// Colour of an arrow or highlighted square (`%cal` / `%csl`).
enum ShapeColor {
  /// `G`
  green('G'),

  /// `R`
  red('R'),

  /// `Y`
  yellow('Y'),

  /// `B`
  blue('B');

  new(this.code);

  /// The one-letter PGN code.
  final String code;

  /// Parses a one-letter code, case-insensitively. Returns null if unknown.
  static ShapeColor? fromCode(String code) {
    final upper = code.toUpperCase();
    for (final c in values) {
      if (c.code == upper) return c;
    }
    return null;
  }
}

/// An arrow or highlighted square drawn on the board for a move comment.
@immutable
sealed class BoardShape {
  const new(this.color);

  /// Parses the JSON form stored in the `nodes.shapes` column.
  factory fromJson(Map<String, Object?> json) {
    final color = ShapeColor.fromCode(json['c']! as String)!;
    return switch (json['t']) {
      'arrow' => ArrowShape(
        color,
        Square.parse(json['from']! as String)!,
        Square.parse(json['to']! as String)!,
      ),
      'circle' => CircleShape(color, Square.parse(json['sq']! as String)!),
      final t => throw FormatException('Unknown shape type $t'),
    };
  }

  /// The shape's colour.
  final ShapeColor color;

  /// JSON form: `{"t":"arrow","from":"e2","to":"e4","c":"G"}` or
  /// `{"t":"circle","sq":"d5","c":"R"}`.
  Map<String, Object?> toJson();

  /// PGN entry, e.g. `Gc4f7` or `Rd5`.
  String get pgn;
}

/// An arrow from one square to another (`%cal`).
final class ArrowShape extends BoardShape {
  /// Creates an arrow.
  const new(super.color, this.from, this.to);

  /// Start square.
  final Square from;

  /// End square.
  final Square to;

  @override
  Map<String, Object?> toJson() => {
    't': 'arrow',
    'from': from.name,
    'to': to.name,
    'c': color.code,
  };

  @override
  String get pgn => '${color.code}${from.name}${to.name}';

  @override
  bool operator ==(Object other) =>
      other is ArrowShape &&
      other.color == color &&
      other.from == from &&
      other.to == to;

  @override
  int get hashCode => Object.hash('arrow', color, from, to);

  @override
  String toString() => 'ArrowShape($pgn)';
}

/// A highlighted square (`%csl`).
final class CircleShape extends BoardShape {
  /// Creates a highlighted square.
  const new(super.color, this.square);

  /// The highlighted square.
  final Square square;

  @override
  Map<String, Object?> toJson() => {
    't': 'circle',
    'sq': square.name,
    'c': color.code,
  };

  @override
  String get pgn => '${color.code}${square.name}';

  @override
  bool operator ==(Object other) =>
      other is CircleShape && other.color == color && other.square == square;

  @override
  int get hashCode => Object.hash('circle', color, square);

  @override
  String toString() => 'CircleShape($pgn)';
}
