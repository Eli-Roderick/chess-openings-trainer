import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';

/// The position after [sanPath] from the initial position, with its last
/// move, or null if a move is illegal.
({String fen, Move? lastMove})? positionAfter(List<String> sanPath) {
  Position pos = Chess.initial;
  Move? last;
  for (final san in sanPath) {
    final move = pos.parseSan(san);
    if (move == null) return null;
    pos = pos.play(move);
    last = move;
  }
  return (fen: pos.fen, lastMove: last);
}

/// A small non-interactive board (import report previews; P05 adds the
/// user's board theme and piece set).
class PositionPreview extends StatelessWidget {
  /// Shows [fen] from [orientation]'s side.
  const new({
    required this.fen,
    required this.orientation,
    this.lastMove,
    this.size = 280,
    super.key,
  });

  /// Position.
  final String fen;

  /// Side at the bottom.
  final Side orientation;

  /// Highlighted last move.
  final Move? lastMove;

  /// Board size in logical pixels.
  final double size;

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: StaticChessboard(
      size: size,
      orientation: orientation,
      fen: fen,
      lastMove: lastMove,
      settings: const StaticChessboardSettings(enableCoordinates: true),
    ),
  );
}

/// Opens a dialog previewing the position after [sanPath].
Future<void> showPositionPreview(
  BuildContext context, {
  required List<String> sanPath,
  required String title,
  Side orientation = Side.white,
}) async {
  final position = positionAfter(sanPath);
  if (position == null) return;
  final size = (MediaQuery.sizeOf(context).shortestSide - 96).clamp(
    160.0,
    360.0,
  );
  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title, maxLines: 3, overflow: TextOverflow.ellipsis),
      content: PositionPreview(
        fen: position.fen,
        lastMove: position.lastMove,
        orientation: orientation,
        size: size,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).closeButtonLabel),
        ),
      ],
    ),
  );
}
