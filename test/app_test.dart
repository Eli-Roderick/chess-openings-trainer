import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repertoire_trainer/app/app.dart';

void main() {
  testWidgets('opens to the placeholder Home in dark theme', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: RepertoireTrainerApp()));
    await tester.pumpAndSettle();

    expect(find.text('Repertoire Trainer'), findsOneWidget);
    expect(find.text('Your repertoires will appear here.'), findsOneWidget);
    final context = tester.element(find.byType(Scaffold));
    expect(Theme.of(context).brightness, Brightness.dark);
  });
}
