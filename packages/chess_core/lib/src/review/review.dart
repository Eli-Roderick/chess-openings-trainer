import 'dart:math' as math;

import 'package:chess_core/src/review/move_facts.dart';
import 'package:chess_core/src/review/win_chance.dart';
import 'package:chess_core/src/tree/line_key.dart';
import 'package:dartchess/dartchess.dart';

/// A move's classification. Stored by index: append only, never reorder.
enum MoveLabel {
  /// In the repertoire or the opening table.
  book,

  /// The only legal move.
  forced,

  /// A sound sacrifice that is best or near-best.
  brilliant,

  /// The only good move.
  great,

  /// The engine's move.
  best,

  /// Within 0.02 expected points of best.
  excellent,

  /// Within 0.05.
  good,

  /// Within 0.10.
  inaccuracy,

  /// Within 0.20.
  mistake,

  /// More than 0.20, or allows a quick mate.
  blunder,

  /// Fails to punish the opponent's mistake.
  miss,
}

/// Every threshold of the classifier and accuracy, in expected points
/// (0 to 1) unless named otherwise (classification-research.md §5).
final class ReviewConfig {
  /// Creates the config; the defaults are v2 of the research file.
  const new({
    this.excellent = 0.02,
    this.good = 0.05,
    this.inaccuracy = 0.10,
    this.mistake = 0.20,
    this.nearBest = 0.02,
    this.brilliantMinAfter = 0.45,
    this.overwhelming = 0.97,
    this.sacrificePawns = 2,
    this.sacrificePlies = 8,
    this.greatGap = 0.10,
    this.greatCpGap = 300,
    this.greatSwing = false,
    this.missOpponentDrop = 0.10,
    this.missGiveBack = 0.10,
    this.missTolerance = 0.05,
    this.quickMate = 2,
    this.alreadyLostCp = -600,
    this.candidateLow = 0.03,
    this.candidateHigh = 0.97,
    this.accuracyDecay = 0.055,
  });

  /// Band upper limits of loss.
  final double excellent;

  /// See [excellent].
  final double good;

  /// See [excellent].
  final double inaccuracy;

  /// See [excellent].
  final double mistake;

  /// Loss allowed for Brilliant and Great.
  final double nearBest;

  /// Brilliant: the mover's expected points after the move, at least.
  final double brilliantMinAfter;

  /// The alternative is already winning this much: no Brilliant / Great.
  final double overwhelming;

  /// Brilliant: material given up, in pawns.
  final int sacrificePawns;

  /// Brilliant: plies of the engine line played before counting material.
  final int sacrificePlies;

  /// Great: the second-best move is at least this much worse.
  final double greatGap;

  /// Great: or at least this many centipawns worse.
  final int greatCpGap;

  /// Experimental Great: a move that turns a worse position into a better
  /// one by at least [greatGap] across 0.5. Off until calibrated.
  final bool greatSwing;

  /// Miss: the opponent's previous move lost at least this much.
  final double missOpponentDrop;

  /// Miss: this move gives back at least this much.
  final double missGiveBack;

  /// Miss: and ends within this much of the position before the
  /// opponent's mistake (worse stays Mistake or Blunder).
  final double missTolerance;

  /// Allowing mate in this many moves or fewer is a Blunder...
  final int quickMate;

  /// ...unless the mover was already worse than this (centipawns).
  final int alreadyLostCp;

  /// Second-pass candidates: the mover's expected points before the move
  /// lie in this band.
  final double candidateLow;

  /// See [candidateLow].
  final double candidateHigh;

  /// Per-move accuracy decay: `103.17 * e^(-k * win% lost) - 3.17`.
  final double accuracyDecay;
}

/// Engine result for one position, White's point of view.
final class PositionAnalysis {
  /// Creates the result.
  const new({required this.score, this.pv = const [], this.second});

  /// Best-line score.
  final EvalScore score;

  /// Best line (UCI), empty for a terminal position.
  final List<String> pv;

  /// Second-best move's score, from the MultiPV pass (null when the pass
  /// did not run on this position).
  final EvalScore? second;

  /// The engine's move.
  String? get best => pv.isEmpty ? null : pv.first;
}

/// The review of one game.
final class GameReview {
  /// Creates the review.
  const new({
    required this.labels,
    required this.losses,
    required this.whiteAccuracy,
    required this.blackAccuracy,
    required this.whitePerformance,
    required this.blackPerformance,
  });

  /// Label of ply `i + 1`; null while either side of it is unanalysed
  /// (book and forced moves need no analysis).
  final List<MoveLabel?> labels;

