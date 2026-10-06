import 'package:chess_core/chess_core.dart';
import 'package:dartchess/dartchess.dart' show Side;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repertoire_trainer/app/router.dart';
import 'package:repertoire_trainer/app/routes.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/features/board/repertoire_board.dart';

import '../app_harness.dart';

Future<(AppHarness, RepertoireTree)> openBrowse(
  WidgetTester tester, {
  int? node,
  Size size = const Size(400, 800),
}) async {
  final h = await AppHarness.pump(tester, size: size);
  final id = await h.create(
    'Caro',
    fixture('black_caro.pgn'),
    side: Side.black,
  );
  h.container.read(routerProvider).go(Routes.browse(id, node: node));
  await h.settle();
  final tree = (await tester.runAsync(
    () => h.container.read(repertoireTreeProvider(id).future),
  ))!;
  await h.settle();
  return (h, tree);
}

BoardViewState board(WidgetTester tester) =>
    tester.widget<RepertoireBoard>(find.byType(RepertoireBoard)).state;

Future<void> key(WidgetTester tester, LogicalKeyboardKey k) async {
  await tester.sendKeyEvent(k);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('steps through the tree with the buttons and the chooser', (
    tester,
  ) async {
    final (h, tree) = await openBrowse(tester);
    expect(find.text('Start position'), findsOneWidget);
    expect(board(tester).orientation, Side.black);
    await tester.tap(find.byKey(const Key('nav-forward')));
    await tester.pumpAndSettle();
    expect(find.text('1.e4 · Opponent move'), findsOneWidget);
    expect(h.sounds.played.last, 'assets/sounds/move.ogg');
    await tester.tap(find.byKey(const Key('nav-forward')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Prepares ...d5'), findsOneWidget);
    expect(find.byKey(const Key('comment-heading')), findsOneWidget);
    // To 2...d5 (a fork: 3.e5 and 3.Nc3).
    await tester.tap(find.byKey(const Key('nav-forward')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('nav-forward')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('nav-forward')));
    await tester.pumpAndSettle();
    expect(find.text('Choose a move'), findsOneWidget);
    await tester.tap(find.byKey(const Key('fork-choice-b1c3')));
    await tester.pumpAndSettle();
    expect(find.text('3.Nc3 · Opponent move'), findsOneWidget);
    await tester.tap(find.byKey(const Key('nav-forward')));
    await tester.pumpAndSettle();
    expect(find.textContaining('free the c8-bishop'), findsOneWidget);
    expect(h.sounds.played.last, 'assets/sounds/capture.ogg');
    await tester.tap(find.byKey(const Key('nav-back')));
    await tester.pumpAndSettle();
    expect(find.text('3.Nc3 · Opponent move'), findsOneWidget);
    await tester.tap(find.byKey(const Key('nav-last')));
    await tester.pumpAndSettle();
    expect(find.textContaining('develops with tempo'), findsOneWidget);
    await tester.tap(find.byKey(const Key('nav-first')));
    await tester.pumpAndSettle();
    expect(find.text('Start position'), findsOneWidget);
    expect(tree.lines, hasLength(3));
  });

  testWidgets('keyboard: arrows, Home, End, up/down, F', (tester) async {
    await openBrowse(tester);
    await key(tester, LogicalKeyboardKey.end);
    expect(find.textContaining('frees the f8-bishop'), findsOneWidget);
    await key(tester, LogicalKeyboardKey.arrowLeft);
    expect(find.text('4.Nf3 · Opponent move'), findsOneWidget);
    await key(tester, LogicalKeyboardKey.arrowLeft);
    expect(find.textContaining('before ...e6 locks it in'), findsOneWidget);
    // 3...Bf5 and 3...c5 are siblings.
    await key(tester, LogicalKeyboardKey.arrowDown);
    expect(find.textContaining('sharper alternative'), findsOneWidget);
    await key(tester, LogicalKeyboardKey.arrowUp);
    expect(find.textContaining('before ...e6 locks it in'), findsOneWidget);
    await key(tester, LogicalKeyboardKey.home);
    expect(find.text('Start position'), findsOneWidget);
    await key(tester, LogicalKeyboardKey.arrowRight);
    expect(find.text('1.e4 · Opponent move'), findsOneWidget);
    await key(tester, LogicalKeyboardKey.keyF);
    expect(board(tester).orientation, Side.white);
  });

  testWidgets('free exploration and back to the repertoire', (tester) async {
    final (h, _) = await openBrowse(tester);
    final controller = h.container.read(activeBoardProvider)!;
    // A repertoire move navigates.
    expect(controller.debugPlayUserMove('e2e4'), isTrue);
    await tester.pumpAndSettle();
    expect(find.text('1.e4 · Opponent move'), findsOneWidget);
    // Anything else explores.
    expect(controller.debugPlayUserMove('e7e5'), isTrue);
    await tester.pumpAndSettle();
    expect(find.text('1...e5'), findsWidgets);
    expect(find.byKey(const Key('free-moves')), findsOneWidget);
    expect(controller.debugPlayUserMove('g1f3'), isTrue);
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.byKey(const Key('free-moves'))).data,
      '1...e5 2.Nf3',
    );
    expect(find.text('Exploring (not saved)'), findsOneWidget);
    await key(tester, LogicalKeyboardKey.arrowLeft);
    expect(
      tester.widget<Text>(find.byKey(const Key('free-moves'))).data,
      '1...e5',
    );
    await tester.tap(find.byKey(const Key('back-to-repertoire')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('free-moves')), findsNothing);
    expect(find.text('1.e4 · Opponent move'), findsOneWidget);
  });

  testWidgets('swipes below the board navigate', (tester) async {
    await openBrowse(tester);
    await tester.fling(
      find.byKey(const Key('swipe-area')),
      const Offset(-300, 0),
      1000,
    );
    await tester.pumpAndSettle();
    expect(find.text('1.e4 · Opponent move'), findsOneWidget);
    await tester.fling(
      find.byKey(const Key('swipe-area')),
      const Offset(300, 0),
      1000,
    );
    await tester.pumpAndSettle();
    expect(find.text('Start position'), findsOneWidget);
  });

  testWidgets('tapping a move in the move list jumps there', (tester) async {
    await openBrowse(tester);
    await tester.ensureVisible(find.text('3...c5'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('3...c5'));
    await tester.pumpAndSettle();
    expect(find.textContaining('sharper alternative'), findsOneWidget);
  });

  testWidgets('deep link ?node= opens at that node', (tester) async {
    final caro = importPgn(fixture('black_caro.pgn'), Side.black).tree!;
    final c5 = caro.nodes.firstWhere((n) => n.san == 'c5');
    await openBrowse(tester, node: c5.id);
    expect(find.textContaining('sharper alternative'), findsOneWidget);
  });

  testWidgets('wide layout: board left, panel right, no overflow', (
    tester,
  ) async {
    await openBrowse(tester, size: const Size(1000, 700));
    final boardRect = tester.getRect(find.byType(RepertoireBoard));
    expect(boardRect.width, boardRect.height);
    expect(boardRect.left, lessThan(10));
    final list = tester.getRect(find.byKey(const Key('move-tree')));
    expect(list.left, greaterThanOrEqualTo(boardRect.right));
    expect(tester.takeException(), isNull);
  });
}
