import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:chess_core/chess_core.dart';
import 'package:dartchess/dartchess.dart' show Side;
import 'package:repertoire_trainer/core/db/repositories/repertoire_repository.dart';
import 'package:repertoire_trainer/core/import/import_runner.dart';

/// Lines and depth of the benchmark PGN (10-testing §5).
const benchmarkLines = 1000;

/// Plies per benchmark line.
const benchmarkDepth = 16;

/// Result of [runImportBenchmark].
final class ImportBenchmarkResult {
  /// Creates the result.
  const new({required this.lines, required this.import, required this.store});

  /// Lines imported.
  final int lines;

  /// Parse, build and validate (the import isolate).
  final Duration import;

  /// Writing the repertoire to the database.
  final Duration store;

  /// Both.
  Duration get total => import + store;
}

/// Generates the 1,000-line synthetic PGN, imports it with [runner] into a
/// temporary repertoire of [repertoires], and removes it again
/// (Diagnostics "Import benchmark", 10-testing §5).
Future<ImportBenchmarkResult> runImportBenchmark({
  required ImportRunner runner,
  required RepertoireRepository repertoires,
}) async {
  final pgn = await Isolate.run(
    () => generateSyntheticPgn(
      lines: benchmarkLines,
      depth: benchmarkDepth,
      seed: 1,
    ),
  );
  final bytes = Uint8List.fromList(utf8.encode(pgn));
  final watch = Stopwatch()..start();
  final finished = await runner(
    bytes,
    Side.white,
  ).firstWhere((p) => p is ImportFinished);
  final importTime = watch.elapsed;
  final ImportFinished(:result, :text) = finished as ImportFinished;
  watch
    ..reset()
    ..start();
  final id = await repertoires.create(
    name: 'Import benchmark',
    color: Side.white,
    pgn: text ?? pgn,
    result: result,
  );
  final storeTime = watch.elapsed;
  await repertoires.remove(id);
  return ImportBenchmarkResult(
    lines: result.tree?.lines.length ?? 0,
    import: importTime,
    store: storeTime,
  );
}
