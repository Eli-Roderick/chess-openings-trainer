import 'package:flutter/material.dart';
import 'package:repertoire_trainer/app/theme/colors.dart';

/// Material 3 themes with the bundled Inter font. Dark is the default
/// (D-25).
abstract final class AppTheme {
  /// Bundled UI font family.
  static const fontFamily = 'Inter';

  /// The dark theme.
  static ThemeData dark() => _build(Brightness.dark);

  /// The light theme.
  static ThemeData light() => _build(Brightness.light);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: brightness,
      surface: dark ? AppColors.darkSurface : null,
    );
    return ThemeData(
      colorScheme: scheme,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: const AppBarTheme(toolbarHeight: 48),
      visualDensity: VisualDensity.standard,
    );
  }

  /// Text style for SAN moves: tabular figures so move numbers line up
  /// (01-product-spec §3).
  static TextStyle moveText(BuildContext context) =>
      (Theme.of(context).textTheme.bodyMedium ?? const TextStyle()).copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
      );
}
