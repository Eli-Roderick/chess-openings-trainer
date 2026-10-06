import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_harness.dart';

void main() {
  testWidgets('opens to the empty Home in dark theme', (tester) async {
    await AppHarness.pump(tester);
    expect(find.text('Repertoire Trainer'), findsOneWidget);
    expect(find.text('No repertoires yet'), findsOneWidget);
    expect(find.byKey(const Key('create-repertoire')), findsOneWidget);
    expect(find.byKey(const Key('try-demo')), findsOneWidget);
    final context = tester.element(find.byType(Scaffold).first);
    expect(Theme.of(context).brightness, Brightness.dark);
    expect(Theme.of(context).colorScheme.surface, const Color(0xFF121212));
  });
}
