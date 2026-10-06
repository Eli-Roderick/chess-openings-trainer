import 'package:flutter/widgets.dart';

/// Phone vs wide layout (docs/plan/01-product-spec.md §3): wide when the
/// width is at least 600 dp or the screen is in landscape.
enum LayoutSize {
  /// Width < 600 dp in portrait.
  phone,

  /// Width ≥ 600 dp, or landscape.
  wide;

  /// The layout for [size].
  static LayoutSize of(Size size) =>
      size.width >= 600 || size.width > size.height ? wide : phone;
}

/// Builds [phone] or [wide] depending on the available size, and limits
/// content width on very wide windows.
class AdaptiveLayout extends StatelessWidget {
  /// Creates the layout.
  const new({required this.phone, this.wide, super.key});

  /// Layout for phones.
  final Widget phone;

  /// Layout for wide screens (defaults to [phone] centred at 840 dp).
  final Widget? wide;

  /// Standard gutter for non-board content.
  static const gutter = 16.0;

  /// Maximum width of list/form content on wide screens.
  static const maxContentWidth = 840.0;

  /// The layout size of [context].
  static LayoutSize sizeOf(BuildContext context) =>
      LayoutSize.of(MediaQuery.sizeOf(context));

  @override
  Widget build(BuildContext context) {
    if (sizeOf(context) == LayoutSize.phone) return phone;
    return wide ??
        Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: maxContentWidth),
            child: phone,
          ),
        );
  }
}
