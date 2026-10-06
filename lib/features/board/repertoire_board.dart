import 'dart:async';

import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/core/settings/app_settings.dart';
import 'package:repertoire_trainer/features/board/board_appearance.dart';
import 'package:repertoire_trainer/features/board/board_position.dart';

/// Everything the board shows. Immutable with value equality, so the board
/// only updates when one of these changes.
@immutable
final class BoardViewState {
  /// Creates a view state.
  const new({
    required this.fen,
    required this.orientation,
    this.movable = PlayerSide.none,
    this.lastMove,
    this.shapes = const {},
    this.highlights = const {},
    this.animate = true,
  });

  /// The position.
  final String fen;

  /// Which side is at the bottom.
  final Side orientation;

  /// Which side the user may move ([PlayerSide.none]: not interactive).
  final PlayerSide movable;

  /// Highlighted last move.
  final Move? lastMove;

  /// Arrows and circles (comment shapes, hints).
  final Set<Shape> shapes;

  /// Coloured square overlays (hint square).
  final Map<Square, Color> highlights;

  /// Whether a position change is animated.
  final bool animate;

  /// A copy with the given fields replaced.
  BoardViewState copyWith({
    String? fen,
    Side? orientation,
    PlayerSide? movable,
    Move? lastMove,
    bool clearLastMove = false,
    Set<Shape>? shapes,
    Map<Square, Color>? highlights,
    bool? animate,
  }) => BoardViewState(
    fen: fen ?? this.fen,
    orientation: orientation ?? this.orientation,
    movable: movable ?? this.movable,
    lastMove: clearLastMove ? null : lastMove ?? this.lastMove,
    shapes: shapes ?? this.shapes,
    highlights: highlights ?? this.highlights,
    animate: animate ?? this.animate,
  );

  @override
  bool operator ==(Object other) =>
      other is BoardViewState &&
      other.fen == fen &&
      other.orientation == orientation &&
      other.movable == movable &&
      other.lastMove == lastMove &&
      other.animate == animate &&
      setEquals(other.shapes, shapes) &&
      mapEquals(other.highlights, highlights);

  @override
  int get hashCode => Object.hash(
    fen,
    orientation,
    movable,
    lastMove,
    animate,
    Object.hashAllUnordered(shapes),
    Object.hashAllUnordered(highlights.entries.map((e) => (e.key, e.value))),
  );
}

/// Chessground settings for the current app settings. Only changes when a
/// board setting changes.
final boardSettingsProvider = Provider<ChessboardSettings>(
  (ref) => chessboardSettings(
    ref.watch(settingsProvider).value ?? const AppSettings(),
  ),
);

/// Error-flash colour (01 §7.7).
const errorFlashColor = Color(0x99E53935);

/// How long the error flash lasts.
const errorFlashDuration = Duration(milliseconds: 300);

/// Soft blue hint square (01 §7.8).
const hintSquareColor = Color(0x664FA3E0);

/// Handle on the board currently on screen, for screens and tests.
final class RepertoireBoardController {
  _RepertoireBoardState? _state;

  /// Whether a board is attached.
  bool get isAttached => _state != null;

  /// The position on the board.
  String? get fen => _state?.widget.state.fen;

  /// Plays [uci] as if the user had moved the piece: same handler as a real
  /// drag or tap-tap (used by widget and integration tests). Returns false
  /// if no board is attached, the board is not interactive or the move is
  /// illegal.
  bool debugPlayUserMove(String uci) {
    final state = _state;
    final move = parseUci(uci);
    if (state == null || move == null) return false;
    return state._userMove(move);
  }

  /// Flashes [square] red for 300 ms; completes when the flash is over.
  Future<void> flashError(Square square) =>
      _state?._flash(square) ?? Future<void>.value();
}

/// The controller of the board on screen (null when none). Each
/// [RepertoireBoard] registers itself while mounted.
final activeBoardProvider =
    NotifierProvider<ActiveBoard, RepertoireBoardController?>(ActiveBoard.new);

/// Holds the [RepertoireBoardController] of the mounted board.
final class ActiveBoard extends Notifier<RepertoireBoardController?> {
  @override
  RepertoireBoardController? build() => null;

  /// Sets the active board controller.
  // A setter would hide the provider's own state field.
  // ignore: use_setters_to_change_properties
  void attach(RepertoireBoardController controller) => state = controller;

  /// Clears it if [controller] is the active one.
  void detach(RepertoireBoardController controller) {
    if (identical(state, controller)) state = null;
  }
}

/// The board every screen uses: a chessground [Chessboard] sized to a square
/// that fits its constraints, driven by an immutable [BoardViewState].
class RepertoireBoard extends ConsumerStatefulWidget {
  /// Creates the board.
  const new({
    required this.state,
    super.key,
    this.onUserMove,
    this.controller,
    this.settingsOverride,
  });

