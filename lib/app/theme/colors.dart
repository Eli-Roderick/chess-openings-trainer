import 'package:flutter/painting.dart';

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

  /// Report: infos.
  static const Color info = Color(0xFF8B949E);

  /// White colour chip.
  static const Color whiteSide = Color(0xFFF0F0F0);

  /// Black colour chip.
  static const Color blackSide = Color(0xFF202020);
}
