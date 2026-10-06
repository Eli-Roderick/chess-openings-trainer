import 'package:flutter/foundation.dart';

/// Deviation-candidates jobs (P09 task 7): how long the prefetch takes and
/// how often it is ready when the opponent's move is due (target ≥ 95 %),
/// over the last 200 of each.
final class DeviationTimings extends ChangeNotifier {
  new();

  /// The app-wide instance (Diagnostics).
  static final DeviationTimings instance = DeviationTimings();

  /// Samples kept.
  static const capacity = 200;

  final _jobs = <Duration>[];
  final _needed = <bool>[];

  /// Finished jobs recorded.
  int get jobCount => _jobs.length;

  /// Times a deviation move was needed.
  int get neededCount => _needed.length;

  /// Share of those where it was ready, or null before any.
  double? get readyRate =>
      _needed.isEmpty ? null : _needed.where((r) => r).length / _needed.length;

  /// Records a finished candidates job.
  void addJob(Duration d) {
    _jobs.add(d);
    if (_jobs.length > capacity) _jobs.removeAt(0);
    notifyListeners();
  }

  /// Records whether the deviation move was ready when needed.
  void addNeeded({required bool ready}) {
    _needed.add(ready);
    if (_needed.length > capacity) _needed.removeAt(0);
    notifyListeners();
  }

  /// The [q] quantile of job durations (nearest rank), or null.
  Duration? quantile(double q) {
    if (_jobs.isEmpty) return null;
    final sorted = [..._jobs]..sort();
    final i = (q * sorted.length).ceil().clamp(1, sorted.length) - 1;
    return sorted[i];
  }

  /// Median job duration.
  Duration? get p50 => quantile(0.5);

  /// 95th percentile job duration.
  Duration? get p95 => quantile(0.95);

  /// Clears the samples.
  void reset() {
    _jobs.clear();
    _needed.clear();
    notifyListeners();
  }
}
