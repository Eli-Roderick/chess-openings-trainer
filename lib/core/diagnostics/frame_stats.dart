import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// Frame statistics for the Diagnostics screen (10-testing §6).
final class FrameStats extends ChangeNotifier {
  new _();

  /// The app-wide instance.
  static final FrameStats instance = FrameStats._();

  /// One frame at 60 Hz: the budget until the display's refresh rate is
  /// known, and the budget the CI profile tests assert against.
  static const jankBudget = Duration(microseconds: 16667);

  /// The frame budget for a display refreshing at [hz] (60 Hz when unknown
  /// or implausible).
  static Duration budgetFor(double hz) => hz >= 30 && hz <= 240
      ? Duration(microseconds: (1000000 / hz).round())
      : jankBudget;

  /// A frame slower than this (build or raster) is over budget; set from
  /// the display's refresh rate when collection starts.
  Duration budget = jankBudget;

  int _count = 0;
  int _janky = 0;
  int _slowBuilds = 0;
  int _slowRasters = 0;
  Duration _worstBuild = Duration.zero;
  Duration _worstRaster = Duration.zero;
  int _buildMicros = 0;
  int _rasterMicros = 0;
  Duration _worst = Duration.zero;
  bool _listening = false;

  /// Frames seen since the last reset.
  int get count => _count;

  /// Frames over [budget] (build or raster).
  int get janky => _janky;

  /// Frames whose UI-thread build took longer than [budget].
  int get slowBuilds => _slowBuilds;

  /// Frames whose raster took longer than [budget].
  int get slowRasters => _slowRasters;

  /// Slowest build.
  Duration get worstBuild => _worstBuild;

  /// Slowest raster.
  Duration get worstRaster => _worstRaster;

  /// Share of frames over budget, in percent.
  double get overBudgetPercent => _count == 0 ? 0 : 100 * _janky / _count;

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
    final views = PlatformDispatcher.instance.views;
    if (views.isNotEmpty) budget = budgetFor(views.first.display.refreshRate);
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
      if (t.rasterDuration > _worstRaster) _worstRaster = t.rasterDuration;
      final slowBuild = t.buildDuration > budget;
      final slowRaster = t.rasterDuration > budget;
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
    _worstRaster = Duration.zero;
    _buildMicros = 0;
    _rasterMicros = 0;
    _worst = Duration.zero;
    notifyListeners();
  }
}
