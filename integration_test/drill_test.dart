// Drill flows 1-7 of docs/plan/10-testing-and-quality.md §3 on the real
// app (Linux desktop). Run with
// `xvfb-run -a flutter test integration_test/drill_test.dart -d linux`.
import 'dart:io';

import 'package:chess_core/chess_core.dart';
import 'package:chessground/chessground.dart' show PlayerSide;
import 'package:dartchess/dartchess.dart' show NormalMove, Side;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:repertoire_trainer/app/bootstrap.dart';
import 'package:repertoire_trainer/app/router.dart';
import 'package:repertoire_trainer/app/routes.dart';
import 'package:repertoire_trainer/core/db/app_database.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/core/diagnostics/deviation_timings.dart';
import 'package:repertoire_trainer/core/settings/app_settings.dart';
import 'package:repertoire_trainer/features/board/board_position.dart';
import 'package:repertoire_trainer/features/board/repertoire_board.dart';
import 'package:repertoire_trainer/features/play/play_on_screen.dart';

var _n = 0;

/// Boots the app on a fresh database holding one repertoire, opens its
/// drill and returns the container, the repertoire id and its tree.
Future<(ProviderContainer, String, RepertoireTree)> _openDrill(
  WidgetTester tester, {
  required String pgn,
  Side side = Side.white,
  AppSettings Function(AppSettings)? settings,
  FakeClock? clock,
  bool openTrain = true,
}) async {
  final dir = await Directory.systemTemp.createTemp('rt_drill_');
  final file = File(p.join(dir.path, 'db${_n++}.sqlite'));
  await bootstrap(
    overrides: [
      databaseProvider.overrideWith((ref) {
        final db = AppDatabase(NativeDatabase.createInBackground(file));
        ref.onDispose(db.close);
        return db;
      }),
      if (clock != null) clockProvider.overrideWithValue(clock),
    ],
  );
  await _until(tester, find.byKey(const Key('create-repertoire')));
  final container = ProviderScope.containerOf(
    tester.element(find.byKey(const Key('create-repertoire'))),
  );
  if (settings != null) {
    await container.read(settingsRepositoryProvider).update(settings);
  }
  final id = await container
      .read(repertoireRepositoryProvider)
      .create(
        name: 'Drill',
        color: side,
        pgn: pgn,
        result: importPgn(pgn, side),
      );
  final tree = await container.read(repertoireRepositoryProvider).loadTree(id);
  await _until(tester, find.text('Drill'));
  if (openTrain) {
    container.read(routerProvider).go(Routes.train(id));
    await _until(tester, find.byType(RepertoireBoard));
  }
  return (container, id, tree);
}

/// Opens the drill of [id] in [mode] (single: [line]).
Future<void> _train(
  ProviderContainer c,
  WidgetTester tester,
  String id, {
  required String mode,
  String? line,
}) async {
  c.read(routerProvider).go(Routes.train(id, mode: mode, line: line));
  await tester.pump(const Duration(milliseconds: 500));
  await _until(
    tester,
    find.byWidgetPredicate(
      (w) => w is RepertoireBoard || w.key == const Key('empty-text'),
    ),
  );
}

/// Plays the line on the board to its end, with a wrong first attempt
/// at every user move when [wrong]; stops the countdown and waits for the
/// run to be stored.
Future<String> _finishLine(
  ProviderContainer c,
  WidgetTester tester,
  RepertoireTree tree, {
  bool wrong = false,
}) async {
  String? lineKey;
  // The previous line's end bar can still be up for a moment.
  final gone = Stopwatch()..start();
  while (find.byKey(const Key('end-bar')).evaluate().isNotEmpty &&
      gone.elapsed.inSeconds < 10) {
    await tester.pump(const Duration(milliseconds: 50));
  }
  while (find.byKey(const Key('end-bar')).evaluate().isEmpty) {
    await _userTurn(tester);
    if (find.byKey(const Key('end-bar')).evaluate().isNotEmpty) break;
    final node = _nodeAt(tree, _board(tester).fen);
    if (wrong) {
      await _play(c, tester, _wrongMove(tree, node.fen));
      await tester.pump(const Duration(milliseconds: 400));
      await _userTurn(tester);
    }
    final next = node.children.firstWhere((ch) => ch.isUserMove);
    lineKey ??= tree.lines.firstWhere((l) => l.path.contains(next)).key;
    await _play(c, tester, next.uci!);
    await tester.pump(const Duration(milliseconds: 100));
  }
  await tester.tap(find.byKey(const Key('end-accuracy')));
  // Stored once pending checks resolve (engine checks: up to 3 s).
  await tester.pump(const Duration(seconds: 4));
  return lineKey!;
}

