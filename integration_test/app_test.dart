// End-to-end tests on the real app (real isolates, a database file).
// Run with `xvfb-run -a flutter test integration_test/app_test.dart -d linux`.
import 'dart:io';
import 'dart:typed_data';

import 'package:chess_core/chess_core.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:repertoire_trainer/app/bootstrap.dart';
import 'package:repertoire_trainer/core/db/app_database.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/core/files/file_service.dart';
import 'package:repertoire_trainer/core/files/providers.dart';
import 'package:repertoire_trainer/main.dart' as app;

/// Returns [picked] from the open dialog.
final class _PickFile implements FileService {
  new(this.picked);

  final PickedFile picked;

  @override
  Future<PickedFile?> pickPgn() async => picked;

  @override
  Future<String?> saveText({
    required String fileName,
    required String text,
  }) async => null;
}

var _dbCount = 0;

/// A fresh database file in a temporary directory.
Future<File> _tempDbFile() async {
  final dir = await Directory.systemTemp.createTemp('rt_it_');
  return File(p.join(dir.path, 'db${_dbCount++}.sqlite'));
}

Future<void> _boot(
  WidgetTester tester,
  File dbFile, {
  List<Override> extra = const [],
}) async {
  await bootstrap(
    overrides: [
      databaseProvider.overrideWith((ref) {
        final db = AppDatabase(NativeDatabase.createInBackground(dbFile));
        ref.onDispose(db.close);
        return db;
      }),
      ...extra,
    ],
  );
}

/// Pumps until [finder] matches or [timeout] passes (real time).
Future<void> _pumpUntil(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 30),
}) async {
  final watch = Stopwatch()..start();
  while (watch.elapsed < timeout) {
    await tester.pump(const Duration(milliseconds: 50));
    if (finder.evaluate().isNotEmpty) return;
  }
  throw TestFailure('Timed out waiting for $finder');
}

PickedFile _file(String name, String text) =>
    PickedFile(name: name, bytes: Uint8List.fromList(text.codeUnits));

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app boots to an empty Home in dark theme', (tester) async {
    await app.main();
    await _pumpUntil(tester, find.text('No repertoires yet'));
    final context = tester.element(find.byType(Scaffold).first);
    expect(Theme.of(context).brightness, Brightness.dark);
    final dir = await getApplicationSupportDirectory();
    final file = File(p.join(dir.path, 'repertoire.sqlite'));
    for (var i = 0; i < 100 && !file.existsSync(); i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(file.existsSync(), isTrue, reason: file.path);
  });

  testWidgets('demo install: the detail screen shows 12 lines', (tester) async {
    await _boot(tester, await _tempDbFile());
    await _pumpUntil(tester, find.byKey(const Key('try-demo')));
    await tester.tap(find.byKey(const Key('try-demo')));
    await _pumpUntil(tester, find.text('Demo: Italian (White)'));
    await tester.tap(find.text('Demo: Italian (White)'));
    await _pumpUntil(tester, find.text('0 of 12 lines trained'));
  });

  testWidgets('malformed import: warnings, import, appears on Home', (
    tester,
  ) async {
    final pgn = File('packages/chess_core/test/fixtures/malformed_tags.pgn')
        .readAsStringSync();
    await _boot(
      tester,
      await _tempDbFile(),
      extra: [
        fileServiceProvider.overrideWithValue(
          _PickFile(_file('malformed.pgn', pgn)),
        ),
      ],
    );
    await _pumpUntil(tester, find.byKey(const Key('create-repertoire')));
    await tester.tap(find.byKey(const Key('create-repertoire')));
    await _pumpUntil(tester, find.byKey(const Key('name-field')));
    await tester.enterText(find.byKey(const Key('name-field')), 'Malformed');
    await tester.tap(find.text('White'));
    await tester.tap(find.byKey(const Key('choose-file')));
    await _pumpUntil(tester, find.byKey(const Key('chosen-file')));
    await tester.ensureVisible(find.byKey(const Key('validate-and-import')));
    await tester.tap(find.byKey(const Key('validate-and-import')));
    await _pumpUntil(tester, find.text('Warnings (9)'));
    await tester.tap(find.byKey(const Key('import-button')));
    await _pumpUntil(tester, find.text('Train'));
    await tester.pageBack();
    await _pumpUntil(tester, find.byKey(const Key('repertoire-list')));
    expect(find.text('Malformed'), findsOneWidget);
  });

  testWidgets('the UI keeps pumping frames during a 5,000-line import', (
    tester,
  ) async {
    final pgn = generateSyntheticPgn(lines: 5000, depth: 16, seed: 7);
    await _boot(
      tester,
      await _tempDbFile(),
      extra: [
        fileServiceProvider.overrideWithValue(_PickFile(_file('big.pgn', pgn))),
      ],
    );
    await _pumpUntil(tester, find.byKey(const Key('create-repertoire')));
    await tester.tap(find.byKey(const Key('create-repertoire')));
    await _pumpUntil(tester, find.byKey(const Key('name-field')));
    await tester.enterText(find.byKey(const Key('name-field')), 'Big');
    await tester.tap(find.text('White'));
    await tester.tap(find.byKey(const Key('choose-file')));
    await _pumpUntil(tester, find.byKey(const Key('chosen-file')));
    await tester.ensureVisible(find.byKey(const Key('validate-only')));
    await tester.tap(find.byKey(const Key('validate-only')));

    final stage = find.byKey(const Key('import-stage'));
    await _pumpUntil(tester, stage);
    var frames = 0;
    var worst = Duration.zero;
    final watch = Stopwatch()..start();
    while (stage.evaluate().isNotEmpty &&
        watch.elapsed < const Duration(seconds: 60)) {
      final frame = Stopwatch()..start();
      await tester.pump(const Duration(milliseconds: 16));
      frame.stop();
      // The pump that builds the report after the import is not import work.
      if (stage.evaluate().isEmpty) break;
      frames++;
      if (frame.elapsed > worst) worst = frame.elapsed;
    }
    // The timing log the acceptance criterion asks for.
    // ignore: avoid_print
    print(
      'Import of 5,000 lines: ${watch.elapsedMilliseconds} ms, '
      '$frames frames, worst frame ${worst.inMilliseconds} ms',
    );
    expect(stage, findsNothing, reason: 'import did not finish');
    expect(frames, greaterThan(10));
    expect(worst, lessThan(const Duration(milliseconds: 250)));
    await _pumpUntil(tester, find.text('Import report'));
  });
}
