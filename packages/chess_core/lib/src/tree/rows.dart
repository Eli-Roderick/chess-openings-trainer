import 'dart:convert';

import 'package:chess_core/src/pgn/board_shape.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

/// One row of the `nodes` table (docs/plan/03-data-model.md §2.2), without
/// the repertoire id.
@immutable
final class NodeRow {
  /// Creates a row.
  new({
    required this.nodeId,
    required this.parentId,
    required this.ply,
    required this.san,
    required this.uci,
    required this.fen,
    required this.isUserMove,
    required this.childIndex,
    this.why,
    this.plan,
    this.watch,
    this.alt,
    List<BoardShape> shapes = const [],
    this.rawComment,
    List<int> nags = const [],
  }) : shapes = List.unmodifiable(shapes),
       nags = List.unmodifiable(nags);

  /// Preorder index, root 0.
  final int nodeId;

  /// Parent's id; null for the root.
  final int? parentId;

  /// Ply (root 0).
  final int ply;

  /// SAN (null for the root).
  final String? san;

  /// UCI (null for the root).
  final String? uci;

  /// FEN after the move.
  final String fen;

  /// Move by the repertoire's side.
  final bool isUserMove;

  /// Order among siblings.
  final int childIndex;

  /// Comment field.
  final String? why;

  /// Comment field.
  final String? plan;

  /// Comment field.
  final String? watch;

  /// Comment field.
  final String? alt;

  /// Arrows and highlighted squares.
  final List<BoardShape> shapes;

  /// Original comment text.
  final String? rawComment;

  /// NAGs.
  final List<int> nags;

  /// The `shapes` column: JSON list, or null when there are none.
  String? get shapesJson =>
      shapes.isEmpty ? null : jsonEncode([for (final s in shapes) s.toJson()]);

  /// The `nags` column: comma-separated, or null when there are none.
  String? get nagsText => nags.isEmpty ? null : nags.join(',');

  /// Parses the `shapes` column.
  static List<BoardShape> shapesFromJson(String? json) => json == null
      ? const []
      : [
          for (final e in jsonDecode(json) as List<Object?>)
            BoardShape.fromJson(e! as Map<String, Object?>),
        ];

  /// Parses the `nags` column.
  static List<int> nagsFromText(String? text) => text == null || text.isEmpty
      ? const []
      : [for (final n in text.split(',')) int.parse(n)];

  static const _shapesEq = ListEquality<BoardShape>();
  static const _nagsEq = ListEquality<int>();

  @override
  bool operator ==(Object other) =>
      other is NodeRow &&
      other.nodeId == nodeId &&
      other.parentId == parentId &&
      other.ply == ply &&
      other.san == san &&
      other.uci == uci &&
      other.fen == fen &&
      other.isUserMove == isUserMove &&
      other.childIndex == childIndex &&
      other.why == why &&
      other.plan == plan &&
      other.watch == watch &&
      other.alt == alt &&
      _shapesEq.equals(other.shapes, shapes) &&
      other.rawComment == rawComment &&
      _nagsEq.equals(other.nags, nags);

  @override
  int get hashCode => Object.hash(
    nodeId,
    parentId,
    ply,
    san,
    uci,
    fen,
    isUserMove,
    childIndex,
    why,
    plan,
    watch,
    alt,
    _shapesEq.hash(shapes),
    rawComment,
    _nagsEq.hash(nags),
  );

  @override
  String toString() => 'NodeRow($nodeId, parent $parentId, $san)';
}

/// One row of the `lines` table (docs/plan/03-data-model.md §2.3), without
/// the repertoire id.
@immutable
final class LineRow {
  /// Creates a row.
  const new({
    required this.lineKey,
    required this.leafNodeId,
    required this.ordinal,
    required this.plies,
    required this.userMoveCount,
    required this.branchPly,
    required this.label,
    required this.ucis,
  });

  /// Line key.
  final String lineKey;

  /// Id of the last node.
  final int leafNodeId;

  /// Preorder position of the leaf.
  final int ordinal;

  /// Length in plies.
  final int plies;

  /// Moves by the repertoire's side.
  final int userMoveCount;

  /// Branch-point start ply.
  final int branchPly;

  /// Display label.
  final String label;

  /// Space-separated UCI sequence.
  final String ucis;

  @override
  bool operator ==(Object other) =>
      other is LineRow &&
      other.lineKey == lineKey &&
      other.leafNodeId == leafNodeId &&
      other.ordinal == ordinal &&
      other.plies == plies &&
      other.userMoveCount == userMoveCount &&
      other.branchPly == branchPly &&
      other.label == label &&
      other.ucis == ucis;

  @override
  int get hashCode => Object.hash(
    lineKey,
    leafNodeId,
    ordinal,
    plies,
    userMoveCount,
    branchPly,
    label,
    ucis,
  );

  @override
  String toString() => 'LineRow($lineKey, $label)';
}

/// The flat form of a tree, as stored in the database.
@immutable
final class RepertoireRows {
  /// Creates rows.
  new({required List<NodeRow> nodes, required List<LineRow> lines})
    : nodes = List.unmodifiable(nodes),
      lines = List.unmodifiable(lines);

  /// Node rows in preorder (index == nodeId).
  final List<NodeRow> nodes;

  /// Line rows in ordinal order.
  final List<LineRow> lines;
}