Future<void> _until(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 20),
}) async {
  final watch = Stopwatch()..start();
  while (watch.elapsed < timeout) {
    await tester.pump(const Duration(milliseconds: 50));
    if (finder.evaluate().isNotEmpty) return;
  }
  throw TestFailure('Timed out waiting for $finder');
}

Future<void> _untilGone(WidgetTester tester, Finder finder) async {
  final watch = Stopwatch()..start();
  while (watch.elapsed < const Duration(seconds: 20)) {
    await tester.pump(const Duration(milliseconds: 50));
    if (finder.evaluate().isEmpty) return;
  }
  throw TestFailure('Still present: $finder');
}

BoardViewState _board(WidgetTester tester) =>
    tester.widget<RepertoireBoard>(find.byType(RepertoireBoard)).state;

/// Waits for the user's turn, or the end bar when the line ends on the
/// opponent's move.
Future<void> _userTurn(WidgetTester tester) async {
  final watch = Stopwatch()..start();
  bool waiting() =>
      find.byKey(const Key('end-bar')).evaluate().isEmpty &&
      (find.byType(RepertoireBoard).evaluate().isEmpty ||
          _board(tester).movable == PlayerSide.none);
  while (waiting()) {
    if (watch.elapsed.inSeconds > 20) {
      final texts = [
        for (final e in find.byType(Text).evaluate())
          (e.widget as Text).data ?? '',
      ].where((t) => t.isNotEmpty).take(20).join(' | ');
      throw TestFailure('no user turn; screen: $texts');
    }
    await tester.pump(const Duration(milliseconds: 20));
  }
}

/// The tree node for the board's position.
TreeNode _nodeAt(RepertoireTree tree, String fen) =>
    tree.nodes.firstWhere((n) => n.fen == fen);

Future<void> _play(ProviderContainer c, WidgetTester tester, String uci) async {
  expect(c.read(activeBoardProvider)!.debugPlayUserMove(uci), isTrue);
  await tester.pump();
}

