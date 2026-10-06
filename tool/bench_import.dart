// Import benchmark: generates a synthetic repertoire and times importPgn.
//
//   dart run tool/bench_import.dart [--lines 1000] [--depth 16] [--seed 1] \
//       [--runs 5]
//
// Prints the time of each run and the median in milliseconds. Use
// `dart compile exe` for AOT numbers comparable to a release build.
import 'dart:io';

import 'package:chess_core/chess_core.dart';
import 'package:dartchess/dartchess.dart' show Side;

void main(List<String> args) {
  final opts = <String, int>{};
  for (var i = 0; i + 1 < args.length; i += 2) {
    final value = int.tryParse(args[i + 1]);
    if (!args[i].startsWith('--') || value == null) {
      stderr.writeln(
        'Usage: dart run tool/bench_import.dart [--lines N] [--depth D] '
        '[--seed S] [--runs R]',
      );
      exitCode = 2;
      return;
    }
    opts[args[i].substring(2)] = value;
  }
  final lines = opts['lines'] ?? 1000;
  final depth = opts['depth'] ?? 16;
  final runs = opts['runs'] ?? 5;
  final pgn = generateSyntheticPgn(
    lines: lines,
    depth: depth,
    seed: opts['seed'] ?? 1,
  );
  stdout.writeln('PGN: $lines lines x $depth plies, ${pgn.length ~/ 1024} KiB');
  final times = <int>[];
  for (var r = 1; r <= runs; r++) {
    final result = importPgn(pgn, Side.white);
    final ms = result.elapsed.inMicroseconds / 1000;
    times.add(result.elapsed.inMicroseconds);
    stdout.writeln(
      'run $r: ${ms.toStringAsFixed(1)} ms '
      '(${result.report.lines} lines, ${result.report.errors.length} errors)',
    );
  }
  times.sort();
  final median = times[times.length ~/ 2] / 1000;
  stdout.writeln('median: ${median.toStringAsFixed(1)} ms');
}
