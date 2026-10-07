// Performance budgets measured AOT in profile mode (D-61):
// - P04: Home shows data < 1 s after main() with 10 repertoires.
// - P05/P06: dragging pieces in Browse for 30 s, with engine analysis
//   running, has no frame over budget.
// - P07: drill latency p95 <= 300 ms.
// - P13: across 20 drilled lines, < 1 % of frames over the build budget.
// - P10: the stats screen opens in < 300 ms with 20k runs.
// - P11: a backup of 20k runs exports in < 3 s and imports in < 5 s.
// - G3: an analysed 120-ply game review opens in < 150 ms; stepping
//   through every move has no frame over the build budget.
// CI runs this file with
// `xvfb-run flutter drive --profile -d linux
//   --driver=test_driver/integration_test.dart
//   --target=integration_test/profile_test.dart`;
// under `flutter test` (debug, JIT) only loose bounds are checked.
import 'dart:developer' show Timeline;
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' show FramePhase, FrameTiming;

import 'package:chess_core/chess_core.dart';
import 'package:chessground/chessground.dart' show PlayerSide;
import 'package:dartchess/dartchess.dart'
    show Chess, NormalMove, Position, Side;
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:repertoire_trainer/app/bootstrap.dart';
import 'package:repertoire_trainer/app/router.dart';
import 'package:repertoire_trainer/app/routes.dart';
import 'package:repertoire_trainer/core/analysis/game_analyzer.dart';
import 'package:repertoire_trainer/core/db/app_database.dart';
import 'package:repertoire_trainer/core/db/backup_queries.dart';
import 'package:repertoire_trainer/core/db/merge_applier.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/core/db/repositories/games_repository.dart';
import 'package:repertoire_trainer/core/db/repositories/repertoire_repository.dart';
import 'package:repertoire_trainer/core/db/repositories/run_repository.dart';
import 'package:repertoire_trainer/core/db/repositories/settings_repository.dart';
import 'package:repertoire_trainer/core/db/repositories/stats_repository.dart';
import 'package:repertoire_trainer/core/db/repositories/sync_state_repository.dart';
import 'package:repertoire_trainer/core/db/stats_service.dart';
import 'package:repertoire_trainer/core/diagnostics/drill_latency.dart';
import 'package:repertoire_trainer/core/diagnostics/frame_stats.dart';
import 'package:repertoire_trainer/core/diagnostics/startup_timings.dart';
import 'package:repertoire_trainer/features/backup/backup_service.dart';
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
      slow.addAll(ts.where((t) => t.buildDuration > stats.budget));
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
      '${stats.budget.inMicroseconds / 1000} ms: ${stats.slowBuilds} '
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

  testWidgets('drill: latency p95 <= 300 ms (user move -> opponent move); '
      '< 1 % of frames over budget across 20 lines', (tester) async {
    final dir = await Directory.systemTemp.createTemp('rt_latency_');
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
    await waitFor(find.byKey(const Key('train')));
    final container = ProviderScope.containerOf(
      tester.element(find.byKey(const Key('train'))),
    );
    final id = (await container.read(repertoireSummariesProvider.future))
        .single
        .id;
    final tree = await container
        .read(repertoireRepositoryProvider)
        .loadTree(id);
    // Train opens the mode sheet (P08); Random is preselected.
    await tester.tap(find.byKey(const Key('train')));
    await waitFor(find.byKey(const Key('sheet-start')));
    await tester.ensureVisible(find.byKey(const Key('sheet-start')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('sheet-start')));
    await waitFor(find.byType(RepertoireBoard));
    DrillLatency.instance.reset();
    final frames = FrameStats.instance..reset();
    BoardViewState board() =>
        tester.widget<RepertoireBoard>(find.byType(RepertoireBoard)).state;
    var userMoves = 0;
    var lines = 0;
    final watch = Stopwatch()..start();
    while (lines < 20 && watch.elapsed.inSeconds < 240) {
      await tester.pump(const Duration(milliseconds: 10));
      if (find.byKey(const Key('end-bar')).evaluate().isNotEmpty) {
        lines++;
        await tester.tap(find.byKey(const Key('next-line')));
        continue;
      }
      if (board().movable == PlayerSide.none) continue;
      final node = tree.nodes.firstWhere((n) => n.fen == board().fen);
      final move = node.children.firstWhere((c) => c.isUserMove);
      // Played like a dropped piece (the board's test hook).
      container.read(activeBoardProvider)!.debugPlayUserMove(move.uci!);
      userMoves++;
    }
    final latency = DrillLatency.instance;
    // The timing log for the acceptance criterion.
    // ignore: avoid_print
    print(
      'Drill latency (${kDebugMode ? 'debug' : 'AOT'}): '
      '${latency.count} replies, p50 ${latency.p50?.inMilliseconds} ms, '
      'p95 ${latency.p95?.inMilliseconds} ms (opponent delay 250 ms)',
    );
    // The frame log for the acceptance criterion.
    // ignore: avoid_print
    print(
      'Drill frames: $lines lines, $userMoves user moves, ${frames.count} '
      'frames; over ${frames.budget.inMicroseconds / 1000} ms: '
      '${frames.slowBuilds} builds, ${frames.slowRasters} rasters; worst '
      'build ${frames.worstBuild.inMicroseconds / 1000} ms, mean build '
      '${frames.averageBuild.inMicroseconds / 1000} ms, mean raster '
      '${frames.averageRaster.inMicroseconds / 1000} ms',
    );
    expect(lines, 20);
    expect(latency.count, greaterThan(10));
    expect(frames.count, greaterThan(100));
    if (!kDebugMode) {
      expect(latency.p95, lessThanOrEqualTo(const Duration(milliseconds: 300)));
      // Builds only: the CI runner rasterizes in software (D-71); raster
      // times are logged and checked on devices.
      expect(frames.slowBuilds / frames.count, lessThan(0.01));
    }
  });
  testWidgets('stats screen opens in < 300 ms with 20k runs', (tester) async {
    const total = 20000;
    final (dbFile, id) = await _seedRuns(total);

    await bootstrap(
      overrides: [
        databaseProvider.overrideWith((ref) {
          final db = AppDatabase(NativeDatabase.createInBackground(dbFile));
          ref.onDispose(db.close);
          return db;
        }),
      ],
    );
    final home = find.text('Big');
    final watch = Stopwatch()..start();
    while (home.evaluate().isEmpty && watch.elapsed.inSeconds < 30) {
      await tester.pump(const Duration(milliseconds: 20));
    }
    final container = ProviderScope.containerOf(tester.element(home));
    // Opening: navigation until the tiles show the run count.
    final loaded = find.text('$total');
    final open = Stopwatch()..start();
    container.read(routerProvider).go(Routes.stats(id));
    while (loaded.evaluate().isEmpty && open.elapsed.inSeconds < 30) {
      await tester.pump(const Duration(milliseconds: 5));
    }
    open.stop();
    expect(loaded, findsOneWidget);
    expect(find.byKey(const Key('accuracy-chart')), findsOneWidget);
    // The timing log for the acceptance criterion.
    // ignore: avoid_print
    print(
      'Stats screen (${kDebugMode ? 'debug' : 'AOT'}): '
      '${open.elapsedMilliseconds} ms with $total runs',
    );
    if (!kDebugMode) {
      expect(open.elapsed, lessThan(const Duration(milliseconds: 300)));
    }
  });

  testWidgets('backup of 20k runs: export < 3 s, import < 5 s', (tester) async {
    final (dbFile, _) = await _seedRuns(20000);
    BackupService service(AppDatabase db) {
      final repertoires = DriftRepertoireRepository(
        db,
        clock: const SystemClock(),
        newId: () => 'unused',
        deviceId: () async => 'dev',
      );
      final runs = DriftRunRepository(db);
      final settings = DriftSettingsRepository(db);
      final stats = StatsService(
        repertoires: repertoires,
        runs: runs,
        stats: DriftStatsRepository(db),
        settings: settings.load,
      );
      return BackupService(
        repertoires: repertoires,
        runs: runs,
        settings: settings,
        applier: MergeApplier(
          db: db,
          repertoires: repertoires,
          runs: runs,
          stats: stats,
          buildTree: (r) async => importPgn(r.pgn, Side.white).tree,
        ),
        queries: BackupQueries(db),
        deviceId: () async => 'dev',
        clock: const SystemClock(),
      );
    }

    final source = AppDatabase(NativeDatabase.createInBackground(dbFile));
    final export = Stopwatch()..start();
    final backup = await service(source).export();
    export.stop();
    await source.close();

    final target = AppDatabase(
      NativeDatabase.createInBackground(
        File(p.join(dbFile.parent.path, 'target.sqlite')),
      ),
    );
    final into = service(target);
    final import = Stopwatch()..start();
    final report = await into.import(
      await into.read(backup.bytes),
      replace: false,
      restoreSettings: false,
    );
    import.stop();
    expect(report.insertedRuns, 20000);
    expect(await DriftRunRepository(target).count(), 20000);
    await target.close();
    // The timing log for the acceptance criterion.
    // ignore: avoid_print
    print(
      'Backup (${kDebugMode ? 'debug' : 'AOT'}): '
      '${backup.bytes.length ~/ 1024} KB, export '
      '${export.elapsedMilliseconds} ms, import '
      '${import.elapsedMilliseconds} ms',
    );
    if (!kDebugMode) {
      expect(export.elapsed, lessThan(const Duration(seconds: 3)));
      expect(import.elapsed, lessThan(const Duration(seconds: 5)));
    }
  });
  testWidgets('game review opens in < 150 ms; stepping through 120 plies '
      'stays within the frame budget', (tester) async {
    final dbFile = await _seedReviewedGame(120);
    await bootstrap(
      overrides: [
        databaseProvider.overrideWith((ref) {
          final db = AppDatabase(NativeDatabase.createInBackground(dbFile));
          ref.onDispose(db.close);
          return db;
        }),
      ],
    );
    final home = find.byKey(const Key('open-games'));
    final watch = Stopwatch()..start();
    while (home.evaluate().isEmpty && watch.elapsed.inSeconds < 30) {
      await tester.pump(const Duration(milliseconds: 20));
    }
    final container = ProviderScope.containerOf(tester.element(home));
    final loaded = find.byKey(const Key('review-summary'));
    final open = Stopwatch()..start();
    container.read(routerProvider).go(Routes.gameReview('g'));
    while (loaded.evaluate().isEmpty && open.elapsed.inSeconds < 30) {
      await tester.pump(const Duration(milliseconds: 5));
    }
    open.stop();
    expect(loaded, findsOneWidget);
    // Warm-up step, then the measured walk through the game.
    await tester.tap(find.byKey(const Key('nav-forward')));
    await tester.pump(const Duration(milliseconds: 300));
    final frames = FrameStats.instance..reset();
    for (var i = 1; i < 120; i++) {
      await tester.tap(find.byKey(const Key('nav-forward')));
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pump(const Duration(milliseconds: 16));
    }
    // The timing log for the acceptance criterion.
    // ignore: avoid_print
    print(
      'Game review (${kDebugMode ? 'debug' : 'AOT'}): open '
      '${open.elapsedMilliseconds} ms; ${frames.count} frames, over '
      '${frames.budget.inMicroseconds / 1000} ms: ${frames.slowBuilds} '
      'builds; worst build ${frames.worstBuild.inMicroseconds / 1000} ms',
    );
    if (!kDebugMode) {
      expect(open.elapsed, lessThan(const Duration(milliseconds: 150)));
      expect(frames.slowBuilds, lessThanOrEqualTo(1));
    }
  });
}

