import 'dart:async';

import 'package:chess_core/chess_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repertoire_trainer/app/router.dart';
import 'package:repertoire_trainer/app/routes.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/core/db/stats_queries.dart';
import 'package:repertoire_trainer/features/stats/stats_data.dart';

import '../app_harness.dart';
import '../run_fixtures.dart';

const _pgn = '1. e4 e5 2. Nf3 (2. Bc4) *';

DailyAggregate _day(String day, double credit, int graded, int runs) =>
    DailyAggregate(
      day: day,
      creditSum: credit,
      gradedSum: graded,
      runCount: runs,
    );

/// Pumps, letting database futures complete, until [finder] matches.
Future<void> _until(AppHarness h, Finder finder) async {
  for (var i = 0; i < 100; i++) {
    await h.tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 5)),
    );
    await h.tester.pump(const Duration(milliseconds: 20));
    if (finder.evaluate().isNotEmpty) return;
  }
  throw TestFailure('Timed out waiting for $finder');
}

/// Lets database futures and streams settle without pumpAndSettle (a
/// loading indicator never settles).
Future<void> _pumpData(AppHarness h) async {
  for (var i = 0; i < 10; i++) {
    await h.tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 5)),
    );
    await h.tester.pump(const Duration(milliseconds: 20));
  }
}

Future<void> _open(AppHarness h, String location, Finder ready) async {
  h.container.read(routerProvider).go(location);
  await _until(h, ready);
  await _pumpData(h);
}

/// Stores [runs] through the stats service (stats re-derived). The
/// service runs in the test zone, like the drill's; the loop lets its
/// database work complete.
Future<void> _record(AppHarness h, List<RunRecord> runs) async {
  for (final r in runs) {
    var done = false;
    unawaited(
      h.container
          .read(statsServiceProvider)
          .recordRun(r)
          .whenComplete(() => done = true),
    );
    for (var i = 0; i < 200 && !done; i++) {
      await h.tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 2)),
      );
      await h.tester.pump();
    }
    expect(done, isTrue, reason: 'run ${r.id} not stored');
  }
  await _pumpData(h);
}

Future<(String, List<LineRef>)> _repertoire(AppHarness h) async {
  final id = await h.create('Rep', _pgn);
  final refs = await h.tester.runAsync(
    () => h.container.read(repertoireRepositoryProvider).lineRefs(id),
  );
  return (id, refs!);
}

