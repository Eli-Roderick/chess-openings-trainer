import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// White's win chance over the game: one point per position, White's area
/// from the bottom, key moves as dots, the current position as a line. Tap
/// or drag to select a position. Painted, not built: one [CustomPaint].
class EvalGraph extends StatelessWidget {
  /// Creates the graph.
  const new({
    required this.values,
    required this.ply,
    required this.onSelect,
    super.key,
    this.marks = const {},
  });

  /// White's win chance (0..1) per position; null = not analysed yet.
  final List<double?> values;

  /// Selected position.
  final int ply;

  /// Dot colour by position.
  final Map<int, Color> marks;

  /// Called with the position under the finger.
  final ValueChanged<int> onSelect;

  int _at(double dx, double width) {
    final n = values.length - 1;
    if (n <= 0 || width <= 0) return 0;
    return (dx / width * n).round().clamp(0, n);
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, c) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (d) => onSelect(_at(d.localPosition.dx, c.maxWidth)),
        onHorizontalDragUpdate: (d) =>
            onSelect(_at(d.localPosition.dx, c.maxWidth)),
        child: RepaintBoundary(
          child: CustomPaint(
            size: Size(c.maxWidth, c.maxHeight),
            painter: EvalGraphPainter(
              values: values,
              ply: ply,
              marks: marks,
              background: dark
                  ? const Color(0xFF3A3A3A)
                  : const Color(0xFF5A5A5A),
              white: dark ? const Color(0xFFD9D9D9) : const Color(0xFFF4F4F4),
              cursor: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints [EvalGraph].
class EvalGraphPainter extends CustomPainter {
  /// Creates the painter.
  const new({
    required this.values,
    required this.ply,
    required this.marks,
    required this.background,
    required this.white,
    required this.cursor,
  });

  /// See [EvalGraph.values].
  final List<double?> values;

  /// See [EvalGraph.ply].
  final int ply;

  /// See [EvalGraph.marks].
  final Map<int, Color> marks;

  /// Black's area.
  final Color background;

  /// White's area.
  final Color white;

  /// Selected-position line.
  final Color cursor;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    canvas.drawRect(Offset.zero & size, Paint()..color = background);
    final n = values.length - 1;
    if (n <= 0) return;
    double x(int i) => i / n * w;
    final ys = List<double>.filled(values.length, h / 2);
    var last = 0.5;
    for (var i = 0; i < values.length; i++) {
      last = values[i] ?? last;
      ys[i] = h * (1 - last);
    }
    final area = Path()..moveTo(0, h);
    for (var i = 0; i <= n; i++) {
      area.lineTo(x(i), ys[i]);
    }
    area
      ..lineTo(w, h)
      ..close();
    canvas
      ..drawPath(area, Paint()..color = white)
      ..drawLine(
        Offset(0, h / 2),
        Offset(w, h / 2),
        Paint()
          ..color = const Color(0x55888888)
          ..strokeWidth = 1,
      )
      ..drawLine(
        Offset(x(ply), 0),
        Offset(x(ply), h),
        Paint()
          ..color = cursor
          ..strokeWidth = 2,
      );
    for (final MapEntry(key: i, value: color) in marks.entries) {
      if (i < 0 || i > n) continue;
      canvas.drawCircle(Offset(x(i), ys[i]), 3, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(EvalGraphPainter old) =>
      !identical(old.values, values) && !_same(old.values, values) ||
      old.ply != ply ||
      !mapEquals(old.marks, marks) ||
      old.background != background ||
      old.white != white ||
      old.cursor != cursor;

  static bool _same(List<double?> a, List<double?> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
