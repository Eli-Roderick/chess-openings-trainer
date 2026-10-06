import 'dart:async';
import 'dart:io';

import 'package:chess_core/chess_core.dart';
import 'package:chessground/chessground.dart' show Arrow, PlayerSide;
import 'package:dartchess/dartchess.dart' show NormalMove, Side, Square;
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repertoire_trainer/core/audio/sound_service.dart';
import 'package:repertoire_trainer/core/diagnostics/deviation_timings.dart';
import 'package:repertoire_trainer/core/haptics/haptics_service.dart';
import 'package:repertoire_trainer/core/settings/app_settings.dart';
import 'package:repertoire_trainer/features/board/board_position.dart';
import 'package:repertoire_trainer/features/drill/deviation.dart';
import 'package:repertoire_trainer/features/drill/drill_controller.dart';
import 'package:repertoire_trainer/features/drill/drill_state.dart';
import 'package:repertoire_trainer/features/drill/line_picker.dart';

final class _Effects implements DrillEffects {
  final log = <String>[];

  @override
  Future<void> flash(Square square) =>
      Future<void>.delayed(const Duration(milliseconds: 300));

  @override
  void haptic(HapticKind kind) {}

  @override
  void sound(SoundType type) => log.add(type.name);
}

/// The first legal move of [fen] not in [book] (stable order).
String? _firstLegal(String fen, Set<String> book) {
  final pos = positionFromFen(fen);
  final moves = [
    for (final e in pos.legalMoves.entries)
      for (final to in e.value.squares) NormalMove(from: e.key, to: to).uci,
  ]..sort();
  return moves.where((m) => !book.contains(m)).firstOrNull;
}

/// A deviation engine in fake time.
final class _FakeEngine implements DeviationEngine {
  @override
  bool available = true;

  /// Time until candidates are in.
  Duration candidatesDelay = const Duration(milliseconds: 100);

  /// Judgement of a reply (passed, loss); best is [best] of the position.
  ({bool passed, int lossCp}) Function(String fen, String reply) verdict = (
    fen,
    reply,
  ) => (passed: true, lossCp: 0);

  /// The best move the judge reports.
  String Function(String fen) best = (fen) => _firstLegal(fen, const {})!;

  /// Positions candidates were requested for.
  final requested = <String>[];
  int cancelled = 0;

  @override
  CandidateJob candidates(String fen, {Set<String> book = const {}}) {
    requested.add(fen);
    final c = Completer<List<PvMove>>();
    final timer = Timer(candidatesDelay, () {
      final m = _firstLegal(fen, book);
      c.complete(m == null ? const [] : [(uci: m, scoreCp: 0)]);
    });
    return (
      result: c.future,
      cancel: () {
        cancelled++;
        timer.cancel();
        if (!c.isCompleted) c.complete(const []);
      },
    );
  }

  @override
  Future<DeviationJudgement?> judge(String fen, String replyUci) =>
      Future.delayed(const Duration(milliseconds: 50), () {
        final v = verdict(fen, replyUci);
        return (passed: v.passed, lossCp: v.lossCp, bestUci: best(fen));
      });

  @override
  Future<String?> bestMove(String fen) =>
      Future.delayed(const Duration(milliseconds: 50), () => best(fen));
}

