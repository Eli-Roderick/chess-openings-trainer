import 'dart:async';

import 'package:chess_core/chess_core.dart';
import 'package:dartchess/dartchess.dart' show Side;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repertoire_trainer/core/analysis/analysis_providers.dart';
import 'package:repertoire_trainer/core/analysis/game_analyzer.dart';
import 'package:repertoire_trainer/core/db/app_database.dart';
import 'package:repertoire_trainer/core/db/providers.dart';

/// Book plies of [game]: the user's repertoires of that colour first,
/// then the lichess opening table.
Future<Set<int>> bookFor(Ref ref, DbImportedGame game) async {
  final table = await ref.read(openingBookProvider.future);
  final side = game.userWhite ? Side.white : Side.black;
  final summaries = await ref.read(repertoireSummariesProvider.future);
  final roots = <TreeNode>[];
  for (final s in summaries.where((s) => s.color == side)) {
    final tree = ref.read(repertoireTreeProvider(s.id).future);
    roots.add((await tree).root);
  }
  final ucis = game.ucis.split(' ');
  return bookPlies(ucis, fensOf(ucis), table: table, roots: roots);
}

/// Analysis request for a stored game (Quick then Standard).
Future<AnalysisRequest> requestFor(Ref ref, DbImportedGame game) async =>
    AnalysisRequest(
      gameId: game.id,
      ucis: game.ucis.split(' '),
      book: await bookFor(ref, game),
    );

/// Batch state.
final class BatchState {
  /// Creates the state.
  const new({
    this.total = 0,
    this.index = 0,
    this.progress,
    this.running = false,
    this.stoppedForBattery = false,
  });

  /// Games in the batch and the one being analysed (0-based).
  final int total;

  /// See [total].
  final int index;

  /// Progress of the current game's tier.
  final AnalysisProgress? progress;

  /// A batch is running.
  final bool running;

  /// The last batch stopped because the battery was low.
  final bool stoppedForBattery;
}

/// "Analyse recent games": one game after another (Quick then Standard),
/// with the Android foreground notification; stops on low battery or
/// [stop]; pauses while a drill is open (the analyzer's hold).
final class BatchController extends Notifier<BatchState> {
  StreamSubscription<AnalysisProgress>? _sub;
  var _cancelled = false;

  @override
  BatchState build() {
    ref.onDispose(() => unawaited(_sub?.cancel()));
    return const BatchState();
  }

  /// Analyses [games] (newest first) that have no complete Standard
  /// review yet.
  Future<void> start(List<DbImportedGame> games) async {
    if (state.running) return;
    final repo = ref.read(gamesRepositoryProvider);
    final todo = <DbImportedGame>[];
    for (final g in games) {
      final r = await repo.review(g.id, AnalysisProfile.standard.index);
      if (!(r?.complete ?? false)) todo.add(g);
    }
    if (todo.isEmpty) return;
    _cancelled = false;
    final host = ref.read(analysisHostProvider);
    state = BatchState(total: todo.length, running: true);
    var lowBattery = false;
    try {
      for (var i = 0; i < todo.length && !_cancelled; i++) {
        if (await host.batteryLow()) {
          lowBattery = true;
          break;
        }
        state = BatchState(total: todo.length, index: i, running: true);
        await host.show('${i + 1} / ${todo.length}');
        final request = await requestFor(ref, todo[i]);
        final done = Completer<void>();
        _sub = ref
            .read(gameAnalyzerProvider)
            .analyse(request)
            .listen(
              (p) => state = BatchState(
                total: todo.length,
                index: i,
                progress: p,
                running: true,
              ),
              onError: (Object _) {},
              onDone: done.complete,
            );
        await done.future;
        _sub = null;
      }
    } finally {
      await host.stop();
      state = BatchState(stoppedForBattery: lowBattery);
    }
  }

  /// Stops the batch (finished positions stay stored).
  Future<void> stop() async {
    _cancelled = true;
    await _sub?.cancel();
    _sub = null;
    state = const BatchState();
  }
}

/// The batch.
final batchProvider = NotifierProvider<BatchController, BatchState>(
  BatchController.new,
);

/// The user's accuracy per game id (Standard over Quick).
final StreamProvider<Map<String, double>> gameAccuracyProvider =
    StreamProvider<Map<String, double>>(
      (ref) => ref.watch(gamesRepositoryProvider).watchUserAccuracies(),
    );
