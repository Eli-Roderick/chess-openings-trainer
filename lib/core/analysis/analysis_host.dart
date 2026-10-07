import 'dart:io';

import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

final _log = Logger('analysis');

/// Platform support for batch analysis (D-122): an Android foreground
/// notification that keeps the process alive, and the battery state.
/// Elsewhere both are no-ops.
class AnalysisHost {
  /// Creates the host.
  const new();

  static const _channel = MethodChannel('rt/analysis');

  bool get _android => Platform.isAndroid;

  /// Shows or updates the notification.
  Future<void> show(String text) async {
    if (!_android) return;
    try {
      await _channel.invokeMethod<void>('show', {'text': text});
    } on PlatformException catch (e) {
      _log.warning('notification: $e');
    }
  }

  /// Removes it.
  Future<void> stop() async {
    if (!_android) return;
    try {
      await _channel.invokeMethod<void>('stop');
    } on PlatformException catch (e) {
      _log.warning('notification: $e');
    }
  }

  /// Whether the battery is low (below 15 % and not charging).
  Future<bool> batteryLow() async {
    if (!_android) return false;
    try {
      final r = await _channel.invokeMapMethod<String, Object?>('battery');
      final level = r?['level'] as int? ?? 100;
      return level < 15 && r?['charging'] != true;
    } on PlatformException {
      return false;
    }
  }
}
