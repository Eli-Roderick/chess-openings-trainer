import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repertoire_trainer/app/theme/app_theme.dart';
import 'package:repertoire_trainer/app/theme/colors.dart';

/// WCAG 2 relative luminance.
double _luminance(Color c) {
  double channel(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
}

/// WCAG 2 contrast ratio.
double contrast(Color a, Color b) {
  final x = _luminance(a);
  final y = _luminance(b);
  return (math.max(x, y) + 0.05) / (math.min(x, y) + 0.05);
}

/// P13 task 6: text in both themes meets WCAG AA (4.5:1); icons and other
/// non-text marks 3:1. Warning icons use the text shade.
void main() {
  for (final theme in [AppTheme.dark(), AppTheme.light()]) {
    final s = theme.colorScheme;
    group(s.brightness.name, () {
      testWidgets('text colours on surfaces: 4.5:1', (tester) async {
        late StatusTextColors status;
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Builder(
              builder: (context) {
                status = AppColors.text(context);
                return const SizedBox();
              },
            ),
          ),
        );
        final pairs = <String, (Color, Color)>{
          'onSurface': (s.onSurface, s.surface),
          'onSurfaceVariant': (s.onSurfaceVariant, s.surface),
          'onSurface on container': (s.onSurface, s.surfaceContainerHighest),
          'primary': (s.primary, s.surface),
          'onPrimary': (s.onPrimary, s.primary),
          'onPrimaryContainer': (s.onPrimaryContainer, s.primaryContainer),
          'onSecondaryContainer': (
            s.onSecondaryContainer,
            s.secondaryContainer,
          ),
          'onTertiaryContainer': (s.onTertiaryContainer, s.tertiaryContainer),
          'onErrorContainer': (s.onErrorContainer, s.errorContainer),
          'error': (s.error, s.surface),
          'status error': (status.error, s.surface),
          'status warning': (status.warning, s.surface),
          'status info': (status.info, s.surface),
          'white on success banner': (Colors.white, AppColors.success),
          'black87 on warning banner': (Colors.black87, AppColors.warning),
        };
        for (final MapEntry(key: name, value: (fg, bg)) in pairs.entries) {
          expect(contrast(fg, bg), greaterThanOrEqualTo(4.5), reason: name);
        }
      });

      test('icons on surfaces: 3:1', () {
        for (final (name, c) in [
          ('success', AppColors.success),
          ('outline', s.outline),
        ]) {
          expect(contrast(c, s.surface), greaterThanOrEqualTo(3), reason: name);
        }
      });
    });
  }
}
