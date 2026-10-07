import 'dart:async';
import 'dart:isolate';

import 'package:chess_core/chess_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show StreamProviderFamily;
import 'package:repertoire_trainer/core/analysis/analysis_providers.dart';
import 'package:repertoire_trainer/core/analysis/game_analyzer.dart';
import 'package:repertoire_trainer/core/db/app_database.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/features/games/game_analysis.dart';
import 'package:repertoire_trainer/features/games/review_model.dart';

/// Everything the review screen shows, rebuilt when a position is stored.
final class ReviewData {
  /// Creates the data.
  const new({
    required this.game,
    required this.replay,
    required this.book,
    required this.analyses,
    required this.review,
    required this.profile,
    required this.done,
    required this.total,
    required this.complete,
    required this.clocks,
    required this.keys,
  });

  /// The stored game.
  final DbImportedGame game;

  /// Positions, moves and move facts.
  final ReviewedGame replay;

  /// Book plies (1-based).
  final Set<int> book;

  /// One per position, White's point of view; null until analysed.
  final List<PositionAnalysis?> analyses;

  /// Labels, losses, accuracy and performance so far.
  final GameReview review;

  /// The tier shown (Standard once it has caught up with Quick).
  final AnalysisProfile profile;

  /// Analysed positions of [profile] and how many it needs.
  final int done;

  /// See [done].
  final int total;

  /// [profile]'s review is complete.
  final bool complete;

  /// Remaining clock after each ply, in tenths (null without `%clk`).
  final List<int>? clocks;

  /// Plies with a key label.
  final List<int> keys;

  /// Standard is complete: nothing is left to analyse.
  bool get finished => complete && profile == AnalysisProfile.standard;
}

/// The review of one game, live while it is analysed. Opening it starts
/// the analysis (Quick, then Standard) unless Standard is complete;
/// leaving cancels it (stored positions stay).
final StreamProviderFamily<ReviewData, String> reviewDataProvider =
    StreamProvider.autoDispose.family<ReviewData, String>((ref, id) {
      final repo = ref.watch(gamesRepositoryProvider);
      final out = StreamController<ReviewData>();
      final subs = <StreamSubscription<Object?>>[];
      ref.onDispose(() {
        for (final s in subs) {
          unawaited(s.cancel());
        }
        unawaited(out.close());
      });

      Future<void> start() async {
        final game = await repo.game(id);
        if (game == null) throw StateError('No game $id');
        final ucis = game.ucis.isEmpty ? <String>[] : game.ucis.split(' ');
        final standardDone =
            (await repo.review(id, AnalysisProfile.standard.index))?.complete ??
            false;
        // A complete review stores every label, book included: the opening
        // table is not needed.
        final book = standardDone
            ? {
                for (final r in await repo.positions(
                  id,
                  AnalysisProfile.standard.index,
                ))
                  if (r.label == MoveLabel.book.index) r.ply,
              }
            : ucis.isEmpty
            ? <int>{}
            : await bookFor(ref, game);
        final replay = await _replay(ucis);
        if (!ref.mounted) return;
        final total = replay.positionsToAnalyse(book: book).length;
        final clocks = parseClocks(game.clocks);
        var quick = const <DbGameAnalysis>[];
        var standard = const <DbGameAnalysis>[];
        var reviews = const <DbGameReview>[];
        final ready = <int>{};

        void emit() {
          if (ready.length < 3 || out.isClosed) return;
          final useStandard =
              standard.isNotEmpty && standard.length >= quick.length;
          final profile = useStandard
              ? AnalysisProfile.standard
              : AnalysisProfile.quick;
          final rows = useStandard ? standard : quick;
          final analyses = List<PositionAnalysis?>.filled(
            replay.length + 1,
            null,
          );
          for (final r in rows) {
            if (r.ply <= replay.length) analyses[r.ply] = analysisFromRow(r);
          }
          for (var i = 0; i <= replay.length; i++) {
            if (analyses[i] == null && replay.isTerminal(i)) {
              analyses[i] = PositionAnalysis(score: replay.terminalScore(i));
            }
          }
          final review = replay.review(
            analyses,
            book: book,
            secondPass: profile.secondPass,
          );
          // A complete review stores its scores; keep them current when the
          // formula changed (the games list reads the stored ones).
          final stored = reviews
              .where((r) => r.profile == profile.index && r.complete)
              .firstOrNull;
          final changed =
              stored != null &&
              (!_sameScore(stored.whiteAccuracy, review.whiteAccuracy) ||
                  !_sameScore(stored.blackAccuracy, review.blackAccuracy) ||
                  stored.whitePerformance != review.whitePerformance ||
                  stored.blackPerformance != review.blackPerformance);
          if (changed) {
            unawaited(
              repo.updateScores(
                id,
                profile.index,
                whiteAccuracy: review.whiteAccuracy,
                blackAccuracy: review.blackAccuracy,
                whitePerformance: review.whitePerformance,
                blackPerformance: review.blackPerformance,
              ),
            );
          }
          out.add(
            ReviewData(
              game: game,
              replay: replay,
              book: book,
              analyses: analyses,
              review: review,
              profile: profile,
              done: rows.where((r) => r.cp != null || r.mate != null).length,
              total: total,
              complete: reviews.any(
                (r) => r.profile == profile.index && r.complete,
              ),
              clocks: clocks,
              keys: keyPlies(review.labels),
            ),
          );
        }

        subs
          ..add(
            repo.watchPositions(id, AnalysisProfile.quick.index).listen((r) {
              quick = r;
              ready.add(0);
              emit();
            }),
          )
          ..add(
            repo.watchPositions(id, AnalysisProfile.standard.index).listen((r) {
              standard = r;
              ready.add(1);
              emit();
            }),
          )
          ..add(
            repo.watchReviews(id).listen((r) {
              reviews = r;
              ready.add(2);
              emit();
            }),
          );
        if (standardDone || ucis.isEmpty || !ref.mounted) return;
        subs.add(
          ref
              .read(gameAnalyzerProvider)
              .analyse(AnalysisRequest(gameId: id, ucis: ucis, book: book))
              .listen(null, onError: out.addError),
        );
      }

      unawaited(start().catchError(out.addError));
      return out.stream;
    });

bool _sameScore(double? a, double? b) =>
    a == b || a != null && b != null && (a - b).abs() < 0.05;

// Top level: the closure must not capture the provider's state.
Future<ReviewedGame> _replay(List<String> ucis) =>
    Isolate.run(() => ReviewedGame.of(ucis));