  /// Expected points the mover lost at ply `i + 1` (null for book, forced
  /// and unanalysed moves).
  final List<double?> losses;

  /// Accuracy 0 to 100 (null without an analysed, non-book move).
  final double? whiteAccuracy;

  /// See [whiteAccuracy].
  final double? blackAccuracy;

  /// Rough performance estimate from average centipawn loss.
  final int? whitePerformance;

  /// See [whitePerformance].
  final int? blackPerformance;
}

/// A game's positions and per-move board facts, computed once.
final class ReviewedGame {
  /// Replays [ucis] (castling as king two squares) from the start position.
  factory of(List<String> ucis) {
    final positions = <Position>[Chess.initial];
    final moves = <NormalMove>[];
    final facts = <MoveFacts>[];
    Square? previousCapture;
    for (final uci in ucis) {
      final before = positions.last;
      final parsed = Move.parse(uci);
      if (parsed is! NormalMove || !before.isLegal(parsed)) {
        throw ArgumentError.value(uci, 'ucis', 'illegal move');
      }
      final move = before.normalizeMove(parsed) as NormalMove;
      final f = moveFacts(before, move, previousCapture: previousCapture);
      facts.add(f);
      moves.add(move);
      positions.add(before.play(move));
      previousCapture = f.capture ? move.to : null;
    }
    return ReviewedGame._(List.unmodifiable(ucis), positions, moves, facts);
  }

  new _(this.ucis, this.positions, this.moves, this.facts);

  /// The moves as given.
  final List<String> ucis;

  /// Position after `i` plies (0 = start), length `ucis.length + 1`.
  final List<Position> positions;

  /// The moves in dartchess form (castling as king takes rook).
  final List<NormalMove> moves;

  /// Facts of ply `i + 1`.
  final List<MoveFacts> facts;

  /// Number of plies.
  int get length => ucis.length;

  /// FEN of the position after `i` plies.
  String fen(int i) => positions[i].fen;

  /// Whether position `i` is the end of the game on the board.
  bool isTerminal(int i) => positions[i].isGameOver;

  /// The board score of a terminal position `i` (mate or draw).
  EvalScore terminalScore(int i) {
    final p = positions[i];
    return p.isCheckmate
        ? EvalScore.mated(whiteMated: p.turn == Side.white)
        : const EvalScore.drawn();
  }

  bool _isEngineMove(int ply, PositionAnalysis before) {
    final best = before.best;
    if (best == null) return false;
    final played = ucis[ply - 1];
    return best == played ||
        normalizeUci(best, isCastling: _castles(ply)) == played;
  }

  bool _castles(int ply) {
    final m = moves[ply - 1];
    return positions[ply - 1].board.roleAt(m.from) == Role.king &&
        (m.from.file - m.to.file).abs() > 1;
  }

  /// Positions the engine must analyse: each position before or after a
  /// move that is neither book nor forced, except game-ending positions
  /// (scored from the board with [terminalScore]).
  List<int> positionsToAnalyse({Set<int> book = const {}}) {
    bool judged(int ply) =>
        ply >= 1 &&
        ply <= length &&
        !book.contains(ply) &&
        !facts[ply - 1].forced;
    return [
      for (var i = 0; i <= length; i++)
        if ((judged(i) || judged(i + 1)) && !isTerminal(i)) i,
    ];
  }

  /// Positions (index `ply - 1`) where the MultiPV pass should run: the
  /// played move was the engine's, not book or forced, not a recapture,
  /// not out of check, with the mover's expected points in the candidate
  /// band, and either a sacrifice or a possible Great.
  List<int> secondPassCandidates(
    List<PositionAnalysis?> analyses, {
    Set<int> book = const {},
    ReviewConfig config = const ReviewConfig(),
  }) {
    if (analyses.length != length + 1) {
      throw ArgumentError.value(
        analyses.length,
        'analyses',
        'one per position',
      );
    }
    final out = <int>[];
    for (var ply = 1; ply <= length; ply++) {
      final before = analyses[ply - 1];
      final after = analyses[ply];
      if (before == null || after == null) continue;
      final f = facts[ply - 1];
      if (book.contains(ply) || f.forced || f.recapture || f.inCheck) {
        continue;
      }
      if (!_isEngineMove(ply, before)) continue;
      final ep = before.score.forSide(forWhite: ply.isOdd);
      if (ep < config.candidateLow || ep > config.candidateHigh) continue;
      final great = !f.easyCapture && !f.fleesCheaperAttacker;
      if (great || _sacrifice(ply, after, config)) out.add(ply - 1);
    }
    return out;
  }

