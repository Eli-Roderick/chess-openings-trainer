import 'package:chess_core/chess_core.dart';
import 'package:chessground/chessground.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/core/settings/app_settings.dart';

/// Every board colour scheme chessground ships, by settings name
/// (01-product-spec §10). Unknown names fall back to brown.
const boardColorSchemes = <String, ChessboardColorScheme>{
  'brown': ChessboardColorScheme.brown,
  'blue': ChessboardColorScheme.blue,
  'green': ChessboardColorScheme.green,
  'grey': ChessboardColorScheme.grey,
  'purple': ChessboardColorScheme.purple,
  'wood': ChessboardColorScheme.wood,
  'ic': ChessboardColorScheme.ic,
  'blue2': ChessboardColorScheme.blue2,
  'blue3': ChessboardColorScheme.blue3,
  'blueMarble': ChessboardColorScheme.blueMarble,
  'canvas': ChessboardColorScheme.canvas,
  'greenPlastic': ChessboardColorScheme.greenPlastic,
  'horsey': ChessboardColorScheme.horsey,
  'leather': ChessboardColorScheme.leather,
  'maple': ChessboardColorScheme.maple,
  'maple2': ChessboardColorScheme.maple2,
  'marble': ChessboardColorScheme.marble,
  'metal': ChessboardColorScheme.metal,
  'newspaper': ChessboardColorScheme.newspaper,
  'olive': ChessboardColorScheme.olive,
  'pinkPyramid': ChessboardColorScheme.pinkPyramid,
  'purpleDiag': ChessboardColorScheme.purpleDiag,
  'wood2': ChessboardColorScheme.wood2,
  'wood3': ChessboardColorScheme.wood3,
  'wood4': ChessboardColorScheme.wood4,
};

/// The colour scheme named [name].
ChessboardColorScheme boardColorScheme(String name) =>
    boardColorSchemes[name] ?? ChessboardColorScheme.brown;

/// The piece set named [name] (a [PieceSet] enum name); cburnett if unknown.
PieceSet pieceSetNamed(String name) => PieceSet.values.firstWhere(
  (p) => p.name == name,
  orElse: () => PieceSet.cburnett,
);

/// Board settings derived from the app settings. Premoves and user-drawn
/// shapes are off; drag and tap-tap are both on (01 §7.5).
ChessboardSettings chessboardSettings(AppSettings s) => ChessboardSettings(
  colorScheme: boardColorScheme(s.boardTheme),
  pieceAssets: pieceSetNamed(s.pieceSet).assets,
  enableCoordinates: s.showCoordinates,
  animationDuration: Duration(milliseconds: s.animationSpeed.ms),
  showLastMove: s.highlightLastMove,
  showValidMoves: s.showLegalMoves,
  enablePremoves: false,
  enablePremoveCastling: false,
);

/// lichess shape colours (with their usual transparency).
Color shapeColor(ShapeColor c) => switch (c) {
  ShapeColor.green => const Color(0xAA15781B),
  ShapeColor.red => const Color(0xAA882020),
  ShapeColor.yellow => const Color(0xAAE68F00),
  ShapeColor.blue => const Color(0xAA003088),
};

/// Chessground shapes for a comment's `%cal`/`%csl` shapes.
Set<Shape> boardShapes(Iterable<BoardShape> shapes) => {
  for (final s in shapes)
    switch (s) {
      ArrowShape() => Arrow(
        color: shapeColor(s.color),
        orig: s.from,
        dest: s.to,
      ),
      CircleShape() => Circle(color: shapeColor(s.color), orig: s.square),
    },
};

/// Decodes the 12 piece images of [set] into chessground's image cache
/// (`ChessgroundImages`, which the board paints from) so the board never
/// shows a frame without pieces. [replacing]: clear the previous set first.
Future<void> precachePieceSet(
  BuildContext context,
  PieceSet set, {
  bool replacing = false,
}) {
  if (replacing) ChessgroundImages.instance.clear();
  return ChessgroundImages.instance.loadAll(
    set.assets,
    devicePixelRatio: MediaQuery.maybeDevicePixelRatioOf(context),
  );
}

/// Precaches the active piece set after the first frame and whenever the
/// setting changes (P05 task 2). Wraps the app's content.
class PieceSetPrecacher extends ConsumerStatefulWidget {
  /// Wraps [child].
  const new({required this.child, super.key});

  /// The app content.
  final Widget child;

  @override
  ConsumerState<PieceSetPrecacher> createState() => _PieceSetPrecacherState();
}

class _PieceSetPrecacherState extends ConsumerState<PieceSetPrecacher> {
  String? _cached;

  @override
  Widget build(BuildContext context) {
    final name = ref.watch(settingsProvider.select((s) => s.value?.pieceSet));
    if (name != null && name != _cached) {
      final replacing = _cached != null;
      _cached = name;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        precachePieceSet(
          context,
          pieceSetNamed(name),
          replacing: replacing,
        ).ignore();
      });
    }
    return widget.child;
  }
}
