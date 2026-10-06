// End-to-end smoke test: the real app boots to the placeholder Home.
// Run with `xvfb-run flutter test integration_test -d linux`.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:repertoire_trainer/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app boots to Home in dark theme', (tester) async {
    await app.main();
    await tester.pumpAndSettle();

    expect(find.text('Your repertoires will appear here.'), findsOneWidget);
    final context = tester.element(find.byType(Scaffold));
    expect(Theme.of(context).brightness, Brightness.dark);
  });
}
