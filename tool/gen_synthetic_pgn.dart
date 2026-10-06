// Generates a legal synthetic repertoire PGN for benchmarks and tests.
//
//   dart run tool/gen_synthetic_pgn.dart --lines 1000 --depth 16 --seed 1 \
//       [--colour white|black] [--out file.pgn]
//
// Writes to stdout unless --out is given.
import 'dart:io';

import 'package:chess_core/chess_core.dart';
import 'package:dartchess/dartchess.dart' show Side;

void main(List<String> args) {
  final opts = <String, String>{};
  for (var i = 0; i + 1 < args.length; i += 2) {
    if (!args[i].startsWith('--')) break;
    opts[args[i].substring(2)] = args[i + 1];
  }
  final lines = int.tryParse(opts['lines'] ?? '1000');
  final depth = int.tryParse(opts['depth'] ?? '16');
  final seed = int.tryParse(opts['seed'] ?? '1');
  final side = switch (opts['colour'] ?? 'white') {
    'white' => Side.white,
    'black' => Side.black,
    _ => null,
  };
  if (args.length.isOdd ||
      lines == null ||
      depth == null ||
      seed == null ||
      side == null) {
    stderr.writeln(
      'Usage: dart run tool/gen_synthetic_pgn.dart --lines N --depth D '
      '--seed S [--colour white|black] [--out file.pgn]',
    );
    exitCode = 2;
    return;
  }
  final pgn = generateSyntheticPgn(
    lines: lines,
    depth: depth,
    seed: seed,
    userSide: side,
  );
  final out = opts['out'];
  if (out == null) {
    stdout.write(pgn);
  } else {
    File(out).writeAsStringSync(pgn);
  }
}