/// A database file holding one fully analysed (Standard) game of [plies]
/// random legal moves, id `g`.
Future<File> _seedReviewedGame(int plies) async {
  final dir = await Directory.systemTemp.createTemp('rt_review_');
  final dbFile = File(p.join(dir.path, 'repertoire.sqlite'));
  final seed = AppDatabase(NativeDatabase(dbFile));
  final rng = math.Random(3);
  Position pos = Chess.initial;
  final ucis = <String>[];
  final sans = <String>[];
  while (ucis.length < plies) {
    final moves = [
      for (final MapEntry(key: from, value: tos) in pos.legalMoves.entries)
        for (final to in tos.squares) NormalMove(from: from, to: to),
    ];
    if (moves.isEmpty) break;
    final m = moves[rng.nextInt(moves.length)];
    final (after, san) = pos.makeSan(m);
    ucis.add(m.uci);
    sans.add(san);
    pos = after;
  }
  final games = GamesRepository(seed);
  await games.upsertGames([
    ImportedGamesCompanion.insert(
      id: 'g',
      username: 'eli',
      url: '',
      endTime: 0,
      timeClass: 'blitz',
      timeControl: '180+2',
      rated: true,
      userWhite: true,
      result: 'win',
      resultDetail: 'resigned',
      whiteName: 'Eli',
      blackName: 'opp',
      whiteRating: 1500,
      blackRating: 1500,
      ucis: ucis.join(' '),
      sans: sans.join(' '),
      pgn: '',
      fetchedAt: 0,
    ),
  ]);
  for (var ply = 0; ply <= ucis.length; ply++) {
    await games.savePosition(
      GameAnalysisCompanion.insert(
        gameId: 'g',
        profile: AnalysisProfile.standard.index,
        ply: ply,
        cp: Value(rng.nextInt(600) - 300),
        pv: Value(ply < ucis.length ? ucis[ply] : ''),
        depth: 18,
      ),
    );
  }
  await games.completeReview(
    GameReviewsCompanion.insert(
      gameId: 'g',
      profile: AnalysisProfile.standard.index,
      engine: 'sf',
      analysed: ucis.length + 1,
      total: ucis.length + 1,
      complete: true,
      updatedAt: 0,
    ),
    List<int?>.filled(ucis.length, null),
  );
  await seed.close();
  return dbFile;
}

