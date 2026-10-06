// Validates a repertoire PGN exactly like the app's importer
// (docs/plan/07-comment-format.md §7).
//
//   dart run tool/validate_pgn.dart --colour white|black [--json] file.pgn
//
// Exit code 0 = no errors (warnings allowed), 1 = errors, 2 = usage/file
// error.
import 'dart:async';
import 'dart:io';

import 'package:chess_core/chess_core.dart';
import 'package:dartchess/dartchess.dart' show Side;

const usage =
    'Usage: dart run tool/validate_pgn.dart --colour white|black [--json] '
    'file.pgn';

Future<void> main(List<String> args) async {
  exitCode = await runValidatePgn(args, out: stdout, err: stderr);
}

/// Runs the validator; returns the exit code.
Future<int> runValidatePgn(
  List<String> args, {
  required StringSink out,
  required StringSink err,
}) async {
  Side? side;
  var json = false;
  String? path;
  for (var i = 0; i < args.length; i++) {
    final a = args[i];
    String? colour;
    if (a == '--colour' || a == '--color') {
      if (i + 1 >= args.length) return _usage(err);
      colour = args[++i];
    } else if (a.startsWith('--colour=') || a.startsWith('--color=')) {
      colour = a.substring(a.indexOf('=') + 1);
    } else if (a == '--json') {
      json = true;
      continue;
    } else if (a.startsWith('-') || path != null) {
      return _usage(err);
    } else {
      path = a;
      continue;
    }
    side = switch (colour) {
      'white' || 'w' => Side.white,
      'black' || 'b' => Side.black,
      _ => null,
    };
    if (side == null) return _usage(err);
  }
  if (side == null || path == null) return _usage(err);

  final List<int> bytes;
  try {
    bytes = await File(path).readAsBytes();
  } on FileSystemException catch (e) {
    err.writeln('Cannot read $path: ${e.osError?.message ?? e.message}');
    return 2;
  }
  final report = importPgnBytes(bytes, side).report;
  if (json) {
    out.writeln(report.toJsonString());
  } else {
    out.write(report.toPlainText());
  }
  return report.hasErrors ? 1 : 0;
}

int _usage(StringSink err) {
  err.writeln(usage);
  return 2;
}
