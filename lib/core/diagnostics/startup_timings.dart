import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

final _log = Logger('startup');

/// Startup milestones for the Diagnostics screen
/// (docs/plan/10-testing-and-quality.md §6). Times are measured from the
/// start of `main()`; Android adds the time from process start to `main()`.
final class StartupTimings {
  new _();

  /// The app-wide instance.
  static final StartupTimings instance = StartupTimings._();

  final Stopwatch _clock = Stopwatch();
  Duration? _runApp;
  Duration? _firstFrame;
  Duration? _homeData;
  Duration? _processToMain;

  /// Call first thing in `main()`. Clears earlier milestones (integration
  /// tests boot the app several times in one process).
  void markMainStart() {
    _runApp = _firstFrame = _homeData = _processToMain = null;
    _clock
      ..reset()
      ..start();
  }

  /// After `runApp`.
  void markRunApp() => _runApp ??= _clock.elapsed;

  /// When the first frame was rasterized.
  void markFirstFrame() => _firstFrame ??= _clock.elapsed;

  /// When Home first showed data.
  void markHomeData() {
    if (_homeData != null || !_clock.isRunning) return;
    _homeData = _clock.elapsed;
    _log.info('Home data after ${_homeData!.inMilliseconds} ms');
  }

  /// main → runApp.
  Duration? get mainToRunApp => _runApp;

  /// runApp → first frame.
  Duration? get runAppToFirstFrame =>
      _firstFrame == null || _runApp == null ? null : _firstFrame! - _runApp!;

  /// First frame → Home data.
  Duration? get firstFrameToHomeData => _homeData == null || _firstFrame == null
      ? null
      : _homeData! - _firstFrame!;

  /// main → Home data.
  Duration? get mainToHomeData => _homeData;

  /// Process start → main (Android only).
  Duration? get processToMain => _processToMain;

  /// Asks Android how long ago the process started
  /// (`rt/native.processStartElapsedMs`) and derives process → main.
  Future<void> loadProcessStart({
    MethodChannel channel = const MethodChannel('rt/native'),
  }) async {
    try {
      final sinceProcessStart = await channel.invokeMethod<int>(
        'processStartElapsedMs',
      );
      if (sinceProcessStart != null) {
        _processToMain = Duration(
          milliseconds: sinceProcessStart - _clock.elapsedMilliseconds,
        );
      }
    } on MissingPluginException {
      // Not Android.
    } on PlatformException catch (e) {
      _log.warning('processStartElapsedMs failed', e);
    }
  }
}
