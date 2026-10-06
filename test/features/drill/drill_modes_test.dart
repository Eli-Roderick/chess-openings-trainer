import 'dart:async';

import 'package:chess_core/chess_core.dart';
import 'package:dartchess/dartchess.dart' show Side, Square;
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repertoire_trainer/core/audio/sound_service.dart';
import 'package:repertoire_trainer/core/haptics/haptics_service.dart';
import 'package:repertoire_trainer/core/settings/app_settings.dart';
import 'package:repertoire_trainer/features/board/board_position.dart';
import 'package:repertoire_trainer/features/board/repertoire_board.dart';
import 'package:repertoire_trainer/features/drill/drill_controller.dart';
import 'package:repertoire_trainer/features/drill/drill_state.dart';
import 'package:repertoire_trainer/features/drill/line_picker.dart';

final class _Effects implements DrillEffects {
  @override
  Future<void> flash(Square square) => Future<void>.delayed(errorFlashDuration);

  @override
  void haptic(HapticKind kind) {}

  @override
  void sound(SoundType type) {}
}

/// Runs and derived stats shared by several drill sessions.
final class DrillStore {
  new(this.tree, {this.settings = const AppSettings()});

  final RepertoireTree tree;
  AppSettings settings;
  final runs = <RunRecord>[];
  final clock = FakeClock(DateTime.utc(2026, 10, 6, 12));
  int ids = 0;

  List<LineRef> get refs => [
    for (final l in tree.lines)
      LineRef(
        key: l.key,
        ucis: l.ucis,
        ordinal: l.ordinal,
        userMoveCount: l.userMoveCount,
      ),
  ];

  List<LineStats> stats() => deriveRepertoire(
    lines: refs,
    runs: runs,
    settings: settings.deriveSettings,
  );

  LineStats statsOf(String key) => stats().firstWhere((s) => s.lineKey == key);

  DrillController drill(FakeAsync async, LinePicker picker) {
    final c = DrillController(
      tree: tree,
      repertoireId: 'rep',
      picker: picker,
      startFromBranch: false,
      deps: DrillDeps(
        clock: clock,
        rng: SeededRng(7),
        newId: () => 'run-${++ids}',
        deviceId: 'dev',
        settings: () => settings,
        lineStats: () async => stats(),
        recentStarted: () async => [
          for (final r in [
            ...runs,
          ]..sort((a, b) => b.startedAt.compareTo(a.startedAt)))
            r.lineKey,
        ].take(3).toList(),
        recordRun: (r) async => runs.add(r),
        check: ({required fen, required userUci, required accepted}) async =>
            const ComparableOutcome(
              comparable: false,
              lossCp: 200,
              status: CheckStatus.ok,
            ),
        effects: _Effects(),
        reviewsToday: (_) async => 0,
      ),
    );
    unawaited(c.start());
    async.flushMicrotasks();
    return c;
  }
}

void elapse(FakeAsync async, DrillStore store, Duration d) {
  store.clock.advance(d);
  async.elapse(d);
}

/// Plays the current line to its end; [wrong] adds a wrong first attempt
/// before every user move. Returns the line key played.
String playLine(
  FakeAsync async,
  DrillStore store,
  DrillController c, {
  bool wrong = false,
}) {
  final key = c.state.line!.key;
  var guard = 0;
  while (c.state.phase != DrillPhase.lineComplete) {
    if (guard++ > 200) fail('line did not finish: ${c.state.phase}');
    if (c.state.phase != DrillPhase.userToMove) {
      elapse(async, store, const Duration(milliseconds: 100));
      continue;
    }
    final node = c.state.node!;
    final line = c.state.line!;
    final expected = line.path[node.ply];
    final position = positionFromFen(node.fen);
    if (wrong) {
      final book = {for (final ch in node.children) ch.uci};
      final bad = position.legalMoves.entries
          .expand(
            (e) => [
              for (final to in e.value.squares) '${e.key.name}${to.name}',
            ],
          )
          .map((u) => resolveMove(position, parseUci(u)!)!)
          .firstWhere((r) => !book.contains(r.uci));
      c.onUserMove(
        uci: bad.uci,
        san: bad.san,
        fenAfter: bad.after.fen,
        viaDrag: true,
      );
      elapse(async, store, errorFlashDuration);
    }
    final r = resolveMove(position, parseUci(expected.uci!)!)!;
    c.onUserMove(uci: r.uci, san: r.san, fenAfter: r.after.fen, viaDrag: true);
    async.flushMicrotasks();
  }
  // Store the run (checks resolve at once) and stop the countdown.
  elapse(async, store, const Duration(milliseconds: 10));
  c.cancelAutoAdvance();
  return key;
}

void next(FakeAsync async, DrillController c) {
  unawaited(c.nextLine());
  async.flushMicrotasks();
}

