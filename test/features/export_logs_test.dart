import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:repertoire_trainer/app/router.dart';
import 'package:repertoire_trainer/app/routes.dart';
import 'package:repertoire_trainer/core/diagnostics/log_setup.dart';
import 'package:repertoire_trainer/core/diagnostics/rotating_file_sink.dart';

import '../app_harness.dart';

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

LogRecord _record(String message) => LogRecord(Level.INFO, message, 'test');

void main() {
  test('readAll returns the rotated files oldest first', () async {
    final dir = Directory.systemTemp.createTempSync('rt-logs');
    addTearDown(() => dir.deleteSync(recursive: true));
    final sink = RotatingFileSink(dir, maxBytes: 80)
      ..write(_record('first'))
      ..write(_record('second'))
      ..write(_record('third'));
    expect(sink.files.length, greaterThan(1));
    final text = await sink.readAll();
    expect(text.indexOf('first'), lessThan(text.indexOf('second')));
    expect(text.indexOf('second'), lessThan(text.indexOf('third')));
  });

  testWidgets('Diagnostics exports the logs as one text file', (tester) async {
    final dir = (await tester.runAsync(
      () => Directory.systemTemp.createTemp('rt-logs'),
    ))!;
    addTearDown(() => dir.deleteSync(recursive: true));
    final sink = RotatingFileSink(dir)..write(_record('hello log'));
    final h = await AppHarness.pump(
      tester,
      size: const Size(400, 3000),
      overrides: [logSinkProvider.overrideWithValue(sink)],
    );
    h.container.read(routerProvider).go(Routes.diagnostics);
    await _until(h, find.byKey(const Key('export-logs')));
    await tester.ensureVisible(find.byKey(const Key('export-logs')));
    await tester.tap(find.byKey(const Key('export-logs')));
    await _until(h, find.text('Logs saved'));
    final saved = h.files.saved.entries.single;
    expect(saved.key, startsWith('repertoire-trainer-logs-'));
    expect(saved.key, endsWith('.txt'));
    expect(saved.value, contains('hello log'));
  });

  testWidgets('Diagnostics says so when there are no logs', (tester) async {
    final h = await AppHarness.pump(tester, size: const Size(400, 3000));
    h.container.read(routerProvider).go(Routes.diagnostics);
    await _until(h, find.byKey(const Key('export-logs')));
    await tester.ensureVisible(find.byKey(const Key('export-logs')));
    await tester.tap(find.byKey(const Key('export-logs')));
    await _until(h, find.text('No log files on this device'));
    expect(h.files.saved, isEmpty);
  });
}
