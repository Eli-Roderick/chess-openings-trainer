import 'package:flutter/foundation.dart';

/// Drill latency (docs/plan/10-testing-and-quality.md §6): user move →
/// opponent move on the board, over the last 200 opponent replies.
final class DrillLatency extends ChangeNotifier {
  new();

  /// The app-wide instance (Diagnostics).
  static final DrillLatency instance = DrillLatency();

  final _samples = <Duration>[];

  /// Samples kept.
  static const capacity = 200;

  /// Number of samples.
  int get count => _samples.length;

  /// Records one reply.
  void add(Duration d) {
    _samples.add(d);
    if (_samples.length > capacity) _samples.removeAt(0);
    notifyListeners();
  }

  /// The [q] quantile (0-1, nearest rank), or null without samples.
  Duration? quantile(double q) {
    if (_samples.isEmpty) return null;
    final sorted = [..._samples]..sort();
    final i = (q * sorted.length).ceil().clamp(1, sorted.length) - 1;
    return sorted[i];
  }

  /// Median.
  Duration? get p50 => quantile(0.5);

  /// 95th percentile.
  Duration? get p95 => quantile(0.95);

  /// Clears the samples.
  void reset() {
    _samples.clear();
    notifyListeners();
  }
}
