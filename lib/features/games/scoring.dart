import 'dart:isolate';

import 'package:chess_core/chess_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repertoire_trainer/core/analysis/game_analyzer.dart';
import 'package:repertoire_trainer/core/db/app_database.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/core/db/repositories/games_repository.dart';

/// The accuracy settings in force: the interim defaults until the app has
/// fitted them to chess.com's own accuracies (D-133).
final class ScoringSettings {
  /// Creates the settings.
  const new({
    this.decay = defaultAccuracyDecay,
    this.bookAsPerfect = false,
    this.revision = 0,
    this.samples = 0,
    this.error,
  });

  /// Reads the stored `review.*` values.
  factory fromMap(Map<String, String> m) => ScoringSettings(
    decay: double.tryParse(m['review.decay'] ?? '') ?? defaultAccuracyDecay,
    bookAsPerfect: m['review.bookAsPerfect'] == '1',
    revision: int.tryParse(m['review.revision'] ?? '') ?? 0,
    samples: int.tryParse(m['review.fitSamples'] ?? '') ?? 0,
    error: double.tryParse(m['review.fitError'] ?? ''),
  );

  /// Per-move accuracy decay.
  final double decay;

  /// Whether book moves count as perfect.
  final bool bookAsPerfect;

  /// [reviewFormulaRevision] the stored scores were computed with.
  final int revision;

  /// Player-games of the last fit (0: never fitted).
  final int samples;

  /// Mean absolute error to chess.com at the last fit.
  final double? error;

  /// The classifier and accuracy config.
  ReviewConfig get config =>
      ReviewConfig(accuracyDecay: decay, bookAsPerfect: bookAsPerfect);

  /// The stored form.
  Map<String, String> toMap() => {
    'review.decay': '$decay',
    'review.bookAsPerfect': bookAsPerfect ? '1' : '0',
    'review.revision': '$revision',
    'review.fitSamples': '$samples',
    if (error != null) 'review.fitError': '$error',
  };
}

/// The scoring settings; invalidate after they change.
final FutureProvider<ScoringSettings> scoringProvider =
    FutureProvider<ScoringSettings>(
      (ref) async => ScoringSettings.fromMap(
        await ref.watch(gamesRepositoryProvider).reviewSettings(),
      ),
    );

/// Outcome of [rescoreGames].
final class RescoreResult {
  /// Creates the result.
  const new({required this.games, required this.settings, this.fit});

  /// Games re-scored.
  final int games;

  /// The settings now in force.
  final ScoringSettings settings;

  /// The fit, when one was run and had enough games.
  final AccuracyFit? fit;
}

/// Re-scores every complete Standard review from its stored positions (no
/// engine work). With [fit], first refits the accuracy decay and the book
/// flag to chess.com's accuracies stored with the games. Stored scores are
/// written under the resulting settings and [reviewFormulaRevision].
Future<RescoreResult> rescoreGames(
  GamesRepository repo,
  ScoringSettings current, {
  bool fit = false,
}) async {
  final games = await repo.standardReviewedGames();
  final reviews = <(DbImportedGame, GameReview)>[];
  for (final g in games) {
    final rows = await repo.positions(g.id, AnalysisProfile.standard.index);
    reviews.add((g, await reviewStored(g.ucis, rows, current.config)));
  }
  var settings = current;
  AccuracyFit? result;
  if (fit) {
    final samples = <AccuracySample>[];
    for (final (g, r) in reviews) {
      final target = g.userWhite
          ? g.chessComWhiteAccuracy
          : g.chessComBlackAccuracy;
      if (target != null) {
        samples.add(
          AccuracySample(review: r, white: g.userWhite, target: target),
        );
      }
    }
    result = fitAccuracy(samples);
    if (result != null) {
      settings = ScoringSettings(
        decay: result.decay,
        bookAsPerfect: result.bookAsPerfect,
        revision: reviewFormulaRevision,
        samples: result.samples,
        error: result.meanError,
      );
    }
  }
  settings = ScoringSettings(
    decay: settings.decay,
    bookAsPerfect: settings.bookAsPerfect,
    revision: reviewFormulaRevision,
    samples: settings.samples,
    error: settings.error,
  );
  for (final (g, r) in reviews) {
    double? acc({required bool white}) => r.accuracyWith(
      white: white,
      decay: settings.decay,
      bookAsPerfect: settings.bookAsPerfect,
    );
    final w = acc(white: true);
    final b = acc(white: false);
    await repo.updateScores(
      g.id,
      AnalysisProfile.standard.index,
      whiteAccuracy: w,
      blackAccuracy: b,
      whitePerformance: w == null ? null : ratingFromAccuracy(w),
      blackPerformance: b == null ? null : ratingFromAccuracy(b),
    );
  }
  await repo.saveReviewSettings(settings.toMap());
  return RescoreResult(games: reviews.length, settings: settings, fit: result);
}

/// Re-scores once after a formula change ([reviewFormulaRevision]);
/// returns whether it did (nothing happens when the revision is current).
Future<bool> rescoreIfStale(
  GamesRepository repo,
  ScoringSettings current,
) async {
  if (current.revision == reviewFormulaRevision) return false;
  await rescoreGames(repo, current);
  return true;
}

/// Positions of a stored Standard review as analyses of [replay] (game-end
/// positions scored from the board).
List<PositionAnalysis?> analysesFromRows(
  ReviewedGame replay,
  List<DbGameAnalysis> rows,
) {
  final analyses = List<PositionAnalysis?>.filled(replay.length + 1, null);
  for (final r in rows) {
    if (r.ply <= replay.length) analyses[r.ply] = analysisFromRow(r);
  }
  for (var i = 0; i <= replay.length; i++) {
    if (analyses[i] == null && replay.isTerminal(i)) {
      analyses[i] = PositionAnalysis(score: replay.terminalScore(i));
    }
  }
  return analyses;
}

/// The review of a stored complete Standard result, computed off the UI
/// isolate. Book plies are the labels stored with it.
Future<GameReview> reviewStored(
  String ucis,
  List<DbGameAnalysis> rows,
  ReviewConfig config,
) => Isolate.run(() {
  final replay = ReviewedGame.of(ucis.isEmpty ? <String>[] : ucis.split(' '));
  return replay.review(
    analysesFromRows(replay, rows),
    book: {
      for (final r in rows)
        if (r.label == MoveLabel.book.index) r.ply,
    },
    config: config,
  );
});