  /// A real sacrifice: the engine's line after the move settles material
  /// down, and either a piece now newly hangs or the move itself gave up
  /// an exchange by capturing. A piece that merely looks en prise (a
  /// tactic keeps it) does not count. Without a line the static exchange
  /// on the board decides.
  bool _sacrifice(int ply, PositionAnalysis after, ReviewConfig config) {
    final f = facts[ply - 1];
    final stat = f.sacrificesPiece(minPawns: config.sacrificePawns);
    if (after.pv.isEmpty) return stat;
    return (stat || f.capture) &&
        pvSacrifice(
          positions[ply - 1],
          positions[ply],
          after.pv,
          minPawns: config.sacrificePawns,
          plies: config.sacrificePlies,
        );
  }

  /// Classifies every analysed move and scores both sides. [analyses]
  /// has one entry per position (length `length + 1`, null = not yet
  /// analysed); [book] holds book plies (1-based). Without
  /// [secondPass], Great is not given and Brilliant uses the best line's
  /// score as the alternative (provisional).
  GameReview review(
    List<PositionAnalysis?> analyses, {
    Set<int> book = const {},
    ReviewConfig config = const ReviewConfig(),
    bool secondPass = true,
  }) {
    if (analyses.length != length + 1) {
      throw ArgumentError.value(
        analyses.length,
        'analyses',
        'one per position',
      );
    }
    final labels = List<MoveLabel?>.filled(length, null);
    final losses = List<double?>.filled(length, null);
    final cpLosses = List<int?>.filled(length, null);
    for (var ply = 1; ply <= length; ply++) {
      final f = facts[ply - 1];
      if (book.contains(ply)) {
        labels[ply - 1] = MoveLabel.book;
        continue;
      }
      if (f.forced) {
        labels[ply - 1] = MoveLabel.forced;
        continue;
      }
      final before = analyses[ply - 1];
      final after = analyses[ply];
      if (before == null || after == null) continue;
      final white = ply.isOdd;
      final engineMove = _isEngineMove(ply, before);
      final epBefore = before.score.forSide(forWhite: white);
      final epAfter = after.score.forSide(forWhite: white);
      final loss = engineMove ? 0.0 : math.max(0, epBefore - epAfter);
      losses[ply - 1] = loss.toDouble();
      int moverCp(EvalScore s) => white ? s.cappedCp : -s.cappedCp;
      cpLosses[ply - 1] = engineMove
          ? 0
          : math.max(0, moverCp(before.score) - moverCp(after.score));
      labels[ply - 1] = _label(
        ply,
        before,
        after,
        analyses,
        losses,
        loss.toDouble(),
        engineMove: engineMove,
        config: config,
        secondPass: secondPass,
      );
    }
    double? accuracy({required bool white}) =>
        _accuracy(analyses, losses, white: white, decay: config.accuracyDecay);
    int? performance({required bool white}) {
      final mine = [
        for (var i = white ? 0 : 1; i < length; i += 2) ?cpLosses[i],
      ];
      if (mine.isEmpty) return null;
      final acpl = mine.reduce((a, b) => a + b) / mine.length;
      return (3000 * math.exp(-0.0115 * acpl)).round().clamp(100, 3200);
    }

    return GameReview(
      labels: labels,
      losses: losses,
      whiteAccuracy: accuracy(white: true),
      blackAccuracy: accuracy(white: false),
      whitePerformance: performance(white: true),
      blackPerformance: performance(white: false),
    );
  }

