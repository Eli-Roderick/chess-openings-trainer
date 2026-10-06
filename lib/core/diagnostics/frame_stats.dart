import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// Frame statistics for the Diagnostics screen (10-testing §6).
final class FrameStats extends ChangeNotifier {
  new _();

  /// The app-wide instance.
  static final FrameStats instance = FrameStats._();

  /// A frame slower than this (build or raster) counts as janky: one frame
  /// at 60 Hz.
  static const jankBudget = Duration(microseconds: 16667);

  int _count = 0;
  int _janky = 0;
  int _slowBuilds = 0;
  int _slowRasters = 0;
  Duration _worstBuild = Duration.zero;
  int _buildMicros = 0;
  int _rasterMicros = 0;
  Duration _worst = Duration.zero;
  bool _listening = false;

  /// Frames seen since the last reset.
  int get count => _count;

  /// Frames over [jankBudget] (build or raster).
  int get janky => _janky;

  /// Frames whose UI-thread build took longer than [jankBudget].
  int get slowBuilds => _slowBuilds;

  /// Frames whose raster took longer than [jankBudget].
  int get slowRasters => _slowRasters;

  /// Slowest build.
  Duration get worstBuild => _worstBuild;

  /// Mean build time.
  Duration get averageBuild =>
      Duration(microseconds: _count == 0 ? 0 : _buildMicros ~/ _count);

  /// Mean raster time.
  Duration get averageRaster =>
      Duration(microseconds: _count == 0 ? 0 : _rasterMicros ~/ _count);

  /// Slowest frame (build + raster).
  Duration get worst => _worst;

  /// Starts collecting frame timings.
  void start() {
    if (_listening) return;
    _listening = true;
    SchedulerBinding.instance.addTimingsCallback(add);
  }

  /// Records [timings] (public for tests).
  @visibleForTesting
  void add(List<FrameTiming> timings) {
    for (final t in timings) {
      _count++;
      _buildMicros += t.buildDuration.inMicroseconds;
      _rasterMicros += t.rasterDuration.inMicroseconds;
      final total = t.buildDuration + t.rasterDuration;
      if (total > _worst) _worst = total;
      if (t.buildDuration > _worstBuild) _worstBuild = t.buildDuration;
      final slowBuild = t.buildDuration > jankBudget;
      final slowRaster = t.rasterDuration > jankBudget;
      if (slowBuild) _slowBuilds++;
      if (slowRaster) _slowRasters++;
      if (slowBuild || slowRaster) _janky++;
    }
    notifyListeners();
  }

  /// Clears the counters.
  void reset() {
    _count = 0;
    _janky = 0;
    _slowBuilds = 0;
    _slowRasters = 0;
    _worstBuild = Duration.zero;
    _buildMicros = 0;
    _rasterMicros = 0;
    _worst = Duration.zero;
    notifyListeners();
  }
}
