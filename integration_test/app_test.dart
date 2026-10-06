// End-to-end smoke test: the real app boots to the placeholder Home.
// Run with `xvfb-run flutter test integration_test -d linux`.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
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

  testWidgets('the database opens in the app support directory', (
    tester,
  ) async {
    await app.main();
    await tester.pumpAndSettle();
    final dir = await getApplicationSupportDirectory();
    final file = File(p.join(dir.path, 'repertoire.sqlite'));
    for (var i = 0; i < 100 && !file.existsSync(); i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
    }
    expect(file.existsSync(), isTrue, reason: file.path);
  });
}
