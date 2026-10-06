// End-to-end tests on the real app (real isolates, a database file).
// Run with `xvfb-run -a flutter test integration_test/app_test.dart -d linux`.
import 'dart:io';
import 'dart:typed_data';

import 'package:chess_core/chess_core.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderScope;
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:repertoire_trainer/app/bootstrap.dart';
import 'package:repertoire_trainer/app/router.dart';
import 'package:repertoire_trainer/app/routes.dart';
import 'package:repertoire_trainer/core/db/app_database.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/core/engine/engine_providers.dart';
import 'package:repertoire_trainer/core/files/file_service.dart';
import 'package:repertoire_trainer/core/files/providers.dart';
import 'package:repertoire_trainer/main.dart' as app;
import 'package:uci_engine/uci_engine.dart';

/// Returns [picked] from the open dialog; keeps saved backups and hands
/// them back when a backup is picked.
final class _PickFile implements FileService {
  new(this.picked);

  final PickedFile picked;
  final backups = <String, Uint8List>{};

  @override
  Future<PickedFile?> pickPgn() async => picked;

  @override
  Future<String?> saveText({
    required String fileName,
    required String text,
  }) async => null;

  @override
  Future<PickedFile?> pickBackup() async => backups.isEmpty
      ? null
      : PickedFile(name: backups.keys.last, bytes: backups.values.last);

  @override
  Future<String?> saveBackup({
    required String fileName,
    required Uint8List bytes,
  }) async {
    backups[fileName] = bytes;
    return '/fake/$fileName';
  }
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

  testWidgets('Browse analysis with the real engine; leaving stops it', (
    tester,
  ) async {
    final lines = <(DateTime, String)>[];
    await _boot(
      tester,
      await _tempDbFile(),
      extra: [
        transportStarterProvider.overrideWithValue(
          (path) async => _RecordingTransport(
            await ProcessTransport.start(path),
            (l) => lines.add((DateTime.now(), l)),
          ),
        ),
      ],
    );
    await _pumpUntil(tester, find.byKey(const Key('try-demo')));
    await tester.tap(find.byKey(const Key('try-demo')));
    await _pumpUntil(tester, find.text('Demo: Italian (White)'));
    await tester.tap(find.text('Demo: Italian (White)'));
    await _pumpUntil(tester, find.byKey(const Key('browse')));
    await tester.tap(find.byKey(const Key('browse')));
    await _pumpUntil(tester, find.byKey(const Key('analysis-toggle')));
    await tester.tap(find.byKey(const Key('analysis-toggle')));
    await _pumpUntil(tester, find.byKey(const Key('pv-0')));
    String depth() =>
        tester.widget<Text>(find.byKey(const Key('analysis-depth'))).data!;
    final first = depth();
    await _pumpUntil(
      tester,
      find.byWidgetPredicate(
        (w) =>
            w.key == const Key('analysis-depth') &&
            w is Text &&
            w.data != first,
      ),
    );
    expect(find.textContaining(RegExp(r'^[+-]\d\.\d\d$')), findsWidgets);

    // The app bar's back button (Browse's nav bar has a "Back" too).
    await tester.tap(find.byType(BackButton));
    await _pumpUntil(tester, find.byKey(const Key('detail-menu')));
    final left = DateTime.now();
    await tester.pump(const Duration(milliseconds: 1200));
    final late = [
      for (final (t, l) in lines)
        if (t.isAfter(left.add(const Duration(milliseconds: 200))) &&
            l.startsWith('info'))
          l,
    ];
    expect(late, isEmpty);
  });

  testWidgets('15. backup round trip: export, wipe, import (merge), '
      'identical repertoires, runs and stats', (tester) async {
    final files = _PickFile(_file('x.pgn', ''));
    await _boot(
      tester,
      await _tempDbFile(),
      extra: [fileServiceProvider.overrideWithValue(files)],
    );
    await _pumpUntil(tester, find.byKey(const Key('try-demo')));
    await tester.tap(find.byKey(const Key('try-demo')));
    await _pumpUntil(tester, find.text('Demo: Italian (White)'));
    final c = ProviderScope.containerOf(
      tester.element(find.text('Demo: Italian (White)')),
    );
    final repertoires = c.read(repertoireRepositoryProvider);
    final id = (await repertoires.records()).single.id;
    final lines = await repertoires.lineRefs(id);
    // Some history: two runs per line, one with a miss.
    var n = 0;
    for (final l in lines) {
      final ucis = l.ucis.split(' ');
      for (final miss in [true, false]) {
        n++;
        final grades = [
          for (var ply = 1; ply <= ucis.length; ply += 2)
            MoveGrade(
              ply: ply,
              expected: ucis[ply - 1],
              accepted: ucis[ply - 1],
              firstAttempt: miss && ply == 3 ? 'a2a3' : ucis[ply - 1],
              result: miss && ply == 3
                  ? GradeResult.wrong
                  : GradeResult.correct,
              credit: miss && ply == 3 ? 0 : 1,
              attempts: 1,
              hintLevel: 0,
            ),
        ];
        await c
            .read(statsServiceProvider)
            .recordRun(
              RunRecord(
                id: 'run-$n',
                repertoireId: id,
                lineKey: l.key,
                ucis: l.ucis,
                mode: RunMode.random,
                startPly: 0,
                wrongMoveMode: WrongMoveMode.retry,
                startedAt: n * 1000,
                finishedAt: n * 1000 + 500,
                localDay: '2026-10-0${n % 6 + 1}',
                completed: true,
                deviated: false,
                gradedCount: grades.length,
                creditSum: grades.fold(0, (a, g) => a + g.credit),
                hintCount: 0,
                deviceId: 'dev',
                grades: grades,
              ),
            );
      }
    }
    Future<String> snapshot() async => [
      await repertoires.records(),
      await c.read(runRepositoryProvider).allRuns(),
      await c.read(statsRepositoryProvider).lineStats(id),
    ].toString();
    final before = await snapshot();

    c.read(routerProvider).go(Routes.settingsSection('sync'));
    await _pumpUntil(tester, find.byKey(const Key('export-backup')));
    await tester.tap(find.byKey(const Key('export-backup')));
    await _pumpUntil(tester, find.textContaining('Backup saved'));
    expect(files.backups, hasLength(1));

    await repertoires.deleteAll();
    expect(await repertoires.records(), isEmpty);

    await tester.tap(find.byKey(const Key('import-backup')));
    await _pumpUntil(tester, find.byKey(const Key('import-dialog')));
    expect(
      find.textContaining('1 repertoire, ${lines.length * 2} runs'),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('start-import')));
    await _pumpUntil(tester, find.textContaining('Backup imported'));
    expect(await snapshot(), before);
  });
}

/// Passes everything through and records the engine's output lines.
final class _RecordingTransport implements UciTransport {
  new(this._inner, this._record);

  final UciTransport _inner;
  final void Function(String line) _record;

  @override
  Stream<String> get lines => _inner.lines.map((l) {
    _record(l);
    return l;
  });

  @override
  Future<int> get exitCode => _inner.exitCode;

  @override
  void send(String command) => _inner.send(command);

  @override
  Future<void> kill() => _inner.kill();
}