/// Plays repertoire moves until the end bar shows.
Future<void> _playLine(
  ProviderContainer c,
  WidgetTester tester,
  RepertoireTree tree, {
  int pick = 0,
}) async {
  while (find.byKey(const Key('end-bar')).evaluate().isEmpty) {
    await _userTurn(tester);
    if (find.byKey(const Key('end-bar')).evaluate().isNotEmpty) break;
    final node = _nodeAt(tree, _board(tester).fen);
    final moves = [
      for (final child in node.children)
        if (child.isUserMove) child,
    ];
    await _play(c, tester, moves[pick.clamp(0, moves.length - 1)].uci!);
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// A legal move that is not in the repertoire at the board's position.
String _wrongMove(RepertoireTree tree, String fen) {
  final node = _nodeAt(tree, fen);
  final book = {for (final c in node.children) c.uci};
  final position = positionFromFen(fen);
  for (final entry in position.legalMoves.entries) {
    for (final to in entry.value.squares) {
      final uci = '${entry.key.name}${to.name}';
      final r = resolveMove(position, parseUci(uci)!);
      if (r != null && !book.contains(r.uci)) return r.uci;
    }
  }
  throw StateError('no wrong move');
}

String _text(WidgetTester tester, Key key) =>
    tester.widget<Text>(find.byKey(key)).data!;

const _italian = '1. e4 e5 2. Nf3 Nc6 3. Bc4 Bc5 4. c3 *';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('1. demo drill: a full correct line, end bar, auto-advance, '
      '100 % for that line', (tester) async {
    final pgn = File('packages/chess_core/test/fixtures/demo_italian_white.pgn')
        .readAsStringSync();
    final (c, id, tree) = await _openDrill(tester, pgn: pgn);
    await _playLine(c, tester, tree);
    expect(_text(tester, const Key('end-accuracy')), endsWith('100 %'));
    await _until(tester, find.text('Your move'));
    expect(find.byKey(const Key('end-bar')), findsNothing);
    final stats = await c.read(statsRepositoryProvider).lineStats(id);
    final trained = stats.where((s) => s.runCount > 0).toList();
    expect(trained, hasLength(1));
    expect(trained.single.accuracy, 1.0);
  });

  testWidgets('2. Retry mode: a wrong move goes back, retry, 0 for the ply', (
    tester,
  ) async {
    final (c, _, tree) = await _openDrill(tester, pgn: _italian);
    await _userTurn(tester);
    final start = _board(tester).fen;
    await _play(c, tester, _wrongMove(tree, start));
    expect(_board(tester).fen, isNot(start));
    await _until(tester, find.text('Your move'));
    await _userTurn(tester);
    expect(_board(tester).fen, start);
    await _play(c, tester, 'e2e4');
    expect(_text(tester, const Key('run-accuracy')), '0/1 · 0 %');
  });

  testWidgets('3. Restart mode: back to the start; graded plies keep their '
      'grade', (tester) async {
    final (c, id, tree) = await _openDrill(
      tester,
      pgn: _italian,
      settings: (s) => s.copyWith(wrongMoveMode: WrongMoveMode.restart),
    );
    await _userTurn(tester);
    await _play(c, tester, 'e2e4');
    await _userTurn(tester);
    await _play(c, tester, _wrongMove(tree, _board(tester).fen));
    await tester.pump(const Duration(milliseconds: 400));
    await _userTurn(tester);
    expect(_board(tester).fen, tree.root.fen);
    await _playLine(c, tester, tree);
    await tester.pump(const Duration(seconds: 4));
    final runs = await c.read(runRepositoryProvider).runsForRepertoire(id);
    final grades = runs.single.grades;
    expect([for (final g in grades) (g.ply, g.result, g.attempts)].take(2), [
      (1, GradeResult.correct, 1),
      (3, GradeResult.wrong, 1),
    ]);
  });

  testWidgets('4. comparable move (real engine): banner, half credit stored', (
    tester,
  ) async {
    final (c, id, tree) = await _openDrill(
      tester,
      pgn: _italian,
      // A wide threshold makes 1.d4 (a few centipawns from 1.e4)
      // comparable with any search depth.
      settings: (s) => s.copyWith(comparableThresholdCp: 100),
    );
    await _userTurn(tester);
    await _play(c, tester, 'd2d4');
    await _until(
      tester,
      find.text(
        'That is not the move in your repertoire, but it is a comparable move.',
      ),
      timeout: const Duration(seconds: 15),
    );
    await _userTurn(tester);
    await _playLine(c, tester, tree);
    await tester.pump(const Duration(seconds: 1));
    final runs = await c.read(runRepositoryProvider).runsForRepertoire(id);
    final g = runs.single.grades.first;
    expect((g.result, g.credit), (GradeResult.comparable, 0.5));
  });

  testWidgets('5. hints: highlight, then arrow; grade 0', (tester) async {
    final (c, _, _) = await _openDrill(tester, pgn: _italian);
    await _userTurn(tester);
    await tester.tap(find.byKey(const Key('hint')));
    await tester.pump();
    expect(_board(tester).highlights, isNotEmpty);
    await tester.tap(find.byKey(const Key('hint')));
    await tester.pump();
    expect(_board(tester).shapes, hasLength(1));
    await _play(c, tester, 'e2e4');
    expect(_text(tester, const Key('run-accuracy')), '0/1 · 0 %');
  });

  testWidgets('6. branch-point start: the position at the branch, chip', (
    tester,
  ) async {
    const pgn = '1. e4 e5 (1... c5 2. Nf3 d6 3. d4) 2. Nf3 Nc6 3. Bb5 *';
    final (_, _, tree) = await _openDrill(
      tester,
      pgn: pgn,
      // A long opponent delay: the board is read before the opponent moves.
      settings: (s) =>
          s.copyWith(startFromBranchPoint: true, opponentMoveDelayMs: 1500),
    );
    await _until(tester, find.byKey(const Key('skipped-chip')));
    expect(_board(tester).fen, tree.root.children.single.fen);
  });

  testWidgets('7. alternative repertoire move (Black): the line switches and '
      'the run is stored under the completed line', (tester) async {
    final pgn = File('packages/chess_core/test/fixtures/black_caro.pgn')
        .readAsStringSync();
    final (c, id, tree) = await _openDrill(tester, pgn: pgn, side: Side.black);
    // Always answer 3.e5 with 3...c5, whichever line was picked.
    await _playLine(c, tester, tree, pick: 1);
    await tester.pump(const Duration(seconds: 1));
    final runs = await c.read(runRepositoryProvider).runsForRepertoire(id);
    final run = runs.single;
    final line = tree.lineByKey(run.lineKey)!;
    expect(run.ucis, line.ucis);
    expect(run.completed, isTrue);
    expect(run.creditSum, run.gradedCount.toDouble());
  });

  testWidgets('8. weak pool: a missed line enters it, Weak mode picks only '
      'it, three clean runs remove it', (tester) async {
    const pgn = '1. e4 e5 (1... c5 2. Nf3) 2. Nf3 *';
    final (c, id, tree) = await _openDrill(tester, pgn: pgn, openTrain: false);
    final weak = tree.lines.first.key;
    await _train(c, tester, id, mode: 'single', line: weak);
    await _finishLine(c, tester, tree, wrong: true);
    Future<LineStats> stats(String key) async =>
        (await c.read(statsRepositoryProvider).lineStats(id))
            .firstWhere((s) => s.lineKey == key);
    expect((await stats(weak)).inWeakPool, isTrue);
    await _train(c, tester, id, mode: 'weak');
    for (var i = 0; i < 3; i++) {
      expect(await _finishLine(c, tester, tree), weak);
      if (i < 2) await tester.tap(find.byKey(const Key('next-line')));
    }
    expect((await stats(weak)).inWeakPool, isFalse);
    await tester.tap(find.byKey(const Key('next-line')));
    await _until(tester, find.text('No weak lines. Nice.'));
  });

  testWidgets('9. SRS: new line passed -> due tomorrow; next day due; a '
      'failure relearns the same day', (tester) async {
    final clock = FakeClock(DateTime(2026, 10, 6, 12));
    final (c, id, tree) = await _openDrill(
      tester,
      pgn: '1. e4 e5 *',
      clock: clock,
      openTrain: false,
    );
    final key = tree.lines.single.key;
    Future<SrsState> srs() async =>
        (await c.read(statsRepositoryProvider).lineStats(id)).single.srs;
    await _train(c, tester, id, mode: 'srs');
    await _finishLine(c, tester, tree);
    expect((await srs()).dueDay, '2026-10-07');
    await tester.tap(find.byKey(const Key('next-line')));
    await _until(tester, find.textContaining('All caught up'));

    // The next day, a new session.
    clock.advance(const Duration(days: 1));
    c.read(routerProvider).go(Routes.home);
    // Let the old drill leave the tree first: re-adding the same location
    // while its page is still animating out keeps the old screen.
    await _until(tester, find.byKey(const Key('repertoire-list')));
    await _untilGone(tester, find.byKey(const Key('empty-text')));
    await _train(c, tester, id, mode: 'srs');
    expect(await _finishLine(c, tester, tree, wrong: true), key);
    // Runs replay in finish order: keep the fixed clock from tying them.
    clock.advance(const Duration(minutes: 1));
    final failed = await srs();
    expect(
      (failed.phase, failed.dueDay, failed.lapses),
      (SrsPhase.learning, '2026-10-07', 1),
    );
    // Relearn in the same session, the same day.
    await tester.tap(find.byKey(const Key('next-line')));
    await _finishLine(c, tester, tree);
    expect((await srs()).dueDay, '2026-10-08');
  });
  testWidgets('14. deviation (real engine, 100 %): the line plays from the '
      'book, then the opponent goes off-book; the reply is judged; Play on '
      'opens; the run is a normal run', (tester) async {
    const pgn = '1. e4 e5 2. Nf3 *';
    final (c, id, tree) = await _openDrill(
      tester,
      pgn: pgn,
      openTrain: false,
      settings: (s) =>
          s.copyWith(deviationsEnabled: true, deviationChancePercent: 100),
    );
    final timings = DeviationTimings.instance..reset();
    await _train(c, tester, id, mode: 'random');
    // The candidates are prefetched at line start (05 §6); a user thinks
    // longer than this test plays, so let the first search finish.
    await _until(
      tester,
      find.byWidgetPredicate((_) => timings.jobCount > 0),
      timeout: const Duration(seconds: 30),
    );
    final line = tree.lines.single;
    await _userTurn(tester);
    await _play(c, tester, 'e2e4');
    await _userTurn(tester);
    expect(_board(tester).fen, line.path[1].fen);
    await _play(c, tester, 'g1f3');
    await _until(tester, find.textContaining('The opponent plays on'));
    expect(timings.readyRate, 1.0);
    // Off-book: the position is not in the repertoire.
    final fen = _board(tester).fen;
    expect(tree.nodes.where((n) => n.fen == fen), isEmpty);
    await _userTurn(tester);
    final pos = positionFromFen(fen);
    final reply = [
      for (final e in pos.legalMoves.entries)
        for (final to in e.value.squares) NormalMove(from: e.key, to: to).uci,
    ]..sort();
    await _play(c, tester, reply.first);
    await _until(
      tester,
      find.byWidgetPredicate(
        (w) =>
            w is Text &&
            w.key == const Key('challenge-text') &&
            (w.data == 'Good reply' || (w.data ?? '').startsWith('Inaccurate')),
      ),
    );
    await _until(tester, find.byKey(const Key('play-on')));
    await tester.pump(const Duration(seconds: 1));
    final run = (await c.read(runRepositoryProvider).runsForRepertoire(id))
        .single;
    expect(
      (run.completed, run.deviated, run.gradedCount, run.creditSum),
      (true, false, 2, 2.0),
    );
    expect(run.deviation!.ply, 4);
    expect(run.deviation!.replyUci, reply.first);
    final stats = (await c.read(statsRepositoryProvider).lineStats(id)).single;
    expect(stats.accuracy, 1.0);
    // Play on from the position after the reply; back to training goes on.
    await tester.tap(find.byKey(const Key('play-on')));
    await _until(tester, find.byType(PlayOnScreen));
    await _until(tester, find.text('Your move'));
    await tester.tap(find.byKey(const Key('back-to-training')));
    await _untilGone(tester, find.byType(PlayOnScreen));
    await _until(tester, find.byType(RepertoireBoard));
  });
}
