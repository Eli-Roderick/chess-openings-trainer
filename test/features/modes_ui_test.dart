import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repertoire_trainer/app/router.dart';
import 'package:repertoire_trainer/app/routes.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/core/settings/app_settings.dart';
import 'package:repertoire_trainer/features/board/repertoire_board.dart';

import '../app_harness.dart';

const _pgn = '1. e4 {[%why Centre.]} e5 2. Nf3 Nc6 3. Bb5 *';

Future<void> go(AppHarness h, String location) async {
  h.container.read(routerProvider).go(location);
  await h.settle();
}

Future<void> move(AppHarness h, String uci) async {
  expect(h.container.read(activeBoardProvider)!.debugPlayUserMove(uci), isTrue);
  await h.tester.pump();
}

Future<void> setSettings(
  AppHarness h,
  AppSettings Function(AppSettings) change,
) => h.tester.runAsync(
  () => h.container.read(settingsRepositoryProvider).update(change),
);

void main() {
  testWidgets('mode sheet: weak disabled with a hint, SRS counts, the '
      'choice starts the drill and is remembered', (tester) async {
    final h = await AppHarness.pump(tester, size: const Size(400, 900));
    final id = await h.create('Rep', _pgn);
    await go(h, Routes.repertoire(id));
    await tester.tap(find.byKey(const Key('train')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('mode-sheet')), findsOneWidget);
    expect(
      tester
          .widget<RadioListTile<Object?>>(find.byKey(const Key('mode-weak')))
          .enabled,
      isFalse,
    );
    expect(find.textContaining('No weak lines yet'), findsOneWidget);
    expect(find.text('0 due, 1 new available'), findsOneWidget);
    // Deviations: mirrors the setting (off), changeable for the session.
    final deviations = tester.widget<SwitchListTile>(
      find.byKey(const Key('sheet-deviations')),
    );
    expect((deviations.value, deviations.onChanged != null), (false, true));
    await tester.tap(find.byKey(const Key('mode-srs')));
    await tester.tap(find.text('Branch point'));
    await tester.pump();
    await tester.tap(find.byKey(const Key('sheet-start')));
    await h.settle();
    expect(find.text('Rep · SRS 1 left'), findsOneWidget);
    final row = await tester.runAsync(
      () => h.container.read(repertoireRepositoryProvider).get(id),
    );
    expect((row!.lastMode, row.drillStartFrom), ('srs', 'branch'));
  });

  testWidgets('Continue resumes the last trained repertoire in its mode', (
    tester,
  ) async {
    final h = await AppHarness.pump(tester);
    final id = await h.create('Rep', '1. e4 e5 *');
    expect(find.byKey(const Key('continue')), findsNothing);
    await go(h, Routes.train(id, mode: 'random'));
    await move(h, 'e2e4');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('end-accuracy')));
    await h.settle();
    await go(h, Routes.home);
    expect(find.text('Continue: Rep · Random'), findsOneWidget);
    await tester.tap(find.byKey(const Key('continue')));
    await h.settle();
    expect(find.text('Rep · Random'), findsOneWidget);
  });

  testWidgets('line summary screen: grades, first attempt, comment; Browse '
      'this line', (tester) async {
    final h = await AppHarness.pump(tester, size: const Size(400, 1000));
    await setSettings(h, (s) => s.copyWith(showLineSummary: true));
    final id = await h.create('Rep', _pgn);
    await go(h, Routes.train(id));
    await move(h, 'd2d4');
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump(const Duration(milliseconds: 100));
    }
    await move(h, 'e2e4');
    await tester.pump(const Duration(milliseconds: 300));
    await move(h, 'g1f3');
    await tester.pump(const Duration(milliseconds: 300));
    await move(h, 'f1b5');
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byKey(const Key('line-summary')), findsOneWidget);
    expect(find.text('2/3 · 67 %'), findsOneWidget);
    expect(find.textContaining('You played d4'), findsOneWidget);
    expect(find.textContaining('Centre.'), findsOneWidget);
    expect(find.text('Entered weak pool'), findsOneWidget);
    await tester.tap(find.byKey(const Key('summary-browse')));
    await h.settle();
    expect(find.byKey(const Key('nav-forward')), findsOneWidget);
    expect(find.text('3.Bb5'), findsWidgets);
  });

  testWidgets('Weak mode with an empty pool; Random from there', (
    tester,
  ) async {
    final h = await AppHarness.pump(tester);
    final id = await h.create('Rep', _pgn);
    await go(h, Routes.train(id, mode: 'weak'));
    expect(find.text('No weak lines. Nice.'), findsOneWidget);
    await tester.tap(find.byKey(const Key('empty-random')));
    await h.settle();
    expect(find.text('Rep · Random'), findsOneWidget);
    expect(find.text('Your move'), findsOneWidget);
  });

  testWidgets('SRS all caught up', (tester) async {
    final h = await AppHarness.pump(tester);
    await setSettings(h, (s) => s.copyWith(srsNewPerDay: 0));
    final id = await h.create('Rep', _pgn);
    await go(h, Routes.train(id, mode: 'srs'));
    expect(find.text('All caught up.'), findsOneWidget);
    expect(find.byKey(const Key('empty-weak')), findsOneWidget);
    await tester.tap(find.byKey(const Key('empty-done')));
    await h.settle();
    expect(find.byKey(const Key('empty-text')), findsNothing);
  });

  testWidgets('Training settings: weak thresholds, SRS limits, day start', (
    tester,
  ) async {
    final h = await AppHarness.pump(tester, size: const Size(400, 2000));
    await go(h, Routes.settingsSection('training'));
    await tester.tap(find.byKey(const Key('show-line-summary')));
    await tester.tap(find.byKey(const Key('srs-max-reviews')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('50').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('day-start')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('06:00').last);
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const Key('weak-enter-below')),
      const Offset(500, 0),
    );
    await h.settle();
    final s = await tester.runAsync(
      () => h.container.read(settingsRepositoryProvider).load(),
    );
    expect(s!.showLineSummary, isTrue);
    expect(s.srsMaxReviewsPerDay, 50);
    expect(s.dayStartHour, 6);
    expect(s.weakEnterBelowPercent, 95);
  });
}
