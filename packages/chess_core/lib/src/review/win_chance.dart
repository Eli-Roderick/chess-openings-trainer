import 'dart:math' as math;

import 'package:meta/meta.dart';

/// A score from White's point of view: centipawns, or moves to mate when
/// [mate] is set (positive: White mates). Terminal positions use
/// [EvalScore.mated] / [EvalScore.drawn].
@immutable
final class EvalScore {
  /// Creates a score.
  const new({this.cp, this.mate})
    : assert(cp != null || mate != null, 'cp or mate');

  /// The side to move is checkmated; [whiteMated] says which side.
  const new mated({required bool whiteMated})
    : cp = whiteMated ? -terminalCp : terminalCp,
      mate = null;

  /// Stalemate or another dead draw.
  const new drawn() : cp = 0, mate = null;

  /// Centipawns used for a checkmate on the board.
  static const terminalCp = 100000;

  /// Centipawns (null with [mate]).
  final int? cp;

  /// Moves to mate (null with [cp]).
  final int? mate;

  /// Centipawns with mates as ±[cpCap] (for centipawn-loss averages).
  int get cappedCp {
    final m = mate;
    if (m != null) return m > 0 ? cpCap : -cpCap;
    return cp!.clamp(-cpCap, cpCap);
  }

  /// Centipawn cap.
  static const cpCap = 1000;

  /// White's win chance, 0 to 1.
  double get white => winChance(this);

  /// Win chance of White ([forWhite]) or Black.
  double forSide({required bool forWhite}) => forWhite ? white : 1 - white;

  /// The mover has a forced mate (from the mover's side).
  bool mateFor({required bool white}) {
    final m = mate;
    return m != null && (white ? m > 0 : m < 0);
  }

  @override
  bool operator ==(Object other) =>
      other is EvalScore && other.cp == cp && other.mate == mate;

  @override
  int get hashCode => Object.hash(cp, mate);

  @override
  String toString() => mate != null ? 'M$mate' : '${cp}cp';
}

/// White's win chance for [s]: lichess's open logistic fit,
/// `50 + 50 * (2 / (1 + e^(-0.00368208 cp)) - 1)`, centipawns clamped to
/// ±1000, divided by 100. A mate is 1 or 0.
double winChance(EvalScore s) {
  final m = s.mate;
  if (m != null) return m > 0 ? 1 : 0;
  final raw = s.cp!;
  if (raw.abs() >= EvalScore.terminalCp) return raw > 0 ? 1 : 0;
  final cp = raw.clamp(-EvalScore.cpCap, EvalScore.cpCap);
  return 0.5 + 0.5 * (2 / (1 + math.exp(-0.00368208 * cp)) - 1);
}
