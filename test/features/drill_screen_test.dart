import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repertoire_trainer/app/router.dart';
import 'package:repertoire_trainer/app/routes.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/core/settings/app_settings.dart';
import 'package:repertoire_trainer/core/sync/sync_controller.dart';
import 'package:repertoire_trainer/features/board/repertoire_board.dart';

import '../app_harness.dart';
import '../core/engine/fake_engine.dart';

const _single = '1. e4 {[%why Centre.]} e5 2. Nf3 Nc6 3. Bb5 *';

Future<String> openDrill(
  AppHarness h, {
  String pgn = _single,
  AppSettings Function(AppSettings)? settings,
}) async {
  if (settings != null) {
    await h.tester.runAsync(
      () => h.container.read(settingsRepositoryProvider).update(settings),
    );
  }
  final id = await h.create('Drill', pgn);
  h.container.read(routerProvider).go(Routes.train(id));
  await h.settle();
  return id;
}

Future<void> move(AppHarness h, String uci) async {
  expect(h.container.read(activeBoardProvider)!.debugPlayUserMove(uci), isTrue);
  await h.tester.pump();
}

Future<void> opponent(WidgetTester tester) =>
    tester.pump(const Duration(milliseconds: 260));

void main() {
  testWidgets('a full line: progress, comment, end bar with countdown; a '
      'tap cancels it, Next line starts again', (tester) async {
    final h = await AppHarness.pump(tester);
    await openDrill(h);
    expect(find.text('Drill · Random'), findsOneWidget);
    expect(find.text('Your move'), findsOneWidget);
    expect(find.text('Move 1 of 3'), findsOneWidget);
    await move(h, 'e2e4');
    expect(find.textContaining('Centre.'), findsOneWidget);
    expect(find.text('1/1 · 100 %'), findsOneWidget);
    await opponent(tester);
    await move(h, 'g1f3');
    await opponent(tester);
    await move(h, 'f1b5');
    await tester.pump();
    expect(find.byKey(const Key('end-bar')), findsOneWidget);
    expect(find.text('3/3 · 100 %'), findsOneWidget);
    expect(find.byKey(const Key('countdown')), findsOneWidget);
    await tester.tap(find.byKey(const Key('end-accuracy')));
    await tester.pump();
    expect(find.byKey(const Key('countdown')), findsNothing);
    await tester.pump(const Duration(seconds: 3));
    expect(find.byKey(const Key('end-bar')), findsOneWidget);
    await h.settle();
    await tester.tap(find.byKey(const Key('next-line')));
    await h.settle();
    expect(find.byKey(const Key('end-bar')), findsNothing);
    expect(find.text('Move 1 of 3'), findsOneWidget);
    // The run was stored and derived.
    final stats = await tester.runAsync(
      () => h.container
          .read(statsRepositoryProvider)
          .lineStats(
            h.container.read(routerProvider).state.pathParameters['id']!,
          ),
    );
    expect(stats!.single.accuracy, 1.0);
  });

  testWidgets('auto-advance after the delay', (tester) async {
    final h = await AppHarness.pump(tester);
    await openDrill(h, pgn: '1. e4 e5 *');
    await move(h, 'e2e4');
    await opponent(tester);
    expect(find.byKey(const Key('end-bar')), findsOneWidget);
    await h.settle();
    await tester.pump(const Duration(milliseconds: 1600));
    await h.settle();
    expect(find.byKey(const Key('end-bar')), findsNothing);
    expect(find.text('Your move'), findsOneWidget);
  });

  testWidgets('a comparable wrong move shows the banner; tap dismisses', (
    tester,
  ) async {
    final engine = FakeEngine(scores: {'e2e4': 30, 'd2d4': 25});
    final h = await AppHarness.pump(tester, engine: engine);
    await openDrill(h);
    await move(h, 'd2d4');
    // Flash, then the take-back; the check runs 1 s.
    for (var i = 0; i < 15; i++) {
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(
      find.text(
        'That is not the move in your repertoire, but it is a comparable move.',
      ),
      findsOneWidget,
    );
    expect(find.text('0.5/1 · 50 %'), findsOneWidget);
    await tester.tap(find.byKey(const Key('banner-comparable')));
    await tester.pump();
    expect(find.byKey(const Key('banner-comparable')), findsNothing);
  });

  testWidgets('without an engine a wrong move gets no banner', (tester) async {
    final h = await AppHarness.pump(tester);
    await openDrill(h);
    await move(h, 'd2d4');
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byKey(const Key('banner-comparable')), findsNothing);
    expect(find.text('0/1 · 0 %'), findsOneWidget);
    expect(find.text('Your move'), findsOneWidget);
  });

  testWidgets('H hints, F flips, the hint button changes label', (
    tester,
  ) async {
    final h = await AppHarness.pump(tester);
    await openDrill(h);
    expect(find.text('Hint'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyH);
    await tester.pump();
    expect(find.text('Show move'), findsOneWidget);
    BoardViewState board() =>
        tester.widget<RepertoireBoard>(find.byType(RepertoireBoard)).state;
    expect(board().highlights, isNotEmpty);
    await tester.tap(find.byKey(const Key('hint')));
    await tester.pump();
    expect(board().shapes, hasLength(1));
    await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
    await tester.pump();
    expect(board().orientation.name, 'black');
  });

  testWidgets('branch-point start shows the skipped chip and moves', (
    tester,
  ) async {
    final h = await AppHarness.pump(tester);
    await openDrill(
      h,
      pgn: '1. e4 e5 (1... c5 2. Nf3 d6 3. d4) 2. Nf3 Nc6 3. Bb5 *',
      settings: (s) => s.copyWith(startFromBranchPoint: true),
    );
    expect(find.text('Skipped to move 1'), findsOneWidget);
    await tester.tap(find.byKey(const Key('skipped-chip')));
    await tester.pumpAndSettle();
    expect(find.text('1.e4'), findsOneWidget);
  });

  testWidgets('leaving after a completed line shows the session summary', (
    tester,
  ) async {
    final h = await AppHarness.pump(tester);
    final id = await openDrill(h, pgn: '1. e4 e5 *');
    await move(h, 'e2e4');
    await opponent(tester);
    // Stop the countdown before settling (settling runs it to the end).
    await tester.tap(find.byKey(const Key('end-accuracy')));
    await h.settle();
    final nav = tester.state<NavigatorState>(find.byType(Navigator).last);
    await nav.maybePop();
    await h.settle();
    expect(find.byKey(const Key('session-summary')), findsOneWidget);
    expect(find.text('1 line completed'), findsOneWidget);
    expect(find.text('Accuracy 100 %'), findsOneWidget);
    expect(find.text('Streak: 1 day, today done'), findsOneWidget);
    await tester.tap(find.byKey(const Key('session-done')));
    await h.settle();
    expect(find.byKey(const Key('detail-menu')), findsOneWidget);
    expect(id, isNotEmpty);
  });

  testWidgets('leaving mid-line stores an abandoned run', (tester) async {
    final h = await AppHarness.pump(tester);
    final id = await openDrill(h);
    await move(h, 'e2e4');
    await opponent(tester);
    final nav = tester.state<NavigatorState>(find.byType(Navigator).last);
    await nav.maybePop();
    await h.settle();
    final runs = await tester.runAsync(
      () => h.container.read(runRepositoryProvider).runsForRepertoire(id),
    );
    expect(runs!.single.completed, isFalse);
    expect(runs.single.gradedCount, 1);
  });

  testWidgets('Training settings are stored', (tester) async {
    final h = await AppHarness.pump(tester, size: const Size(400, 1200));
    h.container.read(routerProvider).go(Routes.settingsSection('training'));
    await h.settle();
    await tester.tap(find.text('Restart line'));
    await tester.tap(find.text('Branch point'));
    await tester.tap(find.byKey(const Key('show-comments')));
    await h.settle();
    final s = await tester.runAsync(
      () => h.container.read(settingsRepositoryProvider).load(),
    );
    expect(s!.wrongMoveMode.name, 'restart');
    expect(s.startFromBranchPoint, isTrue);
    expect(s.showComments, isFalse);
  });

  testWidgets('sync waits while a line is played; a repertoire deleted on '
      'another device sends the drill home', (tester) async {
    final h = await AppHarness.pump(tester);
    final id = await openDrill(h);
    final gate = h.container.read(syncGateProvider);
    expect(gate.busy, isTrue);
    h.container
        .read(syncControllerProvider.notifier)
        .debugAnnounce(
          SyncChange(
            changedIds: {id},
            deletedIds: {id},
            updatedNames: const [],
          ),
        );
    await h.settle();
    expect(
      find.text('This repertoire was deleted on another device.'),
      findsOneWidget,
    );
    expect(find.byType(RepertoireBoard), findsNothing);
    expect(gate.busy, isFalse);
  });
}
