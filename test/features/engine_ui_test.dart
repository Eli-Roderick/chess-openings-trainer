import 'dart:async';

import 'package:dartchess/dartchess.dart' show Side;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repertoire_trainer/app/router.dart';
import 'package:repertoire_trainer/app/routes.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/core/engine/engine_providers.dart';
import 'package:repertoire_trainer/features/board/eval_bar.dart';
import 'package:uci_engine/uci_engine.dart';

import '../app_harness.dart';
import '../core/engine/fake_engine.dart';

Future<String> openBrowse(AppHarness h) async {
  final id = await h.create(
    'Caro',
    fixture('black_caro.pgn'),
    side: Side.black,
  );
  h.container.read(routerProvider).go(Routes.browse(id));
  await h.settle();
  return id;
}

Future<void> lifecycle(
  WidgetTester tester,
  List<AppLifecycleState> states,
) async {
  states.forEach(tester.binding.handleAppLifecycleStateChanged);
  await tester.pump();
}

void main() {
  testWidgets('analysis: eval bar and lines; PV tap explores; lines '
      'setting; leaving Browse stops the search', (tester) async {
    final engine = FakeEngine(scores: {'e2e4': 35, 'd2d4': 20, 'c2c4': 10});
    final h = await AppHarness.pump(tester, engine: engine);
    await openBrowse(h);
    expect(find.byKey(const Key('analysis-panel')), findsNothing);
    await tester.tap(find.byKey(const Key('analysis-toggle')));
    await tester.pump();
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byKey(const Key('analysis-panel')), findsOneWidget);
    expect(find.byType(EvalBar), findsOneWidget);
    expect(find.textContaining('Depth '), findsOneWidget);
    // White to move at the start, e2e4 at +0.35.
    expect(find.text('+0.35'), findsOneWidget);
    expect(find.byKey(const Key('pv-0')), findsOneWidget);
    expect(engine.commands, contains('go infinite'));

    // Two lines.
    await tester.tap(find.text('2'));
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byKey(const Key('pv-1')), findsOneWidget);
    expect(engine.commands, contains('setoption name MultiPV value 2'));

    // Tapping the second move of the first line explores 1.e4 e5.
    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('pv-0')),
        matching: find.byKey(const Key('pv-move-1')),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      tester.widget<Text>(find.byKey(const Key('free-moves'))).data,
      '1.e4 e5',
    );

    final stops = engine.commands.where((c) => c == 'stop').length;
    h.container.read(routerProvider).go(Routes.home);
    await h.settle();
    expect(engine.commands.where((c) => c == 'stop').length, stops + 1);
    final sent = engine.commands.length;
    await tester.pump(const Duration(seconds: 1));
    expect(engine.commands.length, sent);
  });

  testWidgets('unavailable engine: Analysis disabled with a tooltip', (
    tester,
  ) async {
    final h = await AppHarness.pump(
      tester,
      overrides: [
        engineStatusProvider.overrideWith(
          (ref) => Stream.value(
            const EngineStatus(EngineState.unavailable, message: 'crashed'),
          ),
        ),
      ],
    );
    await openBrowse(h);
    final button = tester.widget<IconButton>(
      find.byKey(const Key('analysis-toggle')),
    );
    expect(button.onPressed, isNull);
    expect(button.tooltip, 'Engine unavailable');
  });

  testWidgets('background: search stops, process quits after 60 s, comes '
      'back on return', (tester) async {
    final engine = FakeEngine();
    final h = await AppHarness.pump(tester, engine: engine);
    await openBrowse(h);
    await tester.tap(find.byKey(const Key('analysis-toggle')));
    await tester.pump(const Duration(milliseconds: 500));
    expect(engine.transports, hasLength(1));
    await lifecycle(tester, [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
    ]);
    await tester.pump(const Duration(milliseconds: 100));
    expect(engine.current.commands.last, 'stop');
    await tester.pump(const Duration(seconds: 59));
    expect(engine.current.exited, isFalse);
    await tester.pump(const Duration(seconds: 2));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();
    expect(engine.current.exited, isTrue);
    await lifecycle(tester, [
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]);
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(engine.transports, hasLength(2));
    expect(engine.current.commands, contains('go infinite'));
  });

  testWidgets('Engine settings: status line, threshold, calibration, '
      'restart', (tester) async {
    final engine = FakeEngine(nps: 2500000);
    final h = await AppHarness.pump(
      tester,
      engine: engine,
      size: const Size(400, 1400),
    );
    h.container.read(routerProvider).go(Routes.settingsSection('engine'));
    await h.settle();
    expect(find.textContaining('Stockfish 18 not running'), findsOneWidget);
    await tester.tap(find.byKey(const Key('run-calibration')));
    for (var i = 0; i < 80; i++) {
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.textContaining('2.50 Mnps · depth'), findsOneWidget);
    expect(find.textContaining('Stockfish 18 ready'), findsOneWidget);
    expect(find.textContaining('2.50 Mnps'), findsWidgets);
    final stored = await tester.runAsync(
      () => h.container.read(syncStateRepositoryProvider).get(calibrationKey),
    );
    expect(stored, contains('"nps":2500000'));

    // Threshold slider: drag to the left end (0.10 pawns).
    await tester.drag(
      find.byKey(const Key('comparable-threshold')),
      const Offset(-500, 0),
    );
    await h.settle();
    final settings = await tester.runAsync(
      () => h.container.read(settingsRepositoryProvider).load(),
    );
    expect(settings!.comparableThresholdCp, 10);
    expect(find.text('0.10 pawns'), findsOneWidget);

    await tester.tap(find.byKey(const Key('restart-engine')));
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(engine.transports, hasLength(2));
    expect(engine.transports.first.exited, isTrue);
  });

  testWidgets('slow device note when the median depth at 1 s is under 12', (
    tester,
  ) async {
    final engine = FakeEngine(step: const Duration(milliseconds: 200));
    final h = await AppHarness.pump(
      tester,
      engine: engine,
      size: const Size(400, 1400),
    );
    h.container.read(routerProvider).go(Routes.settingsSection('engine'));
    await h.settle();
    await tester.tap(find.byKey(const Key('run-calibration')));
    for (var i = 0; i < 80; i++) {
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byKey(const Key('slow-device-note')), findsOneWidget);
  });

  testWidgets('automatic calibration after 10 s idle on Home, once', (
    tester,
  ) async {
    final engine = FakeEngine();
    final h = await AppHarness.pump(tester, engine: engine);
    await tester.pump(const Duration(seconds: 9));
    expect(engine.transports, isEmpty);
    await tester.pump(const Duration(seconds: 2));
    for (var i = 0; i < 80; i++) {
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(engine.commands.where((c) => c.startsWith('go')).length, 6);
    final stored = await tester.runAsync(
      () => h.container.read(syncStateRepositoryProvider).get(calibrationKey),
    );
    expect(stored, isNotNull);
    // Leaving and returning to Home does not calibrate again.
    h.container.read(routerProvider).go(Routes.settings);
    await h.settle();
    h.container.read(routerProvider).go(Routes.home);
    await h.settle();
    await tester.pump(const Duration(seconds: 15));
    expect(engine.commands.where((c) => c.startsWith('go')).length, 6);
  });

  testWidgets('a screen over Home postpones the automatic calibration', (
    tester,
  ) async {
    final engine = FakeEngine();
    final h = await AppHarness.pump(tester, engine: engine);
    await tester.pump(const Duration(seconds: 5));
    h.container.read(routerProvider).go(Routes.settings);
    await h.settle();
    await tester.pump(const Duration(seconds: 30));
    expect(engine.transports, isEmpty);
    h.container.read(routerProvider).go(Routes.home);
    await h.settle();
    await tester.pump(const Duration(seconds: 11));
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(engine.transports, hasLength(1));
    for (var i = 0; i < 80; i++) {
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump(const Duration(milliseconds: 100));
    }
  });

  testWidgets('Diagnostics engine section', (tester) async {
    final engine = FakeEngine();
    final h = await AppHarness.pump(
      tester,
      engine: engine,
      size: const Size(400, 2000),
    );
    unawaited(
      h.container
          .read(engineServiceProvider)
          .topLines('8/8/8/8/8/8/8/K6k w - - 0 1'),
    );
    for (var i = 0; i < 12; i++) {
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump(const Duration(milliseconds: 100));
    }
    h.container.read(routerProvider).go(Routes.diagnostics);
    await h.settle();
    expect(find.byKey(const Key('diagnostics-engine')), findsOneWidget);
    expect(find.text('/fake/stockfish'), findsOneWidget);
    expect(find.text('Stockfish 18'), findsOneWidget);
    expect(find.textContaining('candidates '), findsOneWidget);
  });
}