  /// What to show.
  final BoardViewState state;

  /// Called with each legal user move, resolved against the position.
  final void Function(NormalMove move, ResolvedMove resolved)? onUserMove;

  /// Optional handle (flash, test moves).
  final RepertoireBoardController? controller;

  /// Settings to use instead of the app's (Settings preview).
  final ChessboardSettings? settingsOverride;

  /// Test hook: called on every build of the board widget.
  @visibleForTesting
  static void Function()? debugOnBuild;

  @override
  ConsumerState<RepertoireBoard> createState() => _RepertoireBoardState();
}

class _RepertoireBoardState extends ConsumerState<RepertoireBoard> {
  late final RepertoireBoardController _handle =
      widget.controller ?? RepertoireBoardController();
  late final ChessboardController _board = ChessboardController(
    game: _gameData(widget.state),
  );
  late final ActiveBoard _active = ref.read(activeBoardProvider.notifier);
  Square? _flashSquare;
  Timer? _flashTimer;
  Completer<void>? _flashDone;

  @override
  void initState() {
    super.initState();
    _handle._state = this;
    // Registering changes provider state, which is not allowed during build.
    scheduleMicrotask(() {
      if (mounted) _active.attach(_handle);
    });
  }

  @override
  void didUpdateWidget(RepertoireBoard old) {
    super.didUpdateWidget(old);
    final s = widget.state;
    final o = old.state;
    if (s.fen != o.fen || s.movable != o.movable || s.lastMove != o.lastMove) {
      _board.updatePosition(
        _gameData(s),
        animate: s.animate && s.fen != o.fen,
        resetPremove: true,
      );
    }
  }

  @override
  void dispose() {
    _flashTimer?.cancel();
    _flashDone?.complete();
    if (identical(_handle._state, this)) _handle._state = null;
    _active.detach(_handle);
    _board.dispose();
    super.dispose();
  }

  static GameData _gameData(BoardViewState s) {
    final position = positionFromFen(s.fen);
    return GameData(
      fen: s.fen,
      playerSide: s.movable,
      sideToMove: position.turn,
      validMoves: s.movable == PlayerSide.none
          ? const {}
          : makeLegalMoves(position),
      lastMove: s.lastMove,
      kingSquareInCheck: position.isCheck
          ? position.board.kingOf(position.turn)
          : null,
    );
  }

  bool _userMove(Move move) {
    final s = widget.state;
    if (move is! NormalMove || s.movable == PlayerSide.none) return false;
    final position = positionFromFen(s.fen);
    final mover = position.turn;
    if (s.movable != PlayerSide.both && s.movable.name != mover.name) {
      return false;
    }
    final resolved = resolveMove(position, move);
    if (resolved == null) return false;
    widget.onUserMove?.call(move, resolved);
    return true;
  }

  Future<void> _flash(Square square) {
    _flashTimer?.cancel();
    _flashDone?.complete();
    final done = _flashDone = Completer<void>();
    setState(() => _flashSquare = square);
    _flashTimer = Timer(errorFlashDuration, () {
      if (mounted) setState(() => _flashSquare = null);
      if (identical(_flashDone, done)) _flashDone = null;
      done.complete();
    });
    return done.future;
  }

  @override
  Widget build(BuildContext context) {
    RepertoireBoard.debugOnBuild?.call();
    // Typed watch: inside `??` inference would make the result nullable.
    final settings =
        widget.settingsOverride ??
        ref.watch<ChessboardSettings>(boardSettingsProvider);
    final s = widget.state;
    final overlays = {...s.highlights, ?_flashSquare: errorFlashColor};
    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest.shortestSide.isFinite
              ? constraints.biggest.shortestSide
              : constraints.maxWidth;
          final square = size / 8;
          return SizedBox.square(
            dimension: size,
            child: Stack(
              children: [
                Chessboard(
                  size: size,
                  controller: _board,
                  settings: settings,
                  orientation: s.orientation,
                  shapes: s.shapes,
                  onMove: (move, {viaDragAndDrop}) => _userMove(move),
                ),
                for (final MapEntry(key: sq, value: color) in overlays.entries)
                  Positioned(
                    left: _col(sq, s.orientation) * square,
                    top: _row(sq, s.orientation) * square,
                    width: square,
                    height: square,
                    child: IgnorePointer(
                      child: ColoredBox(
                        key: ValueKey('overlay-${sq.name}'),
                        color: color,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  static int _col(Square sq, Side orientation) =>
      orientation == Side.white ? sq.file : 7 - sq.file;

  static int _row(Square sq, Side orientation) =>
      orientation == Side.white ? 7 - sq.rank : sq.rank;
}