const _three =
    '1. e4 e5 2. Nf3 (2. Bc4 Bc5 3. c3) (2. d4 exd4 3. c3) 2... Nc6 3. Bb5 *';

void main() {
  group('pickers', () {
    final tree = importPgn(_three, Side.white).tree!;
    final store = DrillStore(tree);
    PickContext ctx({
      Map<String, LineStats> stats = const {},
      List<String> recent = const [],
      String today = '2026-10-06',
      int index = 0,
      int reviews = 0,
      AppSettings settings = const AppSettings(),
    }) => PickContext(
      lines: tree.lines,
      stats: stats,
      recentNewestFirst: recent,
      nowMs: 0,
      today: today,
      settings: settings,
      rng: SeededRng(1),
      sessionPickIndex: index,
      reviewsToday: reviews,
    );

    test('Weak: empty pool, then only pool lines', () {
      expect(const WeakPicker().pick(ctx()), isA<WeakPoolEmpty>());
      final weak = {
        for (final s in store.stats())
          s.lineKey: LineStats(
            lineKey: s.lineKey,
            archived: false,
            runCount: 1,
            accuracy: 0.2,
            lastPlayedAt: 0,
            weak: s.lineKey == tree.lines[1].key
                ? const WeakPoolState(inPool: true, cleanStreak: 0)
                : WeakPoolState.outside,
            srs: SrsState.initial,
          ),
      };
      for (var i = 0; i < 20; i++) {
        final pick = const WeakPicker().pick(ctx(stats: weak));
        expect((pick as PickedLine).key, tree.lines[1].key);
      }
      expect(const WeakPicker().count(ctx(stats: weak)), 1);
    });

    test('SRS: new lines in file order; quota per day; review cap', () {
      final first = const SrsPicker().pick(ctx()) as PickedLine;
      expect((first.key, first.isNew), (tree.lines.first.key, true));
      expect(const SrsPicker().count(ctx()), 3);
      // Quota 1, used today: caught up today, available again tomorrow.
      final seen = {
        tree.lines.first.key: LineStats(
          lineKey: tree.lines.first.key,
          archived: false,
          runCount: 1,
          accuracy: 1,
          lastPlayedAt: 0,
          weak: WeakPoolState.outside,
          srs: SrsState.initial.copyWith(
            phase: SrsPhase.review,
            firstSeenDay: '2026-10-06',
            dueDay: '2026-10-07',
            intervalDays: 1,
            reps: 1,
          ),
        ),
      };
      const one = AppSettings(srsNewPerDay: 1);
      final today = const SrsPicker().pick(ctx(stats: seen, settings: one));
      expect(today, isA<SrsAllCaughtUp>());
      expect((today as SrsAllCaughtUp).nextDueDay, '2026-10-07');
      final tomorrow = const SrsPicker().pick(
        ctx(stats: seen, settings: one, today: '2026-10-07'),
      );
      // Due review first (pick 1 of the session), the new one later.
      expect((tomorrow as PickedLine).key, tree.lines.first.key);
      const capped = AppSettings(srsMaxReviewsPerDay: 10);
      final limit = const SrsPicker().pick(ctx(settings: capped, reviews: 10));
      expect((limit as SrsAllCaughtUp).limitReached, isTrue);
    });

    test('Single: always the same line; unknown line has nothing', () {
      final key = tree.lines[2].key;
      for (var i = 0; i < 5; i++) {
        expect((SingleLinePicker(key).pick(ctx()) as PickedLine).key, key);
      }
      expect(
        const SingleLinePicker('nope').pick(ctx()),
        isA<NoTrainableLines>(),
      );
      expect(pickerFor(RunMode.single, lineKey: key).mode, RunMode.single);
      expect(pickerFor(RunMode.weak).mode, RunMode.weak);
    });
  });

  test('Weak mode: lines leave the pool after 3 clean runs; the session '
      'continues with the rest; then the empty-pool screen', () {
    fakeAsync((async) {
      final tree = importPgn(_three, Side.white).tree!;
      final store = DrillStore(tree);
      final a = tree.lines[0].key;
      final b = tree.lines[1].key;
      // Make A and B weak with failing single-line runs.
      for (final key in [a, b]) {
        final c = store.drill(async, SingleLinePicker(key));
        playLine(async, store, c, wrong: true);
        unawaited(c.close());
        async.flushMicrotasks();
      }
      expect(store.statsOf(a).inWeakPool, isTrue);
      expect(store.statsOf(b).inWeakPool, isTrue);
      expect(store.statsOf(tree.lines[2].key).inWeakPool, isFalse);

      final c = store.drill(async, const WeakPicker());
      expect(c.state.modeCount, 2);
      final played = <String>[];
      while (c.state.phase != DrillPhase.empty) {
        played.add(playLine(async, store, c));
        next(async, c);
        if (played.length > 10) fail('pool never emptied: $played');
      }
      expect(played.toSet(), {a, b});
      expect(played.where((k) => k == a), hasLength(3));
      expect(played.where((k) => k == b), hasLength(3));
      expect(c.state.empty, isA<WeakPoolEmpty>());
      expect(store.statsOf(a).inWeakPool, isFalse);
    });
  });

  test('SRS: a failed line returns later in the same session; then all '
      'caught up with the next due day', () {
    fakeAsync((async) {
      const pgn = '1. e4 e5 (1... c5 2. Nf3) 2. Nf3 *';
      final tree = importPgn(pgn, Side.white).tree!;
      final store = DrillStore(tree);
      final c = store.drill(async, const SrsPicker());
      expect(c.state.modeCount, 2);
      final first = playLine(async, store, c, wrong: true);
      expect(store.statsOf(first).srs.phase, SrsPhase.learning);
      next(async, c);
      final second = playLine(async, store, c);
      expect(second, isNot(first));
      next(async, c);
      // The failed line is due again today.
      final third = playLine(async, store, c);
      expect(third, first);
      expect(store.statsOf(first).srs.dueDay, '2026-10-07');
      next(async, c);
      expect(c.state.phase, DrillPhase.empty);
      final caughtUp = c.state.empty! as SrsAllCaughtUp;
      expect((caughtUp.nextDueDay, caughtUp.dueOnNextDay), ('2026-10-07', 2));
      expect(store.runs.every((r) => r.mode == RunMode.srs), isTrue);
    });
  });

  test('line summary: opens with the setting; mixed grades, accuracy '
      'before and after, weak-pool change', () {
    fakeAsync((async) {
      const pgn = '1. e4 {[%why Centre.]} e5 2. Nf3 Nc6 3. Bb5 *';
      final tree = importPgn(pgn, Side.white).tree!;
      final store = DrillStore(
        tree,
        settings: const AppSettings(showLineSummary: true),
      );
      final c = store.drill(async, const RandomPicker());
      // A wrong first move, then two correct ones.
      final node = c.state.node!;
      final position = positionFromFen(node.fen);
      final bad = resolveMove(position, parseUci('d2d4')!)!;
      c.onUserMove(uci: bad.uci, san: bad.san, fenAfter: bad.after.fen);
      elapse(async, store, errorFlashDuration);
      final good = resolveMove(position, parseUci('e2e4')!)!;
      c.onUserMove(uci: good.uci, san: good.san, fenAfter: good.after.fen);
      async.flushMicrotasks();
      playLine(async, store, c);
      expect(c.state.summaryOpen, isTrue);
      final summary = c.state.summary!;
      expect(summary.run.creditSum, 2);
      expect((summary.before!.runCount, summary.before!.accuracy), (0, null));
      expect(summary.after!.accuracy, closeTo(2 / 3, 1e-9));
      expect(summary.weakChange, isTrue);
      final first = summary.moves.first;
      expect(
        (first.grade.result, first.firstAttemptSan),
        (GradeResult.wrong, 'd4'),
      );
      expect(first.node.comment?.why, 'Centre.');
      expect(
        summary.moves.skip(1).every((m) => m.firstAttemptSan == null),
        isTrue,
      );
      // No countdown with the summary.
      elapse(async, store, const Duration(seconds: 5));
      expect(c.state.phase, DrillPhase.lineComplete);
      c.closeSummary();
      expect(c.state.summaryOpen, isFalse);
      c.openSummary();
      expect(c.state.summaryOpen, isTrue);
    });
  });

  test('empty weak pool shows the empty screen at once', () {
    fakeAsync((async) {
      final store = DrillStore(importPgn(_three, Side.white).tree!);
      final c = store.drill(async, const WeakPicker());
      expect(c.state.phase, DrillPhase.empty);
      expect(c.state.empty, isA<WeakPoolEmpty>());
      expect(c.state.modeCount, 0);
    });
  });

  test('SRS over two days: pass, next day due, fail, relearn the same day', () {
    fakeAsync((async) {
      final tree = importPgn('1. e4 e5 *', Side.white).tree!;
      final store = DrillStore(tree);
      final key = tree.lines.single.key;
      final day1 = store.drill(async, const SrsPicker());
      playLine(async, store, day1);
      expect(store.statsOf(key).srs.dueDay, '2026-10-07');
      next(async, day1);
      expect(day1.state.phase, DrillPhase.empty);
      unawaited(day1.close());
      async.flushMicrotasks();

      elapse(async, store, const Duration(days: 1));
      final day2 = store.drill(async, const SrsPicker());
      expect(day2.state.phase, DrillPhase.userToMove);
      playLine(async, store, day2, wrong: true);
      final failed = store.statsOf(key).srs;
      expect((failed.phase, failed.dueDay), (SrsPhase.learning, '2026-10-07'));
      next(async, day2);
      expect(day2.state.phase, DrillPhase.userToMove);
    });
  });
}
