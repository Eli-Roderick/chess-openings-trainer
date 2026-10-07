import 'dart:io';
import 'dart:isolate';

import 'package:chess_core/chess_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repertoire_trainer/core/analysis/analysis_host.dart';
import 'package:repertoire_trainer/core/analysis/game_analyzer.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/core/engine/engine_providers.dart';
import 'package:uci_engine/uci_engine.dart';

/// The lichess opening table, parsed in an isolate once.
final openingBookProvider = FutureProvider<OpeningBook>((ref) async {
  final tsv = await rootBundle.loadString('assets/openings/openings.tsv');
  return await Isolate.run(() => OpeningBook.parse(tsv));
});

/// Game analysis engines (separate single-thread processes, D-121).
final gameAnalyzerProvider = Provider<GameAnalyzer>((ref) {
  final analyzer = GameAnalyzer(
    launch: () async {
      final binary = await ref.read(engineBinaryProvider.future);
      if (binary == null) {
        throw const EngineUnavailable('Stockfish binary not found');
      }
      return await ref.read(transportStarterProvider)(binary.path);
    },
    store: ref.watch(gamesRepositoryProvider),
    workers: defaultWorkers(Platform.numberOfProcessors),
    clock: ref.watch(clockProvider),
  );
  ref.onDispose(analyzer.dispose);
  return analyzer;
});

/// Foreground notification and battery (overridden in tests).
final analysisHostProvider = Provider<AnalysisHost>(
  (ref) => const AnalysisHost(),
);
