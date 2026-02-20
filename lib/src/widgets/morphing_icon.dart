import 'dart:ui';
import 'package:flutter/widgets.dart';

/// Paints the toggle button icon that morphs between sidebar and tab bar states.
///
/// Sidebar state (t=0): 3 horizontal lines of unequal length + vertical bar on right.
/// Tab bar state (t=1): 3 horizontal lines of equal wider length, vertical bar faded out.
class MorphingIconPainter extends CustomPainter {
  MorphingIconPainter({
    required this.t,
    required this.color,
  });

  /// Animation value: 0.0 = sidebar icon, 1.0 = tab bar icon.
  final double t;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.5;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // --- Three horizontal lines ---
    // Sidebar: unequal widths (18, 14, 10), left-aligned.
    // Tab bar: equal width (20), centered.
    const lineGap = 6.0;

    final w1 = lerpDouble(18, 20, t)!;
    final w2 = lerpDouble(14, 20, t)!;
    final w3 = lerpDouble(10, 20, t)!;

    // Sidebar lines start from left offset; tabbar lines are centered.
    final sidebarLeft = cx - 10;

    final x1 = lerpDouble(sidebarLeft, cx - w1 / 2, t)!;
    final x2 = lerpDouble(sidebarLeft, cx - w2 / 2, t)!;
    final x3 = lerpDouble(sidebarLeft, cx - w3 / 2, t)!;

    final y1 = cy - lineGap;
    final y2 = cy;
    final y3 = cy + lineGap;

    canvas.drawLine(Offset(x1, y1), Offset(x1 + w1, y1), paint);
    canvas.drawLine(Offset(x2, y2), Offset(x2 + w2, y2), paint);
    canvas.drawLine(Offset(x3, y3), Offset(x3 + w3, y3), paint);

    // --- Vertical bar (sidebar only, fades out) ---
    if (t < 1.0) {
      final barPaint = Paint()
        ..color = color.withValues(alpha: color.a * (1.0 - t))
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 2.5;

      final barX = lerpDouble(cx + 8, cx + 12, t)!;
      final barTop = cy - lineGap - 2;
      final barBottom = cy + lineGap + 2;

      canvas.drawLine(Offset(barX, barTop), Offset(barX, barBottom), barPaint);
    }
  }

  @override
  bool shouldRepaint(MorphingIconPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.color != color;
}

/// Widget wrapper for the morphing icon, driven by an Animation<double>.
class MorphingIcon extends StatelessWidget {
  const MorphingIcon({
    super.key,
    required this.animation,
    required this.color,
    this.size = 40.0,
  });

  final Animation<double> animation;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return CustomPaint(
          size: Size(size, size),
          painter: MorphingIconPainter(
            t: animation.value,
            color: color,
          ),
        );
      },
    );
  }
}
