import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repertoire_trainer/app/router.dart';
import 'package:repertoire_trainer/app/routes.dart';
import 'package:repertoire_trainer/core/db/providers.dart';

import '../app_harness.dart';

Future<void> _until(AppHarness h, Finder finder, {int rounds = 400}) async {
  for (var i = 0; i < rounds; i++) {
    await h.tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await h.tester.pump(const Duration(milliseconds: 20));
    if (finder.evaluate().isNotEmpty) return;
  }
  throw TestFailure('Timed out waiting for $finder');
}

void main() {
  testWidgets('Database: rows per table and the last derivation', (
    tester,
  ) async {
    final h = await AppHarness.pump(tester, size: const Size(400, 4000));
    await h.create('Rep', '1. e4 e5 2. Nf3 (2. Bc4) *');
    h.container.read(routerProvider).go(Routes.diagnostics);
    await _until(h, find.byKey(const Key('diagnostics-database')));
    await _until(h, find.text('repertoires'));
    final row = find.ancestor(
      of: find.text('lines'),
      matching: find.byType(ListTile),
    );
    expect(find.descendant(of: row, matching: find.text('2')), findsOneWidget);
    expect(find.text('Last derivation'), findsOneWidget);
  });

  testWidgets('Import benchmark: imports 1,000 lines and removes them', (
    tester,
  ) async {
    final h = await AppHarness.pump(tester, size: const Size(400, 4000));
    h.container.read(routerProvider).go(Routes.diagnostics);
    await _until(h, find.byKey(const Key('run-benchmark')));
    await tester.tap(find.byKey(const Key('run-benchmark')));
    await _until(h, find.textContaining('1000 lines:'), rounds: 3000);
    final summaries = await tester.runAsync(
      () => h.container.read(repertoireRepositoryProvider).records(),
    );
    expect(summaries, isEmpty);
  });
}
