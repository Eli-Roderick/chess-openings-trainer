import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repertoire_trainer/app/router.dart';
import 'package:repertoire_trainer/app/routes.dart';
import 'package:repertoire_trainer/core/files/file_service.dart';

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
  final texts = [
    for (final e in find.byType(Text).evaluate()) (e.widget as Text).data,
  ].whereType<String>().join(' | ');
  throw TestFailure('Timed out waiting for $finder; screen: $texts');
}

void main() {
  testWidgets('export saves a backup; importing it merges (nothing new); '
      'replace asks for confirmation; a bad file is rejected', (tester) async {
    final h = await AppHarness.pump(tester, size: const Size(400, 900));
    await h.create('Rep', '1. e4 e5 2. Nf3 *');
    h.container.read(routerProvider).go(Routes.settingsSection('sync'));
    await _until(h, find.byKey(const Key('export-backup')));

    await tester.tap(find.byKey(const Key('export-backup')));
    await _until(h, find.textContaining('Backup saved'));
    final name = h.files.savedBackups.keys.single;
    expect(name, startsWith('repertoire-trainer-backup-20261006-'));
    expect(name, endsWith('.rtbackup'));

    h.files.pickedBackup = PickedFile(
      name: name,
      bytes: h.files.savedBackups[name]!,
    );
    await tester.tap(find.byKey(const Key('import-backup')));
    await _until(h, find.byKey(const Key('import-dialog')));
    expect(find.textContaining('1 repertoire, 0 runs'), findsOneWidget);
    await tester.tap(find.byKey(const Key('start-import')));
    await _until(h, find.textContaining('Backup imported'));
    expect(
      find.text('Backup imported: 0 repertoires updated, 0 runs added.'),
      findsOneWidget,
    );

    // Replace all: confirmation with the local counts, then cancel.
    await tester.tap(find.byKey(const Key('import-backup')));
    await _until(h, find.byKey(const Key('import-dialog')));
    await tester.tap(find.byKey(const Key('mode-replace')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('start-import')));
    await _until(h, find.byKey(const Key('confirm-replace')));
    expect(
      find.textContaining('deletes 1 repertoire and 0 runs'),
      findsOneWidget,
    );
    await tester.tap(find.text('Cancel'));
    await tester.pump();

    h.files.pickedBackup = PickedFile(
      name: 'x.rtbackup',
      bytes: Uint8List.fromList([1, 2, 3]),
    );
    await tester.tap(find.byKey(const Key('import-backup')));
    await _until(h, find.text('Not a Repertoire Trainer backup.'));
  });
}
