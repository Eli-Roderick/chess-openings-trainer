import 'package:chess_core/chess_core.dart' show FakeClock;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/features/import/annotation_prompt.dart';

import '../app_harness.dart';

Future<void> tapKey(WidgetTester tester, String key) async {
  await tester.ensureVisible(find.byKey(Key(key)));
  await tester.tap(find.byKey(Key(key)));
}

void main() {
  group('Home', () {
    testWidgets('data state: cards sorted, with counts', (tester) async {
      final h = await AppHarness.pump(tester);
      await h.create('First', fixture('one_line.pgn'));
      (h.container.read(clockProvider) as FakeClock).advance(
        const Duration(seconds: 1),
      );
      await h.create('Second', fixture('demo_italian_white.pgn'));
      expect(find.byKey(const Key('repertoire-list')), findsOneWidget);
      expect(find.text('1 line'), findsOneWidget);
      expect(find.text('12 lines'), findsOneWidget);
      expect(find.text('Not trained'), findsNWidgets(2));
      // Never trained: newest first.
      final first = tester.getTopLeft(find.text('First')).dy;
      final second = tester.getTopLeft(find.text('Second')).dy;
      expect(second, lessThan(first));
      expect(find.byKey(const Key('new-repertoire')), findsOneWidget);
    });

    testWidgets('Try the demo installs and opens the detail screen', (
      tester,
    ) async {
      final h = await AppHarness.pump(tester);
      await tapKey(tester, 'try-demo');
      await h.settle();
      expect(find.text('Demo: Italian (White)'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('detail-lines')),
          matching: find.text('12'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('delete with confirmation, then undo', (tester) async {
      final h = await AppHarness.pump(tester);
      await h.create('Keep me', fixture('one_line.pgn'));
      await tester.longPress(find.text('Keep me'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('action-delete')));
      await tester.pumpAndSettle();
      expect(find.text('Delete Keep me?'), findsOneWidget);
      await tester.tap(find.byKey(const Key('confirm-delete')));
      await h.settle();
      expect(find.text('No repertoires yet'), findsOneWidget);
      expect(find.text('Deleted Keep me'), findsOneWidget);
      await tester.tap(find.text('Undo'));
      await h.settle();
      expect(find.text('Keep me'), findsOneWidget);
    });

    testWidgets('rename from the context menu', (tester) async {
      final h = await AppHarness.pump(tester);
      await h.create('Old name', fixture('one_line.pgn'));
      await tester.longPress(find.text('Old name'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('action-rename')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('rename-field')), '');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Enter a name'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('rename-field')), 'New name');
      await tester.tap(find.text('Save'));
      await h.settle();
      expect(find.text('New name'), findsOneWidget);
      expect(find.text('Old name'), findsNothing);
    });

    testWidgets('export PGN writes the stored text', (tester) async {
      final h = await AppHarness.pump(tester);
      final pgn = fixture('one_line.pgn');
      await h.create('My: rep?', pgn);
      await tester.longPress(find.text('My: rep?'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('action-export')));
      await h.settle();
      expect(h.files.saved, {'My_ rep_.pgn': pgn});
      expect(find.text('Saved /fake/My_ rep_.pgn'), findsOneWidget);
    });

    testWidgets('wide layout shows a menu button on cards', (tester) async {
      final h = await AppHarness.pump(tester, size: const Size(1000, 700));
      final id = await h.create('Wide', fixture('one_line.pgn'));
      expect(find.byKey(Key('menu-$id')), findsOneWidget);
    });
  });

  group('Create', () {
    testWidgets('validation: name, colour and source are required', (
      tester,
    ) async {
      final h = await AppHarness.pump(tester);
      await tapKey(tester, 'create-repertoire');
      await h.settle();
      await tapKey(tester, 'validate-and-import');
      await tester.pumpAndSettle();
      expect(find.text('Enter a name'), findsOneWidget);
      expect(find.byKey(const Key('colour-error')), findsOneWidget);
      expect(find.text('Choose a file or paste a PGN'), findsOneWidget);
    });

    testWidgets('warns about a duplicate name', (tester) async {
      final h = await AppHarness.pump(tester);
      await h.create('Italian', fixture('one_line.pgn'));
      await tapKey(tester, 'new-repertoire');
      await h.settle();
      await tester.enterText(find.byKey(const Key('name-field')), 'italian');
      await tester.pump();
      expect(
        find.text('A repertoire with this name already exists'),
        findsOneWidget,
      );
    });

    testWidgets('paste, validate and import, then the detail screen', (
      tester,
    ) async {
      final h = await AppHarness.pump(tester);
      await tapKey(tester, 'create-repertoire');
      await h.settle();
      await tester.enterText(find.byKey(const Key('name-field')), 'Caro');
      await tester.tap(find.text('Black'));
      await tapKey(tester, 'paste-text');
      await tester.pump();
      await tester.enterText(
        find.byKey(const Key('paste-field')),
        fixture('black_caro.pgn'),
      );
      await tapKey(tester, 'validate-and-import');
      await h.settle();
      expect(find.text('Import report'), findsOneWidget);
      expect(find.text('Errors (0)'), findsNothing);
      expect(find.text('Warnings (0)'), findsOneWidget);
      expect(find.textContaining('Processed in'), findsOneWidget);
      await tapKey(tester, 'import-button');
      await h.settle();
      expect(find.text('Caro'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('detail-lines')),
          matching: find.text('3'),
        ),
        findsOneWidget,
      );
      final summaries = await tester.runAsync(
        () => h.container.read(repertoireSummariesProvider.future),
      );
      expect(summaries!.single.name, 'Caro');
    });

    testWidgets(
      'a file with errors: report shows them and Import is disabled',
      (tester) async {
        final h = await AppHarness.pump(tester);
        await tapKey(tester, 'create-repertoire');
        await h.settle();
        h.pickFile('broken.pgn', fixture('illegal_move.pgn'));
        await tester.enterText(find.byKey(const Key('name-field')), 'Broken');
        await tester.tap(find.text('White'));
        await tapKey(tester, 'choose-file');
        await h.settle();
        expect(find.byKey(const Key('chosen-file')), findsOneWidget);
        await tapKey(tester, 'validate-and-import');
        await h.settle();
        expect(find.text('Errors (1)'), findsOneWidget);
        expect(
          find.textContaining('Illegal or ambiguous move Bxc7'),
          findsOneWidget,
        );
        expect(find.text('Warnings (2)'), findsOneWidget);
        await tester.drag(
          find.byKey(const Key('report-list')),
          const Offset(0, -2000),
        );
        await tester.pumpAndSettle();
        expect(find.text('Info (2)'), findsOneWidget);
        final button = tester.widget<FilledButton>(
          find.byKey(const Key('import-button')),
        );
        expect(button.onPressed, isNull);
        // Copy report puts the plain-text report on the clipboard.
        await tapKey(tester, 'copy-report');
        await tester.pumpAndSettle();
        expect(h.clipboard.single, contains('E-ILLEGAL'));
      },
    );

    testWidgets('warnings are grouped by code; tapping one previews the '
        'position', (tester) async {
      final h = await AppHarness.pump(tester);
      await tapKey(tester, 'create-repertoire');
      await h.settle();
      h.pickFile('m.pgn', fixture('malformed_tags.pgn'));
      await tester.enterText(find.byKey(const Key('name-field')), 'M');
      await tester.tap(find.text('White'));
      await tapKey(tester, 'choose-file');
      await h.settle();
      await tapKey(tester, 'validate-only');
      await h.settle();
      expect(find.byKey(const Key('import-button')), findsNothing);
      expect(find.byKey(const Key('group-W-BAD-SHAPE')), findsOneWidget);
      await tapKey(tester, 'group-W-MALFORMED');
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('1.e4: comment tags are malformed'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.textContaining('Position: 1.e4'), findsOneWidget);
    });

    testWidgets('copy annotation prompt needs a colour, then fills it', (
      tester,
    ) async {
      final h = await AppHarness.pump(tester);
      await tapKey(tester, 'create-repertoire');
      await h.settle();
      await tapKey(tester, 'copy-prompt');
      await tester.pumpAndSettle();
      expect(find.text('Choose a colour first'), findsOneWidget);
      await tester.tap(find.text('Black'));
      await tapKey(tester, 'copy-prompt');
      await tester.pumpAndSettle();
      expect(h.clipboard.single, annotationPrompt('BLACK'));
      expect(h.clipboard.single, contains('The student plays: BLACK'));
      expect(h.clipboard.single, isNot(contains('<<WHITE or BLACK>>')));
    });
  });
}
