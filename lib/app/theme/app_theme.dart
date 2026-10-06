import 'package:flutter/material.dart';
import 'package:repertoire_trainer/app/theme/colors.dart';

/// Material 3 themes. Dark is the default (D-25).
abstract final class AppTheme {
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData light() => _build(Brightness.light);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: brightness,
    );
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: brightness == Brightness.dark
          ? AppColors.darkSurface
          : scheme.surface,
    );
  }
}
