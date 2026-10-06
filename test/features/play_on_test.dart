import 'package:dartchess/dartchess.dart' show Position, Side;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repertoire_trainer/app/router.dart';
import 'package:repertoire_trainer/app/routes.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/features/board/board_position.dart';
import 'package:repertoire_trainer/features/board/free_move.dart';
import 'package:repertoire_trainer/features/board/repertoire_board.dart';
import 'package:repertoire_trainer/features/play/play_on_screen.dart';

import '../app_harness.dart';

const _start = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';

/// A scripted engine: [replies] in order, then nothing.
final class _Script {
  new(this.replies);

  final List<String> replies;
  final asked = <String>[];

  Future<String?> call(String fen) async {
    asked.add(fen);
    return replies.isEmpty ? null : replies.removeAt(0);
  }
}

PlayOnArgs _args(String fen, {Side user = Side.white}) => PlayOnArgs(
  repertoireId: 'r',
  nodeId: 0,
  nodeFen: fen,
  userSide: user,
  orientation: user,
);

Future<AppHarness> _open(
  WidgetTester tester,
  _Script engine,
  PlayOnArgs args,
) async {
  final h = await AppHarness.pump(
    tester,
    overrides: [playOnEngineProvider.overrideWithValue(engine.call)],
  );
  h.container.read(routerProvider).go(Routes.home);
  await h.settle();
  // The route completes when the screen pops.
  // ignore: unawaited_futures
  h.container.read(routerProvider).push(Routes.playEngine, extra: args);
  await h.settle();
  return h;
}

Future<void> _move(AppHarness h, String uci) async {
  expect(h.container.read(activeBoardProvider)!.debugPlayUserMove(uci), isTrue);
  await h.tester.pump();
  // The engine's reply shows after at least 300 ms.
  await h.tester.pump(const Duration(milliseconds: 350));
  await h.settle();
}

String _fen(WidgetTester tester) =>
    tester.widget<RepertoireBoard>(find.byType(RepertoireBoard)).state.fen;

void main() {
  group('playOnResult', () {
    test('mate, stalemate, insufficient material, threefold, 50 moves', () {
      Position at(String fen) => positionFromFen(fen);
      // Scholar's mate: Black is mated.
      const mated =
          'r1bqkb1r/pppp1Qpp/2n2n2/4p3/2B1P3/8/PPPP1PPP/RNB1K1NR b KQkq - 0 4';
      expect(
        playOnResult(at(mated), userSide: Side.white),
        PlayOnResult.userMates,
      );
      expect(
        playOnResult(at(mated), userSide: Side.black),
        PlayOnResult.engineMates,
      );
      expect(
        playOnResult(
          at('7k/5Q2/6K1/8/8/8/8/8 b - - 0 1'),
          userSide: Side.white,
        ),
        PlayOnResult.stalemate,
      );
      expect(
        playOnResult(at('8/8/8/4k3/8/8/8/4K3 w - - 0 1'), userSide: Side.white),
        PlayOnResult.insufficientMaterial,
      );
      expect(
        playOnResult(at(_start), userSide: Side.white, repetitions: 3),
        PlayOnResult.threefold,
      );
      expect(
        playOnResult(
          at('4k3/8/8/8/8/8/8/R3K3 w - - 100 80'),
          userSide: Side.white,
        ),
        PlayOnResult.fiftyMoves,
      );
      expect(playOnResult(at(_start), userSide: Side.white), isNull);
      expect(
        repetitionKey(_start),
        'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq -',
      );
    });
  });

  testWidgets('the engine replies with a legal move; take back restores two '
      'plies', (tester) async {
    final engine = _Script(['e7e5', 'b8c6']);
    final h = await _open(tester, engine, _args(_start));
    expect(find.text('Your move'), findsOneWidget);
    await _move(h, 'e2e4');
    expect(engine.asked.single, contains('4P3'));
    expect(
      _fen(tester),
      'rnbqkbnr/pppp1ppp/8/4p3/4P3/8/PPPP1PPP/RNBQKBNR w KQkq - 0 2',
    );
    expect(find.text('1.e4 e5'), findsOneWidget);
    await tester.tap(find.byKey(const Key('take-back')));
    await h.settle();
    expect(_fen(tester), _start);
    expect(
      tester
          .widget<OutlinedButton>(find.byKey(const Key('take-back')))
          .onPressed,
      isNull,
    );
    await _move(h, 'g1f3');
    expect(find.text('1.Nf3 Nc6'), findsOneWidget);
  });

  testWidgets('the engine moves first when it is its turn', (tester) async {
    final engine = _Script(['e2e4']);
    await _open(tester, engine, _args(_start, user: Side.black));
    await tester.pump(const Duration(milliseconds: 350));
    expect(engine.asked, [_start]);
    expect(_fen(tester), contains('4P3'));
  });

  testWidgets('checkmate ends the game with a dialog; Back to training '
      'leaves', (tester) async {
    final h = await _open(
      tester,
      _Script([]),
      _args('6k1/5ppp/8/8/8/8/8/R5K1 w - - 0 1'),
    );
    await _move(h, 'a1a8');
    expect(find.byKey(const Key('play-on-result')), findsOneWidget);
    expect(find.text('Checkmate. You win.'), findsWidgets);
    await tester.tap(find.byKey(const Key('result-back')));
    await h.settle();
    expect(find.byType(PlayOnScreen), findsNothing);
  });

  testWidgets('threefold repetition by shuffling knights', (tester) async {
    final engine = _Script(['g8f6', 'f6g8', 'g8f6', 'f6g8']);
    final h = await _open(tester, engine, _args(_start));
    for (final m in ['g1f3', 'f3g1', 'g1f3', 'f3g1']) {
      await _move(h, m);
    }
    expect(find.text('Threefold repetition. Draw.'), findsWidgets);
  });

  testWidgets('Analyse opens Browse at the position with analysis on', (
    tester,
  ) async {
    final h = await AppHarness.pump(
      tester,
      overrides: [playOnEngineProvider.overrideWithValue(_Script([]).call)],
    );
    final id = await h.create('Rep', '1. e4 e5 2. Nf3 *');
    final tree = await tester.runAsync(
      () => h.container.read(repertoireTreeProvider(id).future),
    );
    final leaf = tree!.lines.single.leaf;
    final args = PlayOnArgs(
      repertoireId: id,
      nodeId: leaf.id,
      nodeFen: leaf.fen,
      userSide: Side.white,
      orientation: Side.white,
      moves: const [
        FreeMove(
          uci: 'b8c6',
          san: 'Nc6',
          fen: 'r1bqkbnr/pppp1ppp/2n5/4p3/4P3/5N2/PPPP1PPP/RNBQKB1R w KQkq - 2 3',
        ),
      ],
    );
    // The route completes when the screen pops.
    // ignore: unawaited_futures
    h.container.read(routerProvider).push(Routes.playEngine, extra: args);
    await h.settle();
    await tester.tap(find.byKey(const Key('play-on-analyse')));
    await h.settle();
    expect(find.text('Exploring (not saved)'), findsWidgets);
    expect(_fen(tester), args.fen);
  });
}