final class _Drill {
  new(
    this.async,
    String pgn, {
    Side side = Side.white,
    AppSettings? settings,
    LinePicker? picker,
    int seed = 1,
    bool available = true,
    Duration candidatesDelay = const Duration(milliseconds: 100),
  }) : tree = importPgn(pgn, side).tree!,
       settings =
           settings ??
           const AppSettings(
             deviationsEnabled: true,
             deviationChancePercent: 100,
           ) {
    engine
      ..available = available
      ..candidatesDelay = candidatesDelay;
    controller = DrillController(
      tree: tree,
      repertoireId: 'rep',
      startFromBranch: false,
      picker: picker ?? const RandomPicker(),
      deps: DrillDeps(
        clock: clock,
        rng: SeededRng(seed),
        newId: () => 'run-${++ids}',
        deviceId: 'dev',
        settings: () => this.settings,
        lineStats: () async => const [],
        recentStarted: () async => const [],
        recordRun: (r) async => runs.add(r),
        check: ({required fen, required userUci, required accepted}) async =>
            const ComparableOutcome.unavailable(),
        effects: effects,
        deviations: engine,
        deviationTimings: timings,
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
  final engine = _FakeEngine();
  final timings = DeviationTimings();
  final runs = <RunRecord>[];
  int ids = 0;
  late final DrillController controller;

  DrillState get s => controller.state;

  void elapse(Duration d) {
    clock.advance(d);
    async.elapse(d);
  }

  void play(String uci) {
    final r = resolveMove(positionFromFen(s.board.fen), parseUci(uci)!)!;
    controller.onUserMove(
      uci: r.uci,
      san: r.san,
      fenAfter: r.after.fen,
      viaDrag: true,
    );
    async.flushMicrotasks();
  }

  void opponent() => elapse(const Duration(milliseconds: 250));

  /// Plays the current line by the book until the line ends or a
  /// challenge starts; returns the opponent's book moves seen (SAN; a
  /// deviation is in the challenge).
  List<String> playBook() {
    final seen = <String>[];
    for (var i = 0; i < 200; i++) {
      switch (s.phase) {
        case DrillPhase.userToMove:
          final next = s.line!.path[s.node!.ply];
          play(next.uci!);
        case DrillPhase.opponentToMove:
          opponent();
          final last = s.log.last;
          if (!last.isUser && s.challenge == null) seen.add(last.san);
        case DrillPhase.loading ||
            DrillPhase.empty ||
            DrillPhase.mistake ||
            DrillPhase.deviationReply ||
            DrillPhase.judging ||
            DrillPhase.lineComplete:
          return seen;
      }
    }
    fail('line did not end');
  }
}

const _userLeaf = '1. e4 e5 2. Nf3 Nc6 3. Bb5 *';
const _opponentLeaf = '1. e4 e5 2. Nf3 Nc6 *';
const _userFork = '1. e4 e5 2. Nf3 (2. Bc4 Bc5 3. c3) 2... Nc6 3. Bb5 *';

const _anywhere = AppSettings(
  deviationsEnabled: true,
  deviationChancePercent: 100,
  deviationTiming: DeviationTiming.anywhere,
);

void main() {
  test('end of line (default) at 100 %: every line of the demo repertoire '
      'plays exactly as written, then the challenge starts', () {
    final pgn = File('assets/demo/italian_white.pgn').readAsStringSync();
    final lines = importPgn(pgn, Side.white).tree!.lines;
    expect(lines.length, greaterThan(10));
    for (final line in lines) {
      fakeAsync((async) {
        final d = _Drill(async, pgn, picker: SingleLinePicker(line.key));
        final seen = d.playBook();
        expect(seen, [
          for (final n in line.path)
            if (!n.isUserMove) n.san!,
        ], reason: line.label);
        expect(d.s.phase, DrillPhase.deviationReply, reason: line.label);
        expect(
          d.s.challenge!.kind,
          line.path.last.isUserMove
              ? ChallengeKind.endOpponentPlays
              : ChallengeKind.endFindMove,
        );
        d.controller.dispose();
        async.flushMicrotasks();
      });
    }
  });

  test('user leaf: the opponent plays on with the deviation sound; a good '
      'reply; the run is a normal run plus the event', () {
    fakeAsync((async) {
      final d = _Drill(async, _userLeaf)..playBook();
      final leaf = d.tree.lines.single.path.last;
      expect(d.engine.requested, [leaf.fen]);
      expect(d.s.challenge!.kind, ChallengeKind.endOpponentPlays);
      expect(d.s.challenge!.deviationSan, isNotNull);
      expect(d.s.board.movable, PlayerSide.white);
      expect(d.effects.log, contains('deviation'));
      expect(d.timings.readyRate, 1.0);
      final fen = d.s.board.fen;
      final reply = _firstLegal(fen, const {})!;
      d.play(reply);
      expect(d.s.phase, DrillPhase.judging);
      d.elapse(const Duration(milliseconds: 50));
      expect(d.s.phase, DrillPhase.lineComplete);
      expect(d.s.challenge!.passed, isTrue);
      // The result stays: no countdown after a challenge.
      expect(d.s.endBar!.counting, isFalse);
      expect(d.s.playOn!.moves.length, 2);
      expect(d.s.playOn!.fen, isNot(fen));
      async.flushMicrotasks();
      final run = d.runs.single;
      expect(
        (run.completed, run.deviated, run.gradedCount, run.creditSum),
        (true, false, 3, 3.0),
      );
      final e = run.deviation!;
      expect((e.ply, e.replyUci, e.passed), (6, reply, true));
      expect(e.deviationUci, isNotNull);
    });
  });

  test('opponent leaf: the user moves directly; an inaccurate reply shows '
      'the best move and does not touch the line accuracy', () {
    fakeAsync((async) {
      final d = _Drill(async, _opponentLeaf);
      d.engine.verdict = (fen, reply) => (passed: false, lossCp: 120);
      d.playBook();
      expect(d.engine.requested, isEmpty);
      expect(d.s.challenge!.kind, ChallengeKind.endFindMove);
      expect(d.s.challenge!.deviationSan, isNull);
      final fen = d.s.board.fen;
      final best = d.engine.best(fen);
      final reply = _firstLegal(fen, {best})!;
      d
        ..play(reply)
        ..elapse(const Duration(milliseconds: 50));
      expect(d.s.challenge!.passed, isFalse);
      expect(d.s.challenge!.bestSan, isNotNull);
      // The position before the reply with the best move and the reply.
      expect(d.s.board.fen, fen);
      expect(d.s.board.shapes.whereType<Arrow>().length, 2);
      async.flushMicrotasks();
      final run = d.runs.single;
      expect((run.gradedCount, run.creditSum, run.deviated), (2, 2.0, false));
      final e = run.deviation!;
      expect(
        (e.ply, e.deviationUci, e.passed, e.lossCp),
        (4, null, false, 120),
      );
      expect(e.bestUci, best);
    });
  });

  test('candidates not ready at the line end: no challenge this run', () {
    fakeAsync((async) {
      final d = _Drill(
        async,
        _userLeaf,
        candidatesDelay: const Duration(seconds: 10),
      )..playBook();
      expect(d.s.phase, DrillPhase.lineComplete);
      expect(d.s.challenge, isNull);
      expect(d.engine.cancelled, 1);
      expect(d.timings.readyRate, 0.0);
      async.flushMicrotasks();
      expect(d.runs.single.deviation, isNull);
      // A normal end bar: the countdown runs.
      expect(d.s.endBar!.counting, isTrue);
    });
  });

  test('hint during the reply shows the best move and fails the reply', () {
    fakeAsync((async) {
      final d = _Drill(async, _userLeaf)..playBook();
      final fen = d.s.board.fen;
      d.controller.hint();
      expect(d.s.challenge!.hinted, isTrue);
      d.elapse(const Duration(milliseconds: 50));
      expect(d.s.board.shapes, isNotEmpty);
      d
        ..play(d.engine.best(fen))
        ..elapse(const Duration(milliseconds: 50));
      expect(d.s.challenge!.passed, isFalse);
      async.flushMicrotasks();
      expect(d.runs.single.deviation!.passed, isFalse);
      expect(d.effects.log, contains('hint'));
    });
  });

  test('anywhere in the line: the opponent leaves the book at the chosen '
      'ply; the run is deviated, graded moves before it count', () {
    fakeAsync((async) {
      final d = _Drill(async, _userLeaf, settings: _anywhere);
      final line = d.tree.lines.single;
      final seen = d.playBook();
      expect(d.s.phase, DrillPhase.deviationReply);
      expect(d.s.challenge!.kind, ChallengeKind.midLine);
      final ply = d.s.log.last.ply;
      expect(line.path[ply - 1].isUserMove, isFalse);
      // Book moves before the deviation only.
      expect(seen, [
        for (final n in line.path.take(ply - 1))
          if (!n.isUserMove) n.san!,
      ]);
      expect(d.s.challenge!.deviationSan, d.s.log.last.san);
      expect(d.s.log.last.san, isNot(line.path[ply - 1].san));
      d
        ..play(_firstLegal(d.s.board.fen, const {})!)
        ..elapse(const Duration(milliseconds: 50));
      expect(d.s.phase, DrillPhase.lineComplete);
      async.flushMicrotasks();
      final run = d.runs.single;
      expect((run.completed, run.deviated), (true, true));
      expect(run.deviation!.ply, ply);
      expect(run.gradedCount, ply ~/ 2);
    });
  });

  test('anywhere: candidates not ready → the book move, and no later '
      'deviation in that run', () {
    fakeAsync((async) {
      final d = _Drill(
        async,
        _userLeaf,
        settings: _anywhere,
        candidatesDelay: const Duration(seconds: 30),
      );
      final seen = d.playBook();
      expect(seen, ['e5', 'Nc6']);
      expect(d.s.phase, DrillPhase.lineComplete);
      async.flushMicrotasks();
      expect((d.runs.single.deviated, d.runs.single.deviation), (false, null));
    });
  });

  test('a branch switch recomputes the candidates for the new leaf', () {
    fakeAsync((async) {
      // The Nf3 line, then the Bc4 alternative.
      final lines = importPgn(_userFork, Side.white).tree!.lines;
      final nf3 = lines.firstWhere((l) => l.ucis.contains('g1f3'));
      final bc4 = lines.firstWhere((l) => l.ucis.contains('f1c4'));
      final e = _Drill(async, _userFork, picker: SingleLinePicker(nf3.key))
        ..play('e2e4')
        ..opponent();
      expect(e.engine.requested, [nf3.path.last.fen]);
      e.play('f1c4');
      expect(e.engine.requested, [nf3.path.last.fen, bc4.path.last.fen]);
      expect(e.engine.cancelled, 1);
      e
        ..opponent()
        ..play('c2c3')
        ..opponent();
      expect(e.s.phase, DrillPhase.deviationReply);
      expect(e.s.line!.key, bc4.key);
    });
  });

  test('0 % never deviates, 100 % always; off or no engine: never', () {
    for (final (settings, available, expected) in [
      (
        const AppSettings(deviationsEnabled: true, deviationChancePercent: 0),
        true,
        false,
      ),
      (
        const AppSettings(deviationsEnabled: true, deviationChancePercent: 100),
        true,
        true,
      ),
      (const AppSettings(deviationChancePercent: 100), true, false),
      (
        const AppSettings(deviationsEnabled: true, deviationChancePercent: 100),
        false,
        false,
      ),
    ]) {
      fakeAsync((async) {
        for (var seed = 0; seed < 5; seed++) {
          final e = _Drill(
            async,
            _userLeaf,
            settings: settings,
            seed: seed,
            available: available,
          )..playBook();
          expect(
            e.s.phase == DrillPhase.deviationReply,
            expected,
            reason: '$settings $available',
          );
          e.controller.dispose();
          async.flushMicrotasks();
        }
      });
    }
  });

  test(
    'skip line during an end-of-line challenge keeps the completed line',
    () {
      fakeAsync((async) {
        final d = _Drill(async, _userLeaf)..playBook();
        expect(d.s.phase, DrillPhase.deviationReply);
        unawaited(d.controller.skipLine());
        async.flushMicrotasks();
        expect(d.s.phase, DrillPhase.lineComplete);
        async.flushMicrotasks();
        final run = d.runs.single;
        expect((run.completed, run.deviation), (true, null));
      });
    },
  );
}
