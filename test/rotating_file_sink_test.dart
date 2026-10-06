import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:repertoire_trainer/core/diagnostics/rotating_file_sink.dart';

void main() {
  late Directory dir;

  setUp(() => dir = Directory.systemTemp.createTempSync('rt_logs'));
  tearDown(() => dir.deleteSync(recursive: true));

  LogRecord record(String msg) => LogRecord(Level.INFO, msg, 'test');

  test('rotates and keeps at most maxFiles files', () {
    final sink = RotatingFileSink(dir, maxBytes: 200);
    for (var i = 0; i < 50; i++) {
      sink.write(record('message number $i with some padding'));
    }
    final names = dir.listSync().map((e) => e.uri.pathSegments.last).toSet();
    expect(names, {'app.log', 'app.1.log', 'app.2.log'});
    expect(sink.files.first.readAsStringSync(), contains('message number 49'));
    for (final f in sink.files) {
      expect(f.lengthSync(), lessThanOrEqualTo(200));
    }
  });
}
