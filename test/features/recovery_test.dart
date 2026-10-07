import 'package:chess_core/chess_core.dart';
import 'package:dartchess/dartchess.dart' show Side;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repertoire_trainer/app/router.dart';
import 'package:repertoire_trainer/app/routes.dart';
import 'package:repertoire_trainer/core/db/providers.dart';

import '../app_harness.dart';

/// Pumps with real async work (isolates, database) until [finder] matches.
Future<void> _until(AppHarness h, Finder finder) async {
  for (var i = 0; i < 200; i++) {
    await h.tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await h.tester.pump(const Duration(milliseconds: 20));
    if (finder.evaluate().isNotEmpty) return;
  }
  throw TestFailure('Timed out waiting for $finder');
}

const _v1 = '1. e4 e5 2. Nf3 *';
const _v2 = '1. e4 e5 2. Bc4 *';

void main() {
  testWidgets('version history restores a re-imported version; the trash '
      'restores a deleted repertoire', (tester) async {
    final h = await AppHarness.pump(tester, size: const Size(400, 900));
    final id = await h.create('Vienna', _v1);
    final repo = h.container.read(repertoireRepositoryProvider);
    await tester.runAsync(
      () => repo.reimport(id, pgn: _v2, result: importPgn(_v2, Side.white)),
    );

    h.container.read(routerProvider).go(Routes.recovery(id));
    await _until(h, find.text('Version history'));
    await _until(h, find.textContaining('Before a re-import'));
    await tester.tap(find.byTooltip('Show menu').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('version-restore')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-restore-version')));
    await _until(h, find.text('Restored Vienna'));
    expect((await tester.runAsync(() => repo.get(id)))!.pgn, _v1);

    await tester.runAsync(() => repo.softDelete(id));
    h.container.read(routerProvider).go(Routes.recovery());
    await _until(h, find.byKey(Key('trash-$id')));
    expect(find.textContaining('training history kept'), findsOneWidget);
    await tester.tap(find.byKey(Key('restore-$id')));
    await _until(h, find.text('Restored Vienna'));
    expect((await tester.runAsync(() => repo.get(id)))!.deleted, isFalse);
    await h.dispose();
  });
}
