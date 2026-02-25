import 'dart:ui';
import 'package:flutter/widgets.dart';
import '../models/nav_mode.dart';
import '../theme/nav_toggle_theme.dart';

/// The toggle button fixed at the top-left corner.
///
/// Always rendered as ONE container. In sidebar mode, a Stack layers:
///   - two invisible hit zones (left: collapse to rail, right: tab bar)
///   - the main hamburger icon centered across the full width
///   - a small tab-bar indicator pinned to the right edge
/// In icon rail / tab bar modes the entire button is a single zone.
class ToggleButton extends StatefulWidget {
  const ToggleButton({
    super.key,
    required this.iconAnimation,
    required this.onLeftPressed,
    required this.onRightPressed,
    required this.mode,
    required this.currentWidth,
    this.enabled = true,
  });

  final Animation<double> iconAnimation;
  final VoidCallback? onLeftPressed;
  final VoidCallback? onRightPressed;
  final NavMode mode;
  final double currentWidth;
  final bool enabled;

  @override
  State<ToggleButton> createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<ToggleButton> {
  bool _hoveringLeft = false;
  bool _hoveringRight = false;

  /// Whether the button is wide enough to show the split sidebar layout.
  bool _canSplit(NavToggleTheme theme) =>
      widget.mode == NavMode.sidebar &&
      widget.currentWidth >= theme.railWidth * 2 + 1;

  @override
  Widget build(BuildContext context) {
    final theme = NavToggleTheme.of(context);
    final showSplit = _canSplit(theme);

    return Semantics(
      label: 'Navigation toggle button',
      child: Container(
        width: widget.currentWidth,
        height: theme.buttonHeight,
        decoration: BoxDecoration(
          color: theme.surface,
          border: Border(
            bottom: BorderSide(color: theme.border, width: 1),
            right: BorderSide(color: theme.border, width: 1),
          ),
        ),
        child: showSplit
            ? _buildSplitInterior(theme)
            : _buildSingleInterior(theme),
      ),
    );
  }

  /// Sidebar mode: one visual button, two invisible hit zones via Stack.
  ///
  /// The main icon is centered across the full width. A small secondary
  /// indicator sits at the right edge. Two overlay zones handle hover/tap
  /// independently — no visible divider.
  Widget _buildSplitInterior(NavToggleTheme theme) {
    // Right zone width — a narrow strip at the right edge
    const rightZoneWidth = 40.0;

    return Stack(
      children: [
        // ── Hover backgrounds (bottom layer) ──
        // Left zone hover bg
        if (_hoveringLeft && widget.enabled)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            right: rightZoneWidth,
            child: Container(color: theme.hoverSurface),
          ),
        // Right zone hover bg
        if (_hoveringRight && widget.enabled)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: rightZoneWidth,
            child: Container(color: theme.hoverSurface),
          ),

        // ── Icons (middle layer, no hit testing) ──
        // Main hamburger icon — centered across the full button
        Positioned.fill(
          child: IgnorePointer(
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
        // Small tab-bar indicator at right edge
        Positioned(
          right: 10,
          top: 0,
          bottom: 0,
          child: IgnorePointer(
            child: Center(
              child: CustomPaint(
                size: const Size(16, 16),
                painter: _SmallTabIndicatorPainter(
                  color: _hoveringRight && widget.enabled
                      ? theme.accent
                      : theme.textDim,
                ),
              ),
            ),
          ),
        ),

        // ── Hit zones (top layer) ──
        // Left zone — collapse to icon rail
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          right: rightZoneWidth,
          child: _HitZone(
            enabled: widget.enabled,
            onHoverChanged: (h) => setState(() => _hoveringLeft = h),
            onTap: widget.onLeftPressed,
            semanticLabel: 'Collapse to icon rail',
          ),
        ),
        // Right zone — toggle to tab bar
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          width: rightZoneWidth,
          child: _HitZone(
            enabled: widget.enabled,
            onHoverChanged: (h) => setState(() => _hoveringRight = h),
            onTap: widget.onRightPressed,
            semanticLabel: 'Switch to tab bar navigation',
          ),
        ),
      ],
    );
  }

  /// Single-zone interior for icon rail, tab bar, and mid-animation states.
  Widget _buildSingleInterior(NavToggleTheme theme) {
    final bg = _hoveringLeft && widget.enabled ? theme.hoverSurface : null;
    final isTabBar = widget.mode == NavMode.tabBar;

    final String label = switch (widget.mode) {
      NavMode.iconRail => 'Expand to sidebar navigation',
      NavMode.tabBar => 'Switch to sidebar navigation',
      NavMode.sidebar => 'Expand to sidebar navigation',
    };

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveringLeft = true),
      onExit: (_) => setState(() => _hoveringLeft = false),
      cursor:
          widget.enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.enabled ? widget.onLeftPressed : null,
        child: Semantics(
          button: true,
          label: label,
          child: Container(
            color: bg,
            child: Center(
              child: isTabBar
                  ? AnimatedBuilder(
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
                    )
                  : CustomPaint(
                      size: const Size(28, 28),
                      painter: _ExpandIconPainter(color: theme.accent),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Transparent hit-test zone — no visible child, just hover + tap.
class _HitZone extends StatelessWidget {
  const _HitZone({
    required this.enabled,
    required this.onHoverChanged,
    required this.onTap,
    required this.semanticLabel,
  });

  final bool enabled;
  final ValueChanged<bool> onHoverChanged;
  final VoidCallback? onTap;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => onHoverChanged(true),
      onExit: (_) => onHoverChanged(false),
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? onTap : null,
        child: Semantics(button: true, label: semanticLabel),
      ),
    );
  }
}

/// Morphing icon: sidebar hamburger (t=0) to centered tab-bar lines (t=1).
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

/// Small 3-line indicator for the tab-bar secondary action (right edge).
class _SmallTabIndicatorPainter extends CustomPainter {
  _SmallTabIndicatorPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.5;

    final cx = size.width / 2;
    final cy = size.height / 2;
    const lineGap = 3.5;
    const halfW = 5.0;

    canvas.drawLine(
        Offset(cx - halfW, cy - lineGap),
        Offset(cx + halfW, cy - lineGap),
        paint);
    canvas.drawLine(
        Offset(cx - halfW, cy), Offset(cx + halfW, cy), paint);
    canvas.drawLine(
        Offset(cx - halfW, cy + lineGap),
        Offset(cx + halfW, cy + lineGap),
        paint);
  }

  @override
  bool shouldRepaint(_SmallTabIndicatorPainter old) => old.color != color;
}

/// Expand icon for rail mode — hamburger menu icon (3 lines, staggered widths).
class _ExpandIconPainter extends CustomPainter {
  _ExpandIconPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.5;

    final cx = size.width / 2;
    final cy = size.height / 2;
    const lineGap = 5.0;
    final left = cx - 8;

    canvas.drawLine(
        Offset(left, cy - lineGap), Offset(left + 16, cy - lineGap), paint);
    canvas.drawLine(
        Offset(left, cy), Offset(left + 12, cy), paint);
    canvas.drawLine(
        Offset(left, cy + lineGap), Offset(left + 8, cy + lineGap), paint);
  }

  @override
  bool shouldRepaint(_ExpandIconPainter old) => old.color != color;
}
