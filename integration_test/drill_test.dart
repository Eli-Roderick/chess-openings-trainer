// Drill flows 1-7 of docs/plan/10-testing-and-quality.md §3 on the real
// app (Linux desktop). Run with
// `xvfb-run -a flutter test integration_test/drill_test.dart -d linux`.
import 'dart:io';

import 'package:chess_core/chess_core.dart';
import 'package:chessground/chessground.dart' show PlayerSide;
import 'package:dartchess/dartchess.dart' show Side;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:repertoire_trainer/app/bootstrap.dart';
import 'package:repertoire_trainer/core/db/app_database.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/core/settings/app_settings.dart';
import 'package:repertoire_trainer/features/board/board_position.dart';
import 'package:repertoire_trainer/features/board/repertoire_board.dart';

var _n = 0;

/// Boots the app on a fresh database holding one repertoire, opens its
/// drill and returns the container, the repertoire id and its tree.
Future<(ProviderContainer, String, RepertoireTree)> _openDrill(
  WidgetTester tester, {
  required String pgn,
  Side side = Side.white,
  AppSettings Function(AppSettings)? settings,
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
  await tester.tap(find.text('Drill'));
  await _until(tester, find.byKey(const Key('train')));
  await tester.tap(find.byKey(const Key('train')));
  await _until(tester, find.byType(RepertoireBoard));
  return (container, id, tree);
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

BoardViewState _board(WidgetTester tester) =>
    tester.widget<RepertoireBoard>(find.byType(RepertoireBoard)).state;

/// Waits for the user's turn.
Future<void> _userTurn(WidgetTester tester) async {
  final watch = Stopwatch()..start();
  while (_board(tester).movable == PlayerSide.none) {
    if (watch.elapsed.inSeconds > 20) throw TestFailure('no user turn');
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
      settings: (s) => s.copyWith(startFromBranchPoint: true),
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
}
