import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:repertoire_trainer/core/diagnostics/frame_stats.dart';

FrameTiming timing({required int buildUs, required int rasterUs}) {
  // vsync, build start/end, raster start/end (microseconds).
  return FrameTiming(
    vsyncStart: 0,
    buildStart: 0,
    buildFinish: buildUs,
    rasterStart: buildUs,
    rasterFinish: buildUs + rasterUs,
    rasterFinishWallTime: buildUs + rasterUs,
  );
}

void main() {
  test('counts slow builds and slow rasters against one 60 Hz frame', () {
    final stats = FrameStats.instance
      ..reset()
      ..add([
        timing(buildUs: 2000, rasterUs: 5000),
        timing(buildUs: 16667, rasterUs: 16667),
        timing(buildUs: 16668, rasterUs: 1000),
        timing(buildUs: 1000, rasterUs: 40000),
      ]);
    expect(stats.count, 4);
    expect(stats.slowBuilds, 1);
    expect(stats.slowRasters, 1);
    expect(stats.janky, 2);
    expect(stats.worstBuild, const Duration(microseconds: 16668));
    expect(stats.worst, const Duration(microseconds: 41000));
    expect(stats.averageBuild, const Duration(microseconds: 9083));
    stats.reset();
    expect((stats.count, stats.janky, stats.slowBuilds), (0, 0, 0));
  });
}
