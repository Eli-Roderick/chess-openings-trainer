import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../app_harness.dart';

Future<void> _question(WidgetTester tester) async {
  await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
  await tester.sendKeyEvent(LogicalKeyboardKey.slash, character: '?');
  await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('? shows the shortcut list; Ctrl+, opens Settings', (
    tester,
  ) async {
    final h = await AppHarness.pump(tester, size: const Size(1000, 800));
    await _question(tester);
    expect(find.byKey(const Key('shortcut-list')), findsOneWidget);
    expect(find.text('Hint, then show the move'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.comma);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await h.settle();
    expect(find.byKey(const Key('section-training')), findsOneWidget);
  });

  testWidgets('? is typed, not intercepted, in a text field', (tester) async {
    final h = await AppHarness.pump(tester, size: const Size(1000, 800));
    await tester.tap(find.byKey(const Key('create-repertoire')));
    await h.settle();
    await tester.tap(find.byType(TextField).first);
    await tester.pump();
    await _question(tester);
    expect(find.byKey(const Key('shortcut-list')), findsNothing);
  });
}
