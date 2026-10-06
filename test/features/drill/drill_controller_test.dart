import 'dart:async';

import 'package:chess_core/chess_core.dart';
import 'package:chessground/chessground.dart' show PlayerSide;
import 'package:dartchess/dartchess.dart' show Side, Square;
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repertoire_trainer/core/audio/sound_service.dart';
import 'package:repertoire_trainer/core/diagnostics/drill_latency.dart';
import 'package:repertoire_trainer/core/haptics/haptics_service.dart';
import 'package:repertoire_trainer/core/settings/app_settings.dart';
import 'package:repertoire_trainer/features/board/board_position.dart';
import 'package:repertoire_trainer/features/board/repertoire_board.dart';
import 'package:repertoire_trainer/features/drill/drill_controller.dart';
import 'package:repertoire_trainer/features/drill/drill_state.dart';

final class _Effects implements DrillEffects {
  final log = <String>[];

  @override
  Future<void> flash(Square square) {
    log.add('flash ${square.name}');
    return Future<void>.delayed(errorFlashDuration);
  }

  @override
  void haptic(HapticKind kind) => log.add('haptic ${kind.name}');

  @override
  void sound(SoundType type) => log.add('sound ${type.name}');
}

typedef _Check = ({
  String fen,
  String uci,
  List<String> accepted,
  Completer<ComparableOutcome> result,
});

/// A drill on a PGN with fakes, in fake time.
final class _Drill {
  new(
    this.async,
    String pgn, {
    Side side = Side.white,
    this.settings = const AppSettings(),
    bool startFromBranch = false,
  }) : tree = importPgn(pgn, side).tree! {
    controller = DrillController(
      tree: tree,
      repertoireId: 'rep',
      startFromBranch: startFromBranch,
      deps: DrillDeps(
        clock: clock,
        rng: SeededRng(1),
        newId: () => 'run-${++ids}',
        deviceId: 'dev',
        settings: () => settings,
        lineStats: () async => const [],
        recentStarted: () async => recent,
        recordRun: (r) async => runs.add(r),
        check: ({required fen, required userUci, required accepted}) {
          final c = Completer<ComparableOutcome>();
          checks.add((fen: fen, uci: userUci, accepted: accepted, result: c));
          return c.future;
        },
        effects: effects,
        latency: latency,
      ),
    );
    unawaited(controller.start());
    async.flushMicrotasks();
  }

  final FakeAsync async;
  final RepertoireTree tree;
  AppSettings settings;
  final clock = FakeClock(DateTime.utc(2026, 10, 6, 12));
  final effects = _Effects();
  final latency = DrillLatency();
  final runs = <RunRecord>[];
  final checks = <_Check>[];
  List<String> recent = <String>[];
  int ids = 0;
  late final DrillController controller;

  DrillState get s => controller.state;

  /// Advances fake time and the clock.
  void elapse(Duration d) {
    clock.advance(d);
    async.elapse(d);
  }

  /// The user plays [uci] (dragged by default).
  bool play(String uci, {bool viaDrag = true}) {
    final r = resolveMove(positionFromFen(s.board.fen), parseUci(uci)!)!;
    final taken = controller.onUserMove(
      uci: r.uci,
      san: r.san,
      fenAfter: r.after.fen,
      viaDrag: viaDrag,
    );
    async.flushMicrotasks();
    return taken;
  }

  /// Lets the opponent reply (default delay).
  void opponent() => elapse(const Duration(milliseconds: 250));
}

const _single = '1. e4 e5 2. Nf3 Nc6 3. Bb5 *';
const _endsWithOpponent = '1. e4 e5 2. Nf3 Nc6 *';
const _userFork = '1. e4 e5 2. Nf3 (2. Bc4 Bc5 3. c3) 2... Nc6 3. Bb5 *';
const _opponentFork = '1. e4 e5 (1... c5 2. Nf3 d6 3. d4) 2. Nf3 Nc6 3. Bb5 *';

