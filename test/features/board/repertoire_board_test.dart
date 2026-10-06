import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:repertoire_trainer/core/db/app_database.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/features/board/board_position.dart';
import 'package:repertoire_trainer/features/board/repertoire_board.dart';

const _size = 400.0;
const double _sq = _size / 8;

/// Centre of [square] on a white-oriented board at the origin.
Offset centre(Square square) =>
    Offset((square.file + 0.5) * _sq, (7 - square.rank + 0.5) * _sq);

typedef Played = List<(NormalMove, ResolvedMove)>;

/// A host whose board state the test can change.
final class Host {
  late StateSetter setState;
  late BoardViewState state;
}

Future<(Played, Host, ProviderContainer)> pumpBoard(
  WidgetTester tester,
  BoardViewState initial, {
  List<Override> overrides = const [],
  bool fixedSettings = true,
}) async {
  final played = Played.empty(growable: true);
  final host = Host()..state = initial;
  final container = ProviderContainer(
    overrides: [
      if (fixedSettings)
        boardSettingsProvider.overrideWithValue(
          const ChessboardSettings(
            animationDuration: Duration.zero,
            enablePremoves: false,
          ),
        ),
      ...overrides,
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: Align(
          alignment: Alignment.topLeft,
          child: SizedBox.square(
            dimension: _size,
            child: StatefulBuilder(
              builder: (context, setState) {
                host.setState = setState;
                return RepertoireBoard(
                  state: host.state,
                  onUserMove: (m, r) => played.add((m, r)),
                );
              },
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  return (played, host, container);
}

const _start = BoardViewState(
  fen: kInitialFEN,
  orientation: Side.white,
  movable: PlayerSide.both,
);

void main() {
  tearDown(() => RepertoireBoard.debugOnBuild = null);

  testWidgets('renders the position', (tester) async {
    final (_, _, container) = await pumpBoard(tester, _start);
    // chessground paints resting pieces; check the position it holds.
    expect(container.read(activeBoardProvider)!.fen, kInitialFEN);
    expect(tester.getSize(find.byType(Chessboard)), const Size.square(_size));
  });

  testWidgets('emits a move on drag', (tester) async {
    final (played, _, _) = await pumpBoard(tester, _start);
    final gesture = await tester.startGesture(centre(Square.e2));
    await gesture.moveBy(const Offset(0, -10));
    await gesture.moveTo(centre(Square.e4));
    await gesture.up();
    await tester.pump();
    expect(played, hasLength(1));
    expect(played.single.$2.uci, 'e2e4');
    expect(played.single.$2.san, 'e4');
  });

  testWidgets('emits a move on tap-tap', (tester) async {
    final (played, _, _) = await pumpBoard(tester, _start);
    await tester.tapAt(centre(Square.g1));
    await tester.pump();
    await tester.tapAt(centre(Square.f3));
    await tester.pump();
    expect([for (final p in played) p.$2.uci], ['g1f3']);
  });

  testWidgets('castling by king-to-rook is reported as king two squares', (
    tester,
  ) async {
    const fen = 'r3k2r/8/8/8/8/8/8/R3K2R w KQkq - 0 1';
    final (played, _, _) = await pumpBoard(
      tester,
      const BoardViewState(
        fen: fen,
        orientation: Side.white,
        movable: PlayerSide.white,
      ),
    );
    await tester.tapAt(centre(Square.e1));
    await tester.pump();
    await tester.tapAt(centre(Square.h1));
    await tester.pump();
    expect([for (final p in played) (p.$2.uci, p.$2.san)], [('e1g1', 'O-O')]);
  });

  testWidgets('refuses moves when not interactive', (tester) async {
    final (played, host, container) = await pumpBoard(
      tester,
      _start.copyWith(movable: PlayerSide.none),
    );
    await tester.tapAt(centre(Square.e2));
    await tester.pump();
    await tester.tapAt(centre(Square.e4));
    await tester.pump();
    final board = container.read(activeBoardProvider)!;
    expect(board.debugPlayUserMove('e2e4'), isFalse);
    expect(played, isEmpty);
    // Only the side allowed to move.
    host.setState(
      () => host.state = _start.copyWith(movable: PlayerSide.black),
    );
    await tester.pump();
    expect(board.debugPlayUserMove('e2e4'), isFalse);
    expect(played, isEmpty);
  });

  testWidgets('promotion selector', (tester) async {
    const fen = '8/4P3/8/8/8/8/k7/4K3 w - - 0 1';
    final (played, _, _) = await pumpBoard(
      tester,
      const BoardViewState(
        fen: fen,
        orientation: Side.white,
        movable: PlayerSide.white,
      ),
    );
    await tester.tapAt(centre(Square.e7));
    await tester.pump();
    await tester.tapAt(centre(Square.e8));
    await tester.pump();
    expect(played, isEmpty);
    // chessground does not export the selector type.
    expect(
      find.byWidgetPredicate(
        (w) => w.runtimeType.toString() == 'PromotionSelector',
      ),
      findsOneWidget,
    );
    // Queen, knight, rook, bishop from e8 downwards: pick the knight.
    await tester.tapAt(centre(Square.e7));
    await tester.pump();
    expect([for (final p in played) (p.$2.uci, p.$2.san)], [('e7e8n', 'e8=N')]);
  });

  testWidgets('test hook plays through the same handler', (tester) async {
    final (played, _, container) = await pumpBoard(tester, _start);
    final board = container.read(activeBoardProvider)!;
    expect(board.fen, kInitialFEN);
    expect(board.debugPlayUserMove('e2e5'), isFalse);
    expect(board.debugPlayUserMove('e2e4'), isTrue);
    expect(played.single.$2.uci, 'e2e4');
  });

  testWidgets('error flash lasts 300 ms', (tester) async {
    final (_, _, container) = await pumpBoard(tester, _start);
    final board = container.read(activeBoardProvider)!;
    var done = false;
    board.flashError(Square.e4).then((_) => done = true).ignore();
    await tester.pump();
    expect(find.byKey(const ValueKey('overlay-e4')), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 299));
    expect(done, isFalse);
    await tester.pump(const Duration(milliseconds: 2));
    expect(done, isTrue);
    expect(find.byKey(const ValueKey('overlay-e4')), findsNothing);
  });

  testWidgets('position updates and black orientation', (tester) async {
    final (_, host, _) = await pumpBoard(
      tester,
      _start.copyWith(orientation: Side.black),
    );
    host.setState(
      () => host.state = host.state.copyWith(
        fen: 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
        lastMove: const NormalMove(from: Square.e2, to: Square.e4),
        highlights: {Square.e4: hintSquareColor},
      ),
    );
    await tester.pump();
    // Black at the bottom: e4 is at file index 3 from the left, row 4.
    final overlay = tester.getTopLeft(find.byKey(const ValueKey('overlay-e4')));
    expect(overlay, const Offset(3 * _sq, 3 * _sq));
  });

  testWidgets('unrelated provider changes do not rebuild the board', (
    tester,
  ) async {
    final db = AppDatabase.memory();
    addTearDown(() => tester.runAsync(db.close));
    final (_, _, container) = await pumpBoard(
      tester,
      _start,
      overrides: [databaseProvider.overrideWithValue(db)],
      fixedSettings: false,
    );
    // Real settings-derived board settings.
    var builds = 0;
    RepertoireBoard.debugOnBuild = () => builds++;
    final settings = container.read(settingsRepositoryProvider);
    await tester.runAsync(
      () => settings.update((s) => s.copyWith(srsNewPerDay: 33)),
    );
    await tester.pump();
    await tester.runAsync(
      () => settings.update((s) => s.copyWith(opponentMoveDelayMs: 500)),
    );
    await tester.pump();
    expect(builds, 0);
  });

  test('BoardViewState equality', () {
    final a = _start.copyWith(highlights: {Square.a1: hintSquareColor});
    final b = _start.copyWith(highlights: {Square.a1: hintSquareColor});
    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(a == _start, isFalse);
    expect(_start.copyWith(clearLastMove: true), _start);
  });

  testWidgets('taking a move back animates the piece home', (tester) async {
    final (_, host, container) = await pumpBoard(
      tester,
      _start,
      fixedSettings: false,
      overrides: [
        boardSettingsProvider.overrideWithValue(
          const ChessboardSettings(
            animationDuration: Duration(milliseconds: 200),
            enablePremoves: false,
          ),
        ),
      ],
    );
    const afterE4 =
        'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1';
    host.setState(
      () => host.state = _start.copyWith(fen: afterE4, animate: false),
    );
    await tester.pump();
    // Back to the start position, animated (the take-back of P05 task 1).
    host.setState(() => host.state = _start);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final board = tester.state(find.byType(Chessboard));
    expect(board.mounted, isTrue);
    expect(tester.hasRunningAnimations, isTrue);
    await tester.pump(const Duration(milliseconds: 150));
    expect(tester.hasRunningAnimations, isFalse);
    expect(container.read(activeBoardProvider)!.fen, kInitialFEN);
  });

  testWidgets('a new animation speed applies to the board on screen', (
    tester,
  ) async {
    final (_, host, container) = await pumpBoard(
      tester,
      _start,
      fixedSettings: false,
      overrides: [
        boardSettingsProvider.overrideWith(
          (ref) => ChessboardSettings(
            animationDuration: ref.watch(_durationProvider),
          ),
        ),
      ],
    );
    const afterE4 =
        'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1';
    host.setState(() => host.state = _start.copyWith(fen: afterE4));
    await tester.pump();
    expect(tester.hasRunningAnimations, isTrue);
    await tester.pumpAndSettle();
    container.read(_durationProvider.notifier).set(Duration.zero);
    await tester.pump();
    host.setState(() => host.state = _start);
    await tester.pump();
    expect(tester.hasRunningAnimations, isFalse);
    expect(container.read(activeBoardProvider)!.fen, kInitialFEN);
  });
}

final _durationProvider = NotifierProvider<_Duration, Duration>(_Duration.new);

final class _Duration extends Notifier<Duration> {
  @override
  Duration build() => const Duration(milliseconds: 200);

  // A setter would hide the notifier's own state field.
  // ignore: use_setters_to_change_properties
  void set(Duration d) => state = d;
}
