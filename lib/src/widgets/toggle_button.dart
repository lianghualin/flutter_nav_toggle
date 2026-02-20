import 'dart:ui';
import 'package:flutter/widgets.dart';
import '../theme/nav_toggle_theme.dart';

/// The 200×52 toggle button fixed at the top-left corner.
///
/// Contains the morphing icon and handles hover state.
/// The button is non-interactive during animations.
class ToggleButton extends StatefulWidget {
  const ToggleButton({
    super.key,
    required this.iconAnimation,
    required this.onPressed,
    required this.isSidebarMode,
    this.enabled = true,
  });

  final Animation<double> iconAnimation;
  final VoidCallback? onPressed;
  final bool isSidebarMode;
  final bool enabled;

  @override
  State<ToggleButton> createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<ToggleButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = NavToggleTheme.of(context);
    final hoverBg = _hovering && widget.enabled
        ? HSLColor.fromColor(theme.surface)
            .withLightness(
              (HSLColor.fromColor(theme.surface).lightness + 0.05)
                  .clamp(0.0, 1.0),
            )
            .toColor()
        : theme.surface;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor:
          widget.enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.enabled ? widget.onPressed : null,
        child: Semantics(
          button: true,
          label: widget.isSidebarMode
              ? 'Switch to tab bar navigation'
              : 'Switch to sidebar navigation',
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: theme.buttonWidth,
            height: theme.buttonHeight,
            decoration: BoxDecoration(
              color: hoverBg,
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(theme.cornerRadius),
              ),
              border: Border(
                bottom: BorderSide(color: theme.border, width: 1),
                right: BorderSide(color: theme.border, width: 1),
              ),
            ),
            child: Center(
              child: AnimatedBuilder(
                animation: widget.iconAnimation,
                builder: (context, _) {
                  return CustomPaint(
                    size: const Size(40, 40),
                    painter: _MorphingIconPainter(
                      t: widget.iconAnimation.value,
                      color: theme.accent,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Inline painter for the morphing icon inside the toggle button.
class _MorphingIconPainter extends CustomPainter {
  _MorphingIconPainter({required this.t, required this.color});

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
    const lineGap = 6.0;

    final w1 = lerpDouble(18, 20, t)!;
    final w2 = lerpDouble(14, 20, t)!;
    final w3 = lerpDouble(10, 20, t)!;

    final sidebarLeft = cx - 10;
    final x1 = lerpDouble(sidebarLeft, cx - w1 / 2, t)!;
    final x2 = lerpDouble(sidebarLeft, cx - w2 / 2, t)!;
    final x3 = lerpDouble(sidebarLeft, cx - w3 / 2, t)!;

    canvas.drawLine(
        Offset(x1, cy - lineGap), Offset(x1 + w1, cy - lineGap), paint);
    canvas.drawLine(Offset(x2, cy), Offset(x2 + w2, cy), paint);
    canvas.drawLine(
        Offset(x3, cy + lineGap), Offset(x3 + w3, cy + lineGap), paint);

    if (t < 1.0) {
      final barPaint = Paint()
        ..color = color.withValues(alpha: color.a * (1.0 - t))
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 2.5;
      final barX = lerpDouble(cx + 8, cx + 12, t)!;
      canvas.drawLine(
        Offset(barX, cy - lineGap - 2),
        Offset(barX, cy + lineGap + 2),
        barPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_MorphingIconPainter old) =>
      old.t != t || old.color != color;
}
