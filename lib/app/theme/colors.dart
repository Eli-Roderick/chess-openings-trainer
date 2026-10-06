import 'package:flutter/material.dart';

/// Colour tokens shared by the themes (docs/plan/01-product-spec.md §3).
abstract final class AppColors {
  /// Material 3 seed.
  static const Color seed = Color(0xFF4E7D3A);

  /// Dark surface: a true dark grey so the board is the brightest element.
  static const Color darkSurface = Color(0xFF121212);

  /// Report: errors.
  static const Color error = Color(0xFFE5534B);

  /// Report: warnings.
  static const Color warning = Color(0xFFE3A21A);

  /// Good result (deviation reply): icons and the banner behind white text
  /// (WCAG AA in both themes, P13).
  static const Color success = Color(0xFF2E7D32);

  /// Report: infos.
  static const Color info = Color(0xFF8B949E);

  /// White colour chip.
  static const Color whiteSide = Color(0xFFF0F0F0);

  /// Black colour chip.
  static const Color blackSide = Color(0xFF202020);

  /// [error], [warning] and [info] for text: readable (WCAG AA, 4.5:1) on
  /// the surface of the current theme; the light theme uses darker shades.
  static StatusTextColors text(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? const StatusTextColors(error: error, warning: warning, info: info)
      : const StatusTextColors(
          error: Color(0xFFB3261E),
          warning: Color(0xFF8A5300),
          info: Color(0xFF59616A),
        );
}

/// Status colours for text (see [AppColors.text]).
@immutable
final class StatusTextColors {
  /// Creates the set.
  const new({required this.error, required this.warning, required this.info});

  /// Errors and wrong moves.
  final Color error;

  /// Warnings and comparable moves.
  final Color warning;

  /// Infos and correct moves.
  final Color info;
}