  MoveLabel _label(
    int ply,
    PositionAnalysis before,
    PositionAnalysis after,
    List<PositionAnalysis?> analyses,
    List<double?> losses,
    double loss, {
    required bool engineMove,
    required ReviewConfig config,
    required bool secondPass,
  }) {
    final white = ply.isOdd;
    final f = facts[ply - 1];
    final epBefore = before.score.forSide(forWhite: white);
    final epAfter = after.score.forSide(forWhite: white);
    final second = before.second;
    final epSecond = second?.forSide(forWhite: white);
    // The best alternative to the played move.
    final alternative = engineMove ? (epSecond ?? epBefore) : epBefore;
    if (loss <= config.nearBest &&
        epAfter >= config.brilliantMinAfter &&
        alternative < config.overwhelming &&
        !f.recapture &&
        (!engineMove || second != null || !secondPass) &&
        _sacrifice(ply, after, config)) {
      return MoveLabel.brilliant;
    }
    if (secondPass &&
        engineMove &&
        second != null &&
        epSecond! < config.overwhelming &&
        !f.recapture &&
        !f.easyCapture &&
        !f.fleesCheaperAttacker &&
        !f.inCheck) {
      final s = second.cp;
      final b = before.score.cp;
      final cpGap =
          s != null &&
          b != null &&
          (white ? b - s : s - b) >= config.greatCpGap;
      final onlyMate =
          before.score.mateFor(white: white) &&
          !second.mateFor(white: white) &&
          after.score.mateFor(white: white);
      final swing =
          config.greatSwing &&
          epSecond < 0.5 &&
          epAfter >= 0.5 &&
          epAfter - epSecond >= config.greatGap;
      if (epBefore - epSecond >= config.greatGap ||
          cpGap ||
          onlyMate ||
          swing) {
        return MoveLabel.great;
      }
    }
    // Allowing a quick mate.
    final m = after.score.mate;
    final allowsMate = m != null && (white ? m < 0 : m > 0);
    if (allowsMate && m.abs() <= config.quickMate) {
      final moverCp = white ? before.score.cappedCp : -before.score.cappedCp;
      final lostAlready =
          before.score.mate != null && !before.score.mateFor(white: white) ||
          before.score.mate == null && moverCp < config.alreadyLostCp;
      if (!lostAlready) return MoveLabel.blunder;
    }
    // Miss: the opponent erred and this move gives it back.
    if (loss >= config.good) {
      final opponentDrop = ply >= 2 ? losses[ply - 2] : null;
      final earlier = ply >= 2 ? analyses[ply - 2] : null;
      if (opponentDrop != null &&
          earlier != null &&
          opponentDrop >= config.missOpponentDrop &&
          loss >= config.missGiveBack &&
          epAfter >=
              earlier.score.forSide(forWhite: white) - config.missTolerance) {
        return MoveLabel.miss;
      }
      if (before.score.mateFor(white: white) &&
          !after.score.mateFor(white: white)) {
        return MoveLabel.miss;
      }
    }
    if (engineMove || loss <= 0) return MoveLabel.best;
    if (loss <= config.excellent) return MoveLabel.excellent;
    if (loss <= config.good) return MoveLabel.good;
    if (loss <= config.inaccuracy) return MoveLabel.inaccuracy;
    if (loss <= config.mistake) return MoveLabel.mistake;
    return MoveLabel.blunder;
  }

  /// lichess-style game accuracy: the mean of the volatility-weighted mean
  /// and the harmonic mean of per-move accuracies; book, forced and
  /// unanalysed moves are left out.
  double? _accuracy(
    List<PositionAnalysis?> analyses,
    List<double?> losses, {
    required bool white,
    required double decay,
  }) {
    // White's win % per position; unanalysed positions repeat the last.
    final wins = <double>[];
    var last = 50.0;
    for (final a in analyses) {
      if (a != null) last = a.score.white * 100;
      wins.add(last);
    }
    final window = (length / 10).floor().clamp(2, 8);
    final weights = <double>[];
    final first = wins.take(window).toList();
    for (var i = 0; i < math.min(window, wins.length) - 2; i++) {
      weights.add(_volatility(first));
    }
    for (var i = 0; i + window <= wins.length; i++) {
      weights.add(_volatility(wins.sublist(i, i + window)));
    }
    final accs = <double>[];
    final ws = <double>[];
    for (var ply = white ? 1 : 2; ply <= length; ply += 2) {
      final loss = losses[ply - 1];
      if (loss == null) continue;
      final acc = (103.1668 * math.exp(-decay * loss * 100) - 3.1669).clamp(
        0.0,
        100.0,
      );
      accs.add(acc);
      ws.add(ply - 1 < weights.length ? weights[ply - 1] : 0.5);
    }
    if (accs.isEmpty) return null;
    var weighted = 0.0;
    var total = 0.0;
    for (var i = 0; i < accs.length; i++) {
      weighted += accs[i] * ws[i];
      total += ws[i];
    }
    var inverse = 0.0;
    for (final a in accs) {
      inverse += 1 / math.max(a, 1);
    }
    final harmonic = accs.length / inverse;
    return (weighted / total + harmonic) / 2;
  }
}

double _volatility(List<double> xs) {
  final mean = xs.reduce((a, b) => a + b) / xs.length;
  var sq = 0.0;
  for (final x in xs) {
    sq += (x - mean) * (x - mean);
  }
  return math.sqrt(sq / xs.length).clamp(0.5, 12);
}