void main() {
  test('a full correct line', () {
    fakeAsync((async) {
      final d = _Drill(async, _single);
      expect(d.s.phase, DrillPhase.userToMove);
      expect(d.s.board.movable, PlayerSide.white);
      expect((d.s.userMovesDone, d.s.userMovesTotal), (0, 3));
      d.play('e2e4');
      expect(d.s.phase, DrillPhase.opponentToMove);
      expect(d.s.comment?.san, 'e4');
      d.opponent();
      expect(d.s.node!.san, 'e5');
      expect(d.s.phase, DrillPhase.userToMove);
      d
        ..play('g1f3')
        ..opponent()
        ..play('f1b5');
      expect(d.s.phase, DrillPhase.lineComplete);
      expect(d.s.endBar!.graded, 3);
      async.flushMicrotasks();
      final run = d.runs.single;
      expect(run.completed, isTrue);
      expect(run.creditSum, 3);
      expect(run.gradedCount, 3);
      expect(
        [for (final g in run.grades) g.result],
        [GradeResult.correct, GradeResult.correct, GradeResult.correct],
      );
      expect(d.s.session.linesCompleted, 1);
      expect(d.effects.log, contains('sound lineComplete'));
      // Auto-advance after 1.5 s starts the next line.
      d.elapse(const Duration(milliseconds: 1500));
      expect(d.s.phase, DrillPhase.userToMove);
      expect(d.s.endBar, isNull);
      expect(d.s.node, d.tree.root);
    });
  });

  test('opponent delay counts exactly; the user move animation adds to it '
      'unless the piece was dropped', () {
    fakeAsync((async) {
      final d = _Drill(async, _single)
        ..play('e2e4')
        ..elapse(const Duration(milliseconds: 249));
      expect(d.s.node!.san, 'e4');
      d.elapse(const Duration(milliseconds: 1));
      expect(d.s.node!.san, 'e5');
      expect(d.latency.p50, const Duration(milliseconds: 250));
      d
        ..play('g1f3', viaDrag: false)
        ..elapse(const Duration(milliseconds: 449));
      expect(d.s.node!.san, 'Nf3');
      d.elapse(const Duration(milliseconds: 1));
      expect(d.s.node!.san, 'Nc6');
    });
  });

  test('wrong move in Retry mode: flash, take back, grade 0, attempts', () {
    fakeAsync((async) {
      final d = _Drill(async, _single)..play('d2d4');
      expect(d.s.phase, DrillPhase.mistake);
      expect(d.s.board.fen, contains('3P4'));
      expect(
        d.effects.log,
        containsAll(['sound error', 'haptic medium', 'flash d4']),
      );
      expect(d.checks.single.uci, 'd2d4');
      expect(d.checks.single.accepted, ['e2e4']);
      // The user cannot move during the flash.
      expect(
        d.controller.onUserMove(
          uci: 'e2e4',
          san: 'e4',
          fenAfter: d.tree.root.children.single.fen,
        ),
        isFalse,
      );
      d.elapse(errorFlashDuration);
      expect(d.s.phase, DrillPhase.userToMove);
      expect(d.s.board.fen, d.tree.root.fen);
      d.play('c2c4');
      expect(d.checks, hasLength(1), reason: 'only the first attempt');
      d
        ..elapse(errorFlashDuration)
        ..play('e2e4');
      expect(d.s.graded, 1);
      expect(d.s.creditSum, 0);
      d.checks.single.result.complete(
        const ComparableOutcome(
          comparable: false,
          lossCp: 70,
          status: CheckStatus.ok,
        ),
      );
      d
        ..opponent()
        ..play('g1f3')
        ..opponent()
        ..play('f1b5');
      async.flushMicrotasks();
      final g = d.runs.single.grades.first;
      expect(
        (g.result, g.attempts, g.firstAttempt),
        (GradeResult.wrong, 3, 'd2d4'),
      );
      expect(g.checkCp, 70);
      expect(d.runs.single.creditSum, 2);
    });
  });

  test('wrong then comparable: half credit and the banner', () {
    fakeAsync((async) {
      final d = _Drill(async, _single)..play('d2d4');
      d.checks.single.result.complete(
        const ComparableOutcome(
          comparable: true,
          lossCp: 10,
          status: CheckStatus.ok,
        ),
      );
      async.flushMicrotasks();
      expect(d.s.banner!.kind, BannerKind.comparable);
      expect(d.s.banner!.sanPrefix, isNull);
      expect(d.s.creditSum, 0.5);
      d.elapse(const Duration(seconds: 4));
      expect(d.s.banner, isNull);
    });
  });

  test('comparable result after the user moved on: grade updated, banner '
      'prefixed with the move', () {
    fakeAsync((async) {
      final d = _Drill(async, _single)
        ..play('d2d4')
        ..elapse(errorFlashDuration)
        ..play('e2e4')
        ..opponent()
        ..play('g1f3');
      d.checks.single.result.complete(
        const ComparableOutcome(
          comparable: true,
          lossCp: 5,
          status: CheckStatus.ok,
        ),
      );
      async.flushMicrotasks();
      expect(d.s.banner!.sanPrefix, '1.d4');
      expect(d.s.log.first.result, GradeResult.comparable);
      d
        ..opponent()
        ..play('f1b5');
      async.flushMicrotasks();
      expect(d.runs.single.creditSum, 2.5);
    });
  });

  test('a comparable result after a hint stays 0', () {
    fakeAsync((async) {
      final d = _Drill(async, _single)
        ..play('d2d4')
        ..elapse(errorFlashDuration)
        ..controller.hint();
      d.checks.single.result.complete(
        const ComparableOutcome(
          comparable: true,
          lossCp: 5,
          status: CheckStatus.ok,
        ),
      );
      async.flushMicrotasks();
      expect(d.s.banner, isNull);
      expect(d.s.creditSum, 0);
    });
  });

  test('hint levels: highlight, then arrow; grade 0', () {
    fakeAsync((async) {
      final d = _Drill(async, _single)..controller.hint();
      expect(d.s.hintLevel, 1);
      expect(d.s.board.highlights.keys, [Square.e2]);
      expect(d.s.board.shapes, isEmpty);
      d.controller.hint();
      expect(d.s.hintLevel, 2);
      expect(d.s.board.shapes, hasLength(1));
      d.controller.hint();
      expect(d.s.hintLevel, 2);
      d.play('e2e4');
      expect(d.s.board.highlights, isEmpty);
      expect(d.s.creditSum, 0);
      expect(d.s.graded, 1);
      d
        ..opponent()
        ..play('g1f3')
        ..opponent()
        ..play('f1b5');
      async.flushMicrotasks();
      final g = d.runs.single.grades.first;
      expect((g.result, g.hintLevel), (GradeResult.hint, 2));
      expect(d.runs.single.hintCount, 1);
    });
  });

  test('Restart mode: back to the start, graded plies keep their grades', () {
    fakeAsync((async) {
      final d =
          _Drill(
              async,
              _single,
              settings: const AppSettings(wrongMoveMode: WrongMoveMode.restart),
            )
            ..play('e2e4')
            ..opponent()
            ..play('d2d4')
            ..elapse(errorFlashDuration);
      expect(d.s.restarts, 1);
      expect(d.s.node, d.tree.root);
      expect(d.s.board.fen, d.tree.root.fen);
      expect(d.s.phase, DrillPhase.userToMove);
      // Replaying: ply 1 is not re-graded, ply 3 keeps "wrong".
      d
        ..play('e2e4')
        ..opponent()
        ..play('g1f3')
        ..opponent()
        ..play('f1b5')
        // The check of 2.d4 is still pending: the run is stored after 3 s.
        ..elapse(const Duration(seconds: 3));
      final run = d.runs.single;
      expect(run.wrongMoveMode, WrongMoveMode.restart);
      expect(
        [for (final g in run.grades) (g.ply, g.result, g.attempts)],
        [
          (1, GradeResult.correct, 1),
          (3, GradeResult.wrong, 1),
          (5, GradeResult.correct, 1),
        ],
      );
    });
  });

  test('an alternative repertoire move switches the line; the run is '
      'stored under the completed line', () {
    fakeAsync((async) {
      final d = _Drill(async, _userFork);
      final nf3Line = d.tree.lines.firstWhere((l) => l.ucis.contains('g1f3'));
      final bc4Line = d.tree.lines.firstWhere((l) => l.ucis.contains('f1c4'));
      // Whichever line was picked, play the Bc4 branch.
      d
        ..play('e2e4')
        ..opponent()
        ..play('f1c4');
      expect(d.s.line!.key, bc4Line.key);
      expect(d.s.creditSum, 2);
      d
        ..opponent()
        ..play('c2c3');
      async.flushMicrotasks();
      final run = d.runs.single;
      expect(run.lineKey, bc4Line.key);
      expect(run.ucis, bc4Line.ucis);
      expect(run.creditSum, 3);
      expect(nf3Line.key, isNot(bc4Line.key));
    });
  });

  test('a line ending with an opponent move completes after it', () {
    fakeAsync((async) {
      final d = _Drill(async, _endsWithOpponent)
        ..play('e2e4')
        ..opponent()
        ..play('g1f3');
      expect(d.s.phase, DrillPhase.opponentToMove);
      d.opponent();
      expect(d.s.node!.san, 'Nc6');
      expect(d.s.phase, DrillPhase.lineComplete);
    });
  });

  test('Black repertoire: the opponent starts', () {
    fakeAsync((async) {
      final d = _Drill(async, '1. e4 c6 2. d4 d5 *', side: Side.black);
      expect(d.s.phase, DrillPhase.opponentToMove);
      expect(d.s.board.orientation, Side.black);
      d.opponent();
      expect(d.s.node!.san, 'e4');
      expect(d.s.board.movable, PlayerSide.black);
      d
        ..play('c7c6')
        ..opponent()
        ..play('d7d5');
      async.flushMicrotasks();
      expect(d.runs.single.creditSum, 2);
    });
  });

  test('branch-point start: position at the branch, skipped moves listed', () {
    fakeAsync((async) {
      final d = _Drill(async, _opponentFork, startFromBranch: true);
      final line = d.s.line!;
      expect(d.s.startPly, line.branchPly);
      expect(line.branchPly, 1);
      expect(d.s.skippedSans, ['e4']);
      expect(d.s.node!.ply, 1);
      // Opponent to move at the branch.
      expect(d.s.phase, DrillPhase.opponentToMove);
    });
  });

  test('Skip line stores an abandoned run and starts the next line', () {
    fakeAsync((async) {
      final d = _Drill(async, _single)..play('e2e4');
      unawaited(d.controller.skipLine());
      async.flushMicrotasks();
      final run = d.runs.single;
      expect(run.completed, isFalse);
      expect(run.gradedCount, 1);
      expect(d.s.phase, DrillPhase.userToMove);
      expect(d.s.node, d.tree.root);
    });
  });

  test('closing mid-line stores an abandoned run; no opponent move after', () {
    fakeAsync((async) {
      final d = _Drill(async, _single)..play('e2e4');
      unawaited(d.controller.close());
      async.flushMicrotasks();
      expect(d.runs.single.completed, isFalse);
      final node = d.s.node;
      d.elapse(const Duration(seconds: 5));
      expect(d.s.node, node);
    });
  });

  test('engine unavailable: no banner, no credit', () {
    fakeAsync((async) {
      final d = _Drill(async, _single)..play('d2d4');
      d.checks.single.result.complete(const ComparableOutcome.unavailable());
      async.flushMicrotasks();
      expect(d.s.banner, isNull);
      d
        ..elapse(errorFlashDuration)
        ..play('e2e4')
        ..opponent()
        ..play('g1f3')
        ..opponent()
        ..play('f1b5');
      async.flushMicrotasks();
      final g = d.runs.single.grades.first;
      expect(
        (g.result, g.checkStatus),
        (GradeResult.wrong, CheckStatus.engineUnavailable),
      );
    });
  });

  test('a check still pending at the end waits 3 s, then times out', () {
    fakeAsync((async) {
      final d = _Drill(async, _single)
        ..play('d2d4')
        ..elapse(errorFlashDuration)
        ..play('e2e4')
        ..opponent()
        ..play('g1f3')
        ..opponent()
        ..play('f1b5');
      expect(d.s.phase, DrillPhase.lineComplete);
      d.elapse(const Duration(milliseconds: 2900));
      expect(d.runs, isEmpty);
      d.elapse(const Duration(milliseconds: 200));
      final g = d.runs.single.grades.first;
      expect(g.checkStatus, CheckStatus.timeout);
      // A late answer changes nothing.
      d.checks.single.result.complete(
        const ComparableOutcome(
          comparable: true,
          lossCp: 0,
          status: CheckStatus.ok,
        ),
      );
      async.flushMicrotasks();
      expect(d.runs.single.creditSum, 2);
    });
  });

  test('the board never waits on the engine', () {
    fakeAsync((async) {
      final d = _Drill(async, _single)
        ..play('d2d4')
        ..elapse(errorFlashDuration)
        ..play('e2e4')
        // The check is still open (a slow engine); the opponent moves on time.
        ..opponent();
      expect(d.s.node!.san, 'e5');
      expect(d.checks.single.result.isCompleted, isFalse);
    });
  });

  test('end bar: a tap cancels auto-advance; Next line starts it', () {
    fakeAsync((async) {
      final d = _Drill(async, _endsWithOpponent)
        ..play('e2e4')
        ..opponent()
        ..play('g1f3')
        ..opponent();
      d.controller.cancelAutoAdvance();
      expect(d.s.endBar!.counting, isFalse);
      d.elapse(const Duration(seconds: 5));
      expect(d.s.phase, DrillPhase.lineComplete);
      unawaited(d.controller.nextLine());
      async.flushMicrotasks();
      expect(d.s.phase, DrillPhase.userToMove);
    });
  });

  test('auto-advance 0 goes straight to the next line', () {
    fakeAsync((async) {
      final d =
          _Drill(
              async,
              _endsWithOpponent,
              settings: const AppSettings(autoAdvanceDelayMs: 0),
            )
            ..play('e2e4')
            ..opponent()
            ..play('g1f3')
            ..opponent();
      async.flushMicrotasks();
      expect(d.s.phase, DrillPhase.userToMove);
      expect(d.runs, hasLength(1));
    });
  });

  test('comments and arrows follow the settings', () {
    fakeAsync((async) {
      const pgn = '1. e4 {[%why Centre.] [%cal Ge2e4]} e5 *';
      final d = _Drill(async, pgn)..play('e2e4');
      expect(d.s.comment?.comment?.why, 'Centre.');
      expect(d.s.board.shapes, hasLength(1));
      final off = _Drill(
        async,
        pgn,
        settings: const AppSettings(showCommentArrows: false),
      )..play('e2e4');
      expect(off.s.board.shapes, isEmpty);
      final none = _Drill(
        async,
        pgn,
        settings: const AppSettings(showComments: false),
      )..play('e2e4');
      expect(none.s.comment, isNull);
    });
  });

  test('flip changes the orientation for the session', () {
    fakeAsync((async) {
      final d = _Drill(async, _endsWithOpponent)..controller.flip();
      expect(d.s.board.orientation, Side.black);
      d
        ..play('e2e4')
        ..opponent()
        ..play('g1f3')
        ..opponent()
        ..elapse(const Duration(milliseconds: 1500));
      expect(d.s.board.orientation, Side.black);
    });
  });
}
