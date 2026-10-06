import 'dart:io' as io;

import 'package:chess_core/chess_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:repertoire_trainer/app/router.dart';
import 'package:repertoire_trainer/app/routes.dart';
import 'package:repertoire_trainer/core/settings/app_settings.dart';
import 'package:repertoire_trainer/features/import/annotation_prompt.dart';
import 'package:repertoire_trainer/features/repertoire/detail_screen.dart';

import '../app_harness.dart';

GoRouter router(AppHarness h) => h.container.read(routerProvider);

Future<void> go(AppHarness h, String location) async {
  router(h).go(location);
  await h.settle();
}

void main() {
  group('Repertoire detail', () {
    testWidgets('shows counts and opens placeholders', (tester) async {
      final h = await AppHarness.pump(tester);
      final id = await h.create('Demo', fixture('demo_italian_white.pgn'));
      await go(h, Routes.repertoire(id));
      expect(find.text('0 of 12 lines trained'), findsOneWidget);
      expect(find.text('Not trained'), findsOneWidget);
      expect(find.text('New available today'), findsOneWidget);
      await tester.tap(find.byKey(const Key('train')));
      await h.settle();
      expect(find.text('Coming soon'), findsOneWidget);
    });

    testWidgets('rename and delete from the menu', (tester) async {
      final h = await AppHarness.pump(tester);
      final id = await h.create('Before', fixture('one_line.pgn'));
      await go(h, Routes.repertoire(id));
      await tester.tap(find.byKey(const Key('detail-menu')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('detail-rename')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('rename-field')), 'After');
      await tester.tap(find.text('Save'));
      await h.settle();
      expect(find.text('After'), findsOneWidget);
      await tester.tap(find.byKey(const Key('detail-menu')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('detail-delete')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirm-delete')));
      await h.settle();
      expect(find.text('No repertoires yet'), findsOneWidget);
      await tester.tap(find.text('Undo'));
      await h.settle();
      expect(find.text('After'), findsOneWidget);
    });

    testWidgets('validate stored PGN shows its report', (tester) async {
      final h = await AppHarness.pump(tester);
      final id = await h.create('M', fixture('malformed_tags.pgn'));
      await go(h, Routes.validate(id));
      expect(find.text('Warnings (9)'), findsOneWidget);
      expect(find.byKey(const Key('import-button')), findsNothing);
    });

    test('counts: coverage and new lines available today', () {
      const lines = [
        LineRef(key: 'a', ucis: 'x'),
        LineRef(key: 'b', ucis: 'y'),
        LineRef(key: 'c', ucis: 'z'),
        LineRef(key: 'd', ucis: 'w', userMoveCount: 0),
      ];
      LineStats s(String key, {int runs = 0, String? firstSeen}) => LineStats(
        lineKey: key,
        archived: false,
        runCount: runs,
        accuracy: null,
        lastPlayedAt: null,
        weak: WeakPoolState.outside,
        srs: firstSeen == null
            ? SrsState.initial
            : SrsState.initial.copyWith(
                phase: SrsPhase.review,
                firstSeenDay: firstSeen,
              ),
      );
      final counts = RepertoireDetailCounts.from(
        stats: [
          s('a', runs: 2, firstSeen: '2026-10-06'),
          s('b'),
          s('c'),
        ],
        lines: lines,
        settings: const AppSettings(srsNewPerDay: 2),
        today: '2026-10-06',
      );
      expect(counts.trained, 1);
      expect(counts.total, 4);
      // Quota 2, one used today; b and c are new (d has no user moves).
      expect(counts.newAvailableToday, 1);
    });
  });

  testWidgets('re-import shows the diff block', (tester) async {
    final h = await AppHarness.pump(tester);
    final id = await h.create('R', fixture('reimport_v1.pgn'));
    await go(h, Routes.reimport(id));
    expect(find.text('Colour: White (cannot change)'), findsOneWidget);
    await tester.tap(find.byKey(const Key('paste-text')));
    await tester.pump();
    await tester.enterText(
      find.byKey(const Key('paste-field')),
      fixture('reimport_v2.pgn'),
    );
    await tester.tap(find.byKey(const Key('validate-reimport')));
    await h.settle();
    String count(String key) => tester
        .widget<Text>(
          find
              .descendant(of: find.byKey(Key(key)), matching: find.byType(Text))
              .last,
        )
        .data!;
    expect(count('diff-unchanged'), '1');
    expect(count('diff-extended'), '1');
    expect(count('diff-new'), '1');
    expect(count('diff-comments'), '0');
    await tester.tap(find.byKey(const Key('diff-removed')));
    await tester.pumpAndSettle();
    expect(find.text('Re-import v1: 1.e4 c5 2.Nf3'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('import-button')));
    await tester.tap(find.byKey(const Key('import-button')));
    await h.settle();
    expect(find.text('Re-imported R'), findsOneWidget);
  });

  group('Settings', () {
    testWidgets('theme switch applies immediately', (tester) async {
      final h = await AppHarness.pump(tester);
      await go(h, Routes.settings);
      await tester.tap(find.byKey(const Key('section-appearance')));
      await h.settle();
      await tester.tap(find.byKey(const Key('theme-light')));
      await h.settle();
      final context = tester.element(find.byType(Scaffold).last);
      expect(Theme.of(context).brightness, Brightness.light);
      await tester.tap(find.byKey(const Key('theme-dark')));
      await h.settle();
      expect(
        Theme.of(tester.element(find.byType(Scaffold).last)).brightness,
        Brightness.dark,
      );
    });

    testWidgets('seven taps on the version open Diagnostics', (tester) async {
      final h = await AppHarness.pump(tester);
      await go(h, Routes.settingsSection('about'));
      expect(find.textContaining('GNU General Public License'), findsOneWidget);
      for (var i = 0; i < 7; i++) {
        await tester.tap(find.byKey(const Key('about-version')));
      }
      await h.settle();
      expect(find.text('Diagnostics'), findsOneWidget);
      expect(find.text('Startup timings'), findsOneWidget);
      expect(find.text('Frames'), findsWidgets);
      await tester.tap(find.byKey(const Key('reset-frames')));
      await tester.pump();
    });

    testWidgets('sections without settings yet say so', (tester) async {
      final h = await AppHarness.pump(tester);
      await go(h, Routes.settingsSection('sync'));
      expect(
        find.text('These settings arrive in a later version.'),
        findsOneWidget,
      );
    });
  });

  group('text scale 1.3 on a phone: no overflow', () {
    testWidgets('Home', (tester) async {
      final h = await AppHarness.pump(
        tester,
        size: const Size(360, 640),
        textScale: 1.3,
      );
      await h.create(
        'A rather long repertoire name for a small phone screen',
        fixture('demo_italian_white.pgn'),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('Home empty', (tester) async {
      await AppHarness.pump(tester, size: const Size(360, 640), textScale: 1.3);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Create and Report', (tester) async {
      final h = await AppHarness.pump(
        tester,
        size: const Size(360, 640),
        textScale: 1.3,
      );
      await go(h, Routes.newRepertoire);
      expect(tester.takeException(), isNull);
      h.pickFile('m.pgn', fixture('malformed_tags.pgn'));
      await tester.enterText(find.byKey(const Key('name-field')), 'M');
      await tester.tap(find.text('White'));
      await tester.tap(find.byKey(const Key('choose-file')));
      await h.settle();
      await tester.ensureVisible(find.byKey(const Key('validate-only')));
      await tester.tap(find.byKey(const Key('validate-only')));
      await h.settle();
      expect(find.text('Import report'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  test('the copied annotation prompt equals Prompt 1 of the plan', () {
    final plan = io.File('docs/plan/08-annotation-prompt.md')
        .readAsStringSync();
    final start = plan.indexOf('````text\n') + '````text\n'.length;
    final end = plan.indexOf('\n````', start);
    expect(annotationPromptTemplate, plan.substring(start, end));
  });
}