void main() {
  group('chart data', () {
    test('gaps on days without runs; 7-day pooled moving average', () {
      final daily = [_day('2026-10-01', 1, 2, 1), _day('2026-10-03', 2, 2, 3)];
      final days = chartDays(daily, '2026-10-05', ChartRange.all);
      expect(
        [for (final d in days) d.day],
        ['2026-10-01', '2026-10-02', '2026-10-03', '2026-10-04', '2026-10-05'],
      );
      expect([for (final d in days) d.accuracy], [0.5, null, 1.0, null, null]);
      expect(
        [for (final d in days) d.movingAverage],
        [0.5, 0.5, 0.75, 0.75, 0.75],
      );
      expect([for (final d in days) d.runs], [1, 0, 3, 0, 0]);
    });

    test('ranges end today; the average forgets days older than 7', () {
      final daily = [_day('2026-08-01', 1, 1, 1)];
      final d30 = chartDays(daily, '2026-10-05', ChartRange.days30);
      expect(d30.length, 30);
      expect(d30.first.day, '2026-09-06');
      expect(d30.every((d) => d.movingAverage == null), isTrue);
      final all = chartDays(daily, '2026-10-05', ChartRange.all);
      expect(all.length, 66);
      expect(all[6].movingAverage, 1.0);
      expect(all[7].movingAverage, isNull);
      expect(chartDays(const [], '2026-10-05', ChartRange.all), isEmpty);
    });
  });

  testWidgets('stats without runs', (tester) async {
    final h = await AppHarness.pump(tester);
    final (id, _) = await _repertoire(h);
    await _open(h, Routes.stats(id), find.byKey(const Key('stats-list')));
    String tile(String key) => tester
        .widget<Text>(
          find.descendant(
            of: find.byKey(Key(key)),
            matching: find.byKey(const Key('tile-value')),
          ),
        )
        .data!;
    expect(tile('tile-accuracy'), '-');
    expect(tile('tile-coverage'), '0 / 2');
    expect(tile('tile-runs'), '0');
    expect(find.text('No runs yet'), findsWidgets);
    expect(find.byKey(const Key('deviation-summary')), findsNothing);
  });

  testWidgets('populated stats: tiles, worst lines, most missed, deviation '
      'replies; line list filters', (tester) async {
    final h = await AppHarness.pump(tester, size: const Size(400, 1600));
    final (id, refs) = await _repertoire(h);
    final a = refs.firstWhere((l) => l.ucis.contains('g1f3'));
    final b = refs.firstWhere((l) => l.ucis.contains('f1c4'));
    await _record(h, [
      for (var i = 0; i < 3; i++)
        fixtureRun(
          id,
          id: 'a$i',
          key: a.key,
          ucis: a.ucis,
          day: '2026-10-0${i + 1}',
          credits: [1, if (i == 0) 0 else 1],
          at: i,
        ),
      fixtureRun(
        id,
        id: 'b0',
        key: b.key,
        ucis: b.ucis,
        day: '2026-10-06',
        credits: [1, 0],
        at: 10,
        deviation: const DeviationEvent(
          ply: 4,
          bestUci: 'f8c5',
          passed: true,
          replyUci: 'f8c5',
          lossCp: 0,
        ),
      ),
    ]);
    await _open(h, Routes.stats(id), find.byKey(const Key('stats-list')));
    expect(find.text('2 / 2'), findsOneWidget);
    expect(find.byKey(const Key('accuracy-chart')), findsOneWidget);
    // Worst first: Bc4 (50 %), then Nf3 (5 of 6).
    final worst = tester
        .widgetList<ListTile>(
          find.byWidgetPredicate(
            (w) => w is ListTile && '${w.key}'.contains('worst-'),
          ),
        )
        .map((t) => (t.trailing! as Text).data)
        .toList();
    expect(worst, ['50 %', '83 %']);
    expect(find.text('2.Nf3 (missed 1 of 3)'), findsOneWidget);
    expect(find.text('1 reply · 100 % good'), findsOneWidget);
    await tester.tap(find.byKey(const Key('show-all-lines')));
    await _until(h, find.byKey(const Key('line-list')));
    await _pumpData(h);
    expect(find.byKey(Key('line-${a.key}')), findsOneWidget);
    await tester.tap(find.byKey(const Key('filter-archived')));
    await _pumpData(h);
    expect(find.byKey(Key('line-${a.key}')), findsNothing);
  });

  testWidgets('line detail: history with marks; an archived line is '
      'read-only', (tester) async {
    final h = await AppHarness.pump(tester, size: const Size(400, 1400));
    final (id, refs) = await _repertoire(h);
    final a = refs.firstWhere((l) => l.ucis.contains('g1f3'));
    await _record(h, [
      fixtureRun(
        id,
        id: 'r1',
        key: a.key,
        ucis: a.ucis,
        day: '2026-10-05',
        credits: [1, 0],
        at: 1,
      ),
      fixtureRun(
        id,
        id: 'r2',
        key: 'old',
        ucis: 'd2d4 d7d5',
        day: '2026-10-05',
        credits: [1],
        at: 2,
      ),
    ]);
    await _open(
      h,
      Routes.lineStats(id, a.key),
      find.byKey(const Key('run-marks')),
    );
    expect(find.text('✓ ✗'), findsOneWidget);
    expect(find.text('missed 1 of 1'), findsOneWidget);
    expect(find.byKey(const Key('drill-this-line')), findsOneWidget);
    expect(find.byKey(const Key('archived-chip')), findsNothing);
    await _open(
      h,
      Routes.lineStats(id, 'old'),
      find.byKey(const Key('run-marks')),
    );
    expect(find.text('Not in current PGN'), findsOneWidget);
    expect(find.text('1.d4 d5'), findsWidgets);
    expect(find.byKey(const Key('drill-this-line')), findsNothing);
    expect(find.text('✓'), findsOneWidget);
  });

  testWidgets('Home streak card: hidden before any run, then live; the day '
      'starts at 04:00', (tester) async {
    final h = await AppHarness.pump(tester);
    final (id, refs) = await _repertoire(h);
    await _open(h, Routes.home, find.byKey(const Key('repertoire-list')));
    expect(find.byKey(const Key('streak-card')), findsNothing);
    final a = refs.first;
    // Yesterday only: alive, not done today.
    await _record(h, [
      fixtureRun(
        id,
        id: 'y',
        key: a.key,
        ucis: a.ucis,
        day: '2026-10-05',
        credits: [1],
        at: 1,
      ),
    ]);
    expect(find.text('1-day streak'), findsOneWidget);
    expect(find.text('Train one line to keep your streak'), findsOneWidget);
    await _record(h, [
      fixtureRun(
        id,
        id: 't',
        key: a.key,
        ucis: a.ucis,
        day: '2026-10-06',
        credits: [1],
        at: 2,
      ),
    ]);
    expect(find.text('2-day streak'), findsOneWidget);
    expect(find.text('Done today'), findsOneWidget);
    expect(find.text('Best: 2'), findsOneWidget);
    // 03:30 the next night still belongs to 2026-10-06.
    (h.container.read(clockProvider) as FakeClock).current = DateTime(
      2026,
      10,
      7,
      3,
      30,
    );
    h.container.invalidate(todayProvider);
    await _pumpData(h);
    expect(find.text('Done today'), findsOneWidget);
    (h.container.read(clockProvider) as FakeClock).current = DateTime(
      2026,
      10,
      7,
      4,
      30,
    );
    h.container.invalidate(todayProvider);
    await _pumpData(h);
    expect(find.text('2-day streak'), findsOneWidget);
    expect(find.text('Train one line to keep your streak'), findsOneWidget);
  });
}
