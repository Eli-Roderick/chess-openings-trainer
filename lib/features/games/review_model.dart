import 'package:chess_core/chess_core.dart';

/// Labels the review steps through with Next/Previous key move.
const Set<MoveLabel> keyLabels = {
  MoveLabel.brilliant,
  MoveLabel.great,
  MoveLabel.mistake,
  MoveLabel.blunder,
  MoveLabel.miss,
};

/// Labels the user can retry (their own moves only).
const Set<MoveLabel> retryLabels = {
  MoveLabel.mistake,
  MoveLabel.blunder,
  MoveLabel.miss,
};

/// Plies (1-based) whose move has a key label.
List<int> keyPlies(List<MoveLabel?> labels) => [
  for (var i = 0; i < labels.length; i++)
    if (keyLabels.contains(labels[i])) i + 1,
];

/// The first key ply after [ply], or null.
int? nextKey(List<int> keys, int ply) {
  for (final k in keys) {
    if (k > ply) return k;
  }
  return null;
}

/// The last key ply before [ply], or null.
int? previousKey(List<int> keys, int ply) {
  for (final k in keys.reversed) {
    if (k < ply) return k;
  }
  return null;
}

/// White moves at odd plies.
bool whiteMoved(int ply) => ply.isOdd;

/// Seconds spent on [ply] (1-based) from the remaining clocks in tenths
/// (`clocks[i]` after ply `i + 1`) and the time control (`180+2`); null
/// when unknown (no clocks, daily games).
double? secondsSpent(List<int>? clocks, String timeControl, int ply) {
  if (clocks == null || ply < 1 || ply > clocks.length) return null;
  final m = RegExp(r'^(\d+)(?:\+(\d+))?$').firstMatch(timeControl);
  if (m == null) return null;
  final base = int.parse(m[1]!) * 10;
  final increment = int.parse(m[2] ?? '0') * 10;
  final before = ply >= 3 ? clocks[ply - 3] : base;
  final spent = before - clocks[ply - 1] + increment;
  return spent < 0 ? 0 : spent / 10;
}

/// Parses the stored clock column (comma-separated tenths).
List<int>? parseClocks(String? column) {
  if (column == null || column.isEmpty) return null;
  return [for (final c in column.split(',')) int.parse(c)];
}

/// The user's worst move: the ply (1-based) with the largest win-chance
/// loss among the user's mistakes, blunders and misses; null for a clean
/// game.
int? turningPoint(GameReview review, {required bool userWhite}) {
  int? worst;
  var loss = -1.0;
  for (var i = 0; i < review.labels.length; i++) {
    final ply = i + 1;
    if (whiteMoved(ply) != userWhite) continue;
    if (!retryLabels.contains(review.labels[i])) continue;
    final l = review.losses[i] ?? 0;
    if (l > loss) {
      loss = l;
      worst = ply;
    }
  }
  return worst;
}

/// Counts of each label for one side.
Map<MoveLabel, int> labelCounts(
  List<MoveLabel?> labels, {
  required bool white,
}) {
  final counts = <MoveLabel, int>{};
  for (var i = 0; i < labels.length; i++) {
    final label = labels[i];
    if (label == null || whiteMoved(i + 1) != white) continue;
    counts[label] = (counts[label] ?? 0) + 1;
  }
  return counts;
}

/// Move number and dots for [ply]: `12.` or `12...`.
String moveNumber(int ply) =>
    whiteMoved(ply) ? '${(ply + 1) ~/ 2}.' : '${ply ~/ 2}...';