/// A database file holding one repertoire (12 lines) with [total] runs and
/// derived stats; returns the file and the repertoire id.
Future<(File, String)> _seedRuns(int total) async {
  final dir = await Directory.systemTemp.createTemp('rt_stats_');
  final dbFile = File(p.join(dir.path, 'repertoire.sqlite'));
  final seed = AppDatabase(NativeDatabase(dbFile));
  var next = 0;
  final sync = DriftSyncStateRepository(seed, newId: () => 'dev');
  final repo = DriftRepertoireRepository(
    seed,
    clock: const SystemClock(),
    newId: () => 'id-${next++}',
    deviceId: sync.deviceId,
  );
  final pgn = generateSyntheticPgn(lines: 12, depth: 12, seed: 2);
  final id = await repo.create(
    name: 'Big',
    color: Side.white,
    pgn: pgn,
    result: importPgn(pgn, Side.white),
  );
  final lines = await repo.lineRefs(id);
  final runs = DriftRunRepository(seed);
  final start = DateTime.utc(2026);
  final batch = <RunRecord>[];
  for (var i = 0; i < total; i++) {
    final line = lines[i % lines.length];
    final ucis = line.ucis.split(' ');
    final at = start.add(Duration(minutes: 20 * i));
    final grades = [
      for (var ply = 1; ply <= ucis.length && ply <= 11; ply += 2)
        MoveGrade(
          ply: ply,
          expected: ucis[ply - 1],
          accepted: ucis[ply - 1],
          firstAttempt: (i + ply) % 7 == 0 ? 'a2a3' : ucis[ply - 1],
          result: (i + ply) % 7 == 0 ? GradeResult.wrong : GradeResult.correct,
          credit: (i + ply) % 7 == 0 ? 0 : 1,
          attempts: 1,
          hintLevel: 0,
        ),
    ];
    batch.add(
      RunRecord(
        id: 'run-$i',
        repertoireId: id,
        lineKey: line.key,
        ucis: line.ucis,
        mode: RunMode.random,
        startPly: 0,
        wrongMoveMode: WrongMoveMode.retry,
        startedAt: at.millisecondsSinceEpoch - 60000,
        finishedAt: at.millisecondsSinceEpoch,
        localDay: localDay(at, 4),
        completed: true,
        deviated: false,
        gradedCount: grades.length,
        creditSum: grades.fold(0, (a, g) => a + g.credit),
        hintCount: 0,
        deviceId: 'dev',
        grades: grades,
      ),
    );
  }
  await runs.insertIfAbsent(batch);
  await StatsService(
    repertoires: repo,
    runs: runs,
    stats: DriftStatsRepository(seed),
    settings: DriftSettingsRepository(seed).load,
  ).rebuildRepertoire(id);
  await seed.close();
  return (dbFile, id);
}
