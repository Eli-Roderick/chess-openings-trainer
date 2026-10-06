import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/core/settings/app_settings.dart';

/// Haptic feedback: light for moves, medium for errors (P05 task 4).
/// No-op on Windows and when the setting is off.
final class HapticsService {
  /// Creates the service.
  new(this._settings, {Future<void> Function(HapticKind)? perform})
    : _perform = perform ?? _platform;

  final AppSettings Function() _settings;
  final Future<void> Function(HapticKind) _perform;

  static Future<void> _platform(HapticKind kind) => switch (kind) {
    HapticKind.light => HapticFeedback.lightImpact(),
    HapticKind.medium => HapticFeedback.mediumImpact(),
  };

  /// After a move.
  void light() => _fire(HapticKind.light);

  /// After a mistake.
  void medium() => _fire(HapticKind.medium);

  void _fire(HapticKind kind) {
    if (defaultTargetPlatform == TargetPlatform.windows) return;
    if (!_settings().hapticsEnabled) return;
    _perform(kind).ignore();
  }
}

/// Strength of a haptic pulse.
enum HapticKind {
  /// Light impact.
  light,

  /// Medium impact.
  medium,
}

/// The app's haptics.
final hapticsServiceProvider = Provider<HapticsService>(
  (ref) => HapticsService(
    () => ref.read(settingsProvider).value ?? const AppSettings(),
  ),
);
