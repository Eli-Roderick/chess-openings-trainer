// Performance budgets measured AOT in profile mode (D-61):
// - P04: Home shows data < 1 s after main() with 10 repertoires.
// - P05/P06: dragging pieces in Browse for 30 s, with engine analysis
//   running, has no frame over budget.
// CI runs this file with
// `xvfb-run flutter drive --profile -d linux
//   --driver=test_driver/integration_test.dart
//   --target=integration_test/profile_test.dart`;
// under `flutter test` (debug, JIT) only loose bounds are checked.
import 'dart:developer' show Timeline;
import 'dart:io';
import 'dart:ui' show FramePhase, FrameTiming;

import 'package:chess_core/chess_core.dart';
import 'package:dartchess/dartchess.dart' show Side;
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:repertoire_trainer/app/bootstrap.dart';
import 'package:repertoire_trainer/core/db/app_database.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/core/db/repositories/repertoire_repository.dart';
import 'package:repertoire_trainer/core/db/repositories/sync_state_repository.dart';
import 'package:repertoire_trainer/core/diagnostics/frame_stats.dart';
import 'package:repertoire_trainer/core/diagnostics/startup_timings.dart';
import 'package:repertoire_trainer/features/board/repertoire_board.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('cold start with 10 repertoires shows Home data in < 1 s', (
    tester,
  ) async {
    final dir = await Directory.systemTemp.createTemp('rt_cold_');
    final dbFile = File(p.join(dir.path, 'repertoire.sqlite'));
    final seed = AppDatabase(NativeDatabase(dbFile));
    var next = 0;
    final repo = DriftRepertoireRepository(
      seed,
      clock: const SystemClock(),
      newId: () => 'id-${next++}',
      deviceId: DriftSyncStateRepository(seed, newId: () => 'dev').deviceId,
    );
    final pgn = generateSyntheticPgn(lines: 12, depth: 12, seed: 1);
    final result = importPgn(pgn, Side.white);
    for (var i = 0; i < 10; i++) {
      await repo.create(
        name: 'Repertoire $i',
        color: Side.white,
        pgn: pgn,
        result: result,
      );
    }
    await seed.close();

    await bootstrap(
      overrides: [
        databaseProvider.overrideWith((ref) {
          final db = AppDatabase(NativeDatabase.createInBackground(dbFile));
          ref.onDispose(db.close);
          return db;
        }),
      ],
    );
    final card = find.text('Repertoire 9');
    final watch = Stopwatch()..start();
    while (card.evaluate().isEmpty && watch.elapsed.inSeconds < 30) {
      await tester.pump(const Duration(milliseconds: 20));
    }
    final t = StartupTimings.instance;
    final total = t.mainToHomeData;
    // The timing log the acceptance criterion asks for.
    // ignore: avoid_print
    print(
      'Cold start (${kDebugMode ? 'debug' : 'AOT'}): '
      'main -> runApp ${t.mainToRunApp?.inMilliseconds} ms, '
      'first frame +${t.runAppToFirstFrame?.inMilliseconds} ms, '
      'Home data +${t.firstFrameToHomeData?.inMilliseconds} ms, '
      'total ${total?.inMilliseconds} ms',
    );
    expect(total, isNotNull);
    expect(
      total,
      lessThan(
        kDebugMode ? const Duration(seconds: 5) : const Duration(seconds: 1),
      ),
    );
  });

  testWidgets('dragging pieces for 30 s stays within the frame budget', (
    tester,
  ) async {
    final dir = await Directory.systemTemp.createTemp('rt_drag_');
    final dbFile = File(p.join(dir.path, 'repertoire.sqlite'));
    await bootstrap(
      overrides: [
        databaseProvider.overrideWith((ref) {
          final db = AppDatabase(NativeDatabase.createInBackground(dbFile));
          ref.onDispose(db.close);
          return db;
        }),
      ],
    );
    Future<void> waitFor(Finder f) async {
      final watch = Stopwatch()..start();
      while (f.evaluate().isEmpty && watch.elapsed.inSeconds < 30) {
        await tester.pump(const Duration(milliseconds: 20));
      }
      expect(f, findsWidgets);
    }

    await waitFor(find.byKey(const Key('try-demo')));
    await tester.tap(find.byKey(const Key('try-demo')));
    await waitFor(find.text('Demo: Italian (White)'));
    await tester.tap(find.text('Demo: Italian (White)'));
    await waitFor(find.byKey(const Key('browse')));
    await tester.tap(find.byKey(const Key('browse')));
    await waitFor(find.byType(RepertoireBoard));
    await tester.pump(const Duration(seconds: 1));

    final board = tester.getRect(find.byType(RepertoireBoard));
    final square = board.width / 8;
    Offset centre(int file, int rank) => Offset(
      board.left + (file + 0.5) * square,
      board.top + (7 - rank + 0.5) * square,
    );
    // Analysis runs during the whole script (P06: the engine never blocks
    // the UI).
    await tester.tap(find.byKey(const Key('analysis-toggle')));
    await waitFor(find.byKey(const Key('pv-0')));
    // Warm-up: the first navigation after opening Browse has one-off costs
    // (about 30 ms of UI work on the CI runner, D-71); the script measures
    // steady-state dragging.
    await tester.tap(find.byKey(const Key('nav-forward')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('nav-back')));
    await tester.pump(const Duration(milliseconds: 300));
    final stats = FrameStats.instance..reset();
    // Slow builds are reported with the script step they followed.
    final marks = <(int, String)>[];
    void mark(String what) => marks.add((Timeline.now, what));
    final slow = <FrameTiming>[];
    SchedulerBinding.instance.addTimingsCallback((ts) {
      slow.addAll(ts.where((t) => t.buildDuration > FrameStats.jankBudget));
    });
    final watch = Stopwatch()..start();
    var drags = 0;
    while (watch.elapsed < const Duration(seconds: 30)) {
      // Drag e2-e4 in 20 steps of one frame each, then step back.
      mark('drag-start $drags');
      final gesture = await tester.startGesture(centre(4, 1));
      final to = centre(4, 3);
      final from = centre(4, 1);
      for (var i = 1; i <= 20; i++) {
        await gesture.moveTo(Offset.lerp(from, to, i / 20)!);
        await tester.pump(const Duration(milliseconds: 16));
      }
      mark('up $drags');
      await gesture.up();
      await tester.pump(const Duration(milliseconds: 300));
      mark('back $drags');
      await tester.tap(find.byKey(const Key('nav-back')));
      await tester.pump(const Duration(milliseconds: 300));
      drags++;
    }
    // The timing log for the acceptance criterion.
    // ignore: avoid_print
    print(
      'Drag script (${kDebugMode ? 'debug' : 'AOT'}): $drags drags, '
      '${stats.count} frames; over '
      '${FrameStats.jankBudget.inMicroseconds / 1000} ms: ${stats.slowBuilds} '
      'builds, ${stats.slowRasters} rasters; worst build '
      '${stats.worstBuild.inMicroseconds / 1000} ms, mean build '
      '${stats.averageBuild.inMicroseconds / 1000} ms, mean raster '
      '${stats.averageRaster.inMicroseconds / 1000} ms',
    );
    for (final t in slow) {
      final start = t.timestampInMicroseconds(FramePhase.buildStart);
      final before = marks.lastWhere(
        (m) => m.$1 <= start,
        orElse: () => (0, '?'),
      );
      // Part of the timing log.
      // ignore: avoid_print
      print(
        'Slow build ${t.buildDuration.inMicroseconds / 1000} ms after '
        '${before.$2} (+${(start - before.$1) / 1000} ms)',
      );
    }
    expect(drags, greaterThan(10));
    expect(find.byKey(const Key('pv-0')), findsOneWidget);
    expect(stats.count, greaterThan(100));
    // The UI thread must not miss the budget; one miss in 30 s is tolerated
    // for scheduling noise on the shared CI VM. Raster time is logged but
    // not asserted: the runner has no GPU and rasterizes in software
    // (D-71). Devices are checked by hand (P05 device checklist).
    if (!kDebugMode) expect(stats.slowBuilds, lessThanOrEqualTo(1));
  });
}
