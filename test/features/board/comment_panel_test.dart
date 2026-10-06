import 'package:chess_core/chess_core.dart';
import 'package:dartchess/dartchess.dart' show Side;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repertoire_trainer/features/board/comment_panel.dart';
import 'package:repertoire_trainer/l10n/gen/app_localizations.dart';

Future<void> pumpPanel(WidgetTester tester, Widget panel) => tester.pumpWidget(
  MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: panel),
  ),
);

void main() {
  final tree = importPgn(
    '1. e4 {[%why Takes the centre.] [%plan Develop quickly.] '
    '[%watch Do not allow ...d5 for free.] [%alt 1.d4 is also fine.]} '
    'e5 2. Nf3 Nc6 3. Bb5 *',
    Side.white,
  ).tree!;
  final e4 = tree.root.children.single;
  final bb5 = tree.lines.single.path.last;
  final e5 = e4.children.single;

  testWidgets('placeholder when nothing is selected', (tester) async {
    await pumpPanel(
      tester,
      const CommentPanel(node: null, placeholder: 'Your move'),
    );
    expect(find.text('Your move'), findsOneWidget);
  });

  testWidgets('all sections; alternatives collapsed', (tester) async {
    await pumpPanel(tester, CommentPanel(node: e4));
    expect(find.text('1.e4'), findsOneWidget);
    expect(find.textContaining('Takes the centre.'), findsOneWidget);
    expect(find.textContaining('Develop quickly.'), findsOneWidget);
    expect(find.textContaining('Do not allow ...d5'), findsOneWidget);
    expect(find.textContaining('1.d4 is also fine.'), findsNothing);
    await tester.tap(find.byKey(const Key('toggle-alternatives')));
    await tester.pump();
    expect(find.textContaining('1.d4 is also fine.'), findsOneWidget);
    expect(find.text('Hide alternatives'), findsOneWidget);
  });

  testWidgets('a move without comment says so', (tester) async {
    await pumpPanel(tester, CommentPanel(node: bb5));
    expect(find.text('3.Bb5'), findsOneWidget);
    expect(find.text('No comment for this move'), findsOneWidget);
  });

  testWidgets('black moves are numbered with dots; fades on change', (
    tester,
  ) async {
    await pumpPanel(tester, CommentPanel(node: e5));
    expect(find.text('1...e5'), findsOneWidget);
    await pumpPanel(tester, CommentPanel(node: e4));
    await tester.pump(const Duration(milliseconds: 75));
    // Both are on screen mid-fade.
    expect(find.text('1...e5'), findsOneWidget);
    expect(find.text('1.e4'), findsOneWidget);
    await tester.pump(CommentPanel.fade);
    expect(find.text('1...e5'), findsNothing);
  });

  testWidgets('long comments scroll inside the height cap', (tester) async {
    final long = importPgn(
      '1. e4 {[%why ${List.filled(200, 'word').join(' ')}]} *',
      Side.white,
    ).tree!.root.children.single;
    await pumpPanel(tester, CommentPanel(node: long, maxHeight: 120));
    expect(tester.getSize(find.byType(CommentPanel)).height, 120);
    expect(tester.takeException(), isNull);
  });
}
