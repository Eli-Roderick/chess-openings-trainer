@Tags(['engine'])
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

/// `engine/linux/stockfish`, relative to the repository root.
File _linuxBinary() {
  var dir = Directory.current;
  while (true) {
    final f = File('${dir.path}/engine/linux/stockfish');
    if (f.existsSync()) return f;
    if (dir.parent.path == dir.path) {
      throw StateError(
        'engine/linux/stockfish not found; run '
        '`dart run tool/fetch_engines.dart --platform linux` first.',
      );
    }
    dir = dir.parent;
  }
}

void main() {
  test('pinned Linux Stockfish answers uci with uciok', () async {
    final process = await Process.start(_linuxBinary().path, const []);
    final lines = process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter());
    final uciok = Completer<List<String>>();
    final seen = <String>[];
    final sub = lines.listen((l) {
      seen.add(l);
      if (l.trim() == 'uciok' && !uciok.isCompleted) uciok.complete(seen);
    });
    process.stdin.writeln('uci');
    final output = await uciok.future.timeout(const Duration(seconds: 5));
    process.stdin.writeln('quit');
    await process.exitCode.timeout(const Duration(seconds: 5));
    await sub.cancel();

    expect(output.any((l) => l.startsWith('id name Stockfish')), isTrue);
    expect(output.last, 'uciok');
  }, tags: 'engine');
}
