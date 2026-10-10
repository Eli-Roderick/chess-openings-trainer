import 'package:chess_core/src/review/review.dart';

/// One side of one game: our stored losses against chess.com's accuracy.
final class AccuracySample {
  /// Creates the sample.
  const new({required this.review, required this.white, required this.target});

  /// The reviewed game (a complete Standard review).
  final GameReview review;

  /// Which side the target belongs to.
  final bool white;

  /// chess.com's accuracy of that side.
  final double target;
}

/// The fitted accuracy settings.
final class AccuracyFit {
  /// Creates the fit.
  const new({
    required this.decay,
    required this.bookAsPerfect,
    required this.meanError,
    required this.bias,
    required this.samples,
  });

  /// Best per-move decay.
  final double decay;

  /// Whether counting book moves as perfect fits better.
  final bool bookAsPerfect;

  /// Mean absolute difference to chess.com at the fit.
  final double meanError;

  /// Mean of ours minus chess.com at the fit.
  final double bias;

  /// Number of player-games used.
  final int samples;
}

/// Fewest player-games a fit is trusted with.
const int minFitSamples = 4;

/// Grid search over decay (and the book flag) minimising the squared error
/// to chess.com's accuracies; null with fewer than [minFitSamples].
AccuracyFit? fitAccuracy(List<AccuracySample> samples) {
  if (samples.length < minFitSamples) return null;
  AccuracyFit? best;
  var bestSq = double.infinity;
  for (final book in [false, true]) {
    for (var k = 0.02; k <= 0.15001; k += 0.0025) {
      var sq = 0.0;
      var abs = 0.0;
      var bias = 0.0;
      var n = 0;
      for (final s in samples) {
        final a = s.review.accuracyWith(
          white: s.white,
          decay: k,
          bookAsPerfect: book,
        );
        if (a == null) continue;
        final d = a - s.target;
        sq += d * d;
        abs += d.abs();
        bias += d;
        n++;
      }
      if (n < minFitSamples || sq >= bestSq) continue;
      bestSq = sq;
      best = AccuracyFit(
        decay: double.parse(k.toStringAsFixed(4)),
        bookAsPerfect: book,
        meanError: abs / n,
        bias: bias / n,
        samples: n,
      );
    }
  }
  return best;
}
