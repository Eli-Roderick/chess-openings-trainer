import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:uci_engine/uci_engine.dart';

/// Share of the bar that is White's for [score] (White's point of view;
/// docs/plan/05-engine.md §8): `0.5 + 0.5 * (2 / (1 + e^(-0.004 cp)) - 1)`,
/// a mate fills the bar. Null (no score yet): even.
double evalFraction(EngineScore? score) {
  if (score == null) return 0.5;
  final mate = score.mate;
  if (mate != null) return mate > 0 ? 1 : 0;
  final cp = score.cp!;
  return 0.5 + 0.5 * (2 / (1 + math.exp(-0.004 * cp)) - 1);
}

/// "+0.35", "-1.20", "M3", "-M2" (White's point of view).
String evalLabel(EngineScore score) {
  final mate = score.mate;
  if (mate != null) return mate > 0 ? 'M$mate' : '-M${-mate}';
  final pawns = score.cp! / 100;
  return '${pawns >= 0 ? '+' : ''}${pawns.toStringAsFixed(2)}';
}

/// Vertical evaluation bar: White's share from the bottom when White is at
/// the bottom ([whiteAtBottom]); animated over 250 ms.
class EvalBar extends StatelessWidget {
  /// Creates the bar.
  const new({
    required this.score,
    super.key,
    this.whiteAtBottom = true,
    this.width = 14,
  });

  /// Score from White's point of view; null before the first update.
  final EngineScore? score;

  /// Board orientation.
  final bool whiteAtBottom;

  /// Bar width.
  final double width;

  @override
  Widget build(BuildContext context) {
    final score = this.score;
    return Semantics(
      label: score == null ? null : evalLabel(score),
      textDirection: TextDirection.ltr,
      child: SizedBox(
        width: width,
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: evalFraction(score)),
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          builder: (context, white, _) => CustomPaint(
            key: const Key('eval-bar'),
            painter: _EvalPainter(white, whiteAtBottom: whiteAtBottom),
          ),
        ),
      ),
    );
  }
}

class _EvalPainter extends CustomPainter {
  new(this.white, {required this.whiteAtBottom});

  final double white;
  final bool whiteAtBottom;

  @override
  void paint(Canvas canvas, Size size) {
    final whiteHeight = size.height * white;
    final black = Paint()..color = const Color(0xFF3A3A3A);
    final whitePaint = Paint()..color = const Color(0xFFEDEDED);
    canvas.drawRect(Offset.zero & size, black);
    final rect = whiteAtBottom
        ? Rect.fromLTWH(0, size.height - whiteHeight, size.width, whiteHeight)
        : Rect.fromLTWH(0, 0, size.width, whiteHeight);
    canvas.drawRect(rect, whitePaint);
    final mid = Paint()
      ..color = const Color(0x80FF9800)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      mid,
    );
  }

  @override
  bool shouldRepaint(_EvalPainter old) =>
      old.white != white || old.whiteAtBottom != whiteAtBottom;
}
