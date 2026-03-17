import 'package:flutter/widgets.dart';
import '../models/system_status.dart';
import '../theme/nav_toggle_theme.dart';

/// Displays system status metrics (CPU, Memory, Disk, Warnings)
/// at the bottom of the sidebar panel.
class StatusPanel extends StatelessWidget {
  const StatusPanel({super.key, required this.status});

  final SystemStatus status;

  static const _green = Color(0xFF10B981);
  static const _amber = Color(0xFFF59E0B);
  static const _red = Color(0xFFEF4444);

  static Color _barColor(double value) {
    if (value >= 0.8) return _red;
    if (value >= 0.6) return _amber;
    return _green;
  }

  @override
  Widget build(BuildContext context) {
    final theme = NavToggleTheme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: theme.border, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MetricRow(
            label: 'CPU',
            value: status.cpu,
            barColor: _barColor(status.cpu),
            theme: theme,
          ),
          const SizedBox(height: 8),
          _MetricRow(
            label: 'MEM',
            value: status.memory,
            barColor: _barColor(status.memory),
            theme: theme,
          ),
          const SizedBox(height: 8),
          _MetricRow(
            label: 'DISK',
            value: status.disk,
            barColor: _barColor(status.disk),
            theme: theme,
          ),
          const SizedBox(height: 10),
          Container(
            height: 1,
            color: theme.border,
          ),
          const SizedBox(height: 10),
          _WarningRow(
            count: status.warnings,
            onTap: status.onWarningTap,
            theme: theme,
          ),
          if (status.time != null) ...[
            const SizedBox(height: 8),
            _TimeRow(
              time: status.time!,
              date: status.date,
              theme: theme,
            ),
          ],
          if (status.userName != null) ...[
            const SizedBox(height: 8),
            _UserNameRow(name: status.userName!, theme: theme),
          ],
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.label,
    required this.value,
    required this.barColor,
    required this.theme,
  });

  final String label;
  final double value;
  final Color barColor;
  final NavToggleTheme theme;

  @override
  Widget build(BuildContext context) {
    final pct = '${(value * 100).round()}%';

    return Row(
      children: [
        SizedBox(
          width: 36,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: theme.navFontFamily,
              fontWeight: FontWeight.w700,
              fontSize: 11,
              letterSpacing: 0.5,
              color: theme.textDim,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _MiniProgressBar(value: value, color: barColor, theme: theme),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 32,
          child: Text(
            pct,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: theme.monoFontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 11,
              color: theme.text,
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniProgressBar extends StatelessWidget {
  const _MiniProgressBar({
    required this.value,
    required this.color,
    required this.theme,
  });

  final double value;
  final Color color;
  final NavToggleTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: theme.border,
        borderRadius: BorderRadius.circular(3),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: value.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}

class _WarningRow extends StatefulWidget {
  const _WarningRow({
    required this.count,
    this.onTap,
    required this.theme,
  });

  final int count;
  final VoidCallback? onTap;
  final NavToggleTheme theme;

  @override
  State<_WarningRow> createState() => _WarningRowState();
}

class _WarningRowState extends State<_WarningRow> {
  static const _amber = Color(0xFFF59E0B);
  static const _red = Color(0xFFEF4444);

  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final hasWarnings = widget.count > 0;
    final isCritical = widget.count >= 10;

    // Use theme.accent for healthy, semantic amber/red for warnings
    final Color statusColor;
    if (!hasWarnings) {
      statusColor = theme.accent;
    } else if (isCritical) {
      statusColor = _red;
    } else {
      statusColor = _amber;
    }

    final iconBg = statusColor.withValues(alpha: 0.12);
    final hoverBg = statusColor.withValues(alpha: 0.08);
    final textColor = hasWarnings ? statusColor : theme.text;
    final badgeBgColor = hasWarnings
        ? statusColor
        : statusColor.withValues(alpha: 0.12);
    final badgeTextColor = hasWarnings
        ? const Color(0xFFFFFFFF)
        : statusColor;

    final label = hasWarnings
        ? '${widget.count} warning${widget.count == 1 ? '' : 's'}'
        : 'All clear';

    Widget row = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: _hovering ? hoverBg : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _hovering
                  ? statusColor.withValues(alpha: 0.18)
                  : iconBg,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Center(
              child: hasWarnings
                  ? _WarningTriangleIcon(color: statusColor)
                  : _CheckIcon(color: statusColor),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: theme.navFontFamily,
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: textColor,
                decoration: _hovering && widget.onTap != null
                    ? TextDecoration.underline
                    : null,
                decorationColor: statusColor,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: badgeBgColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${widget.count}',
              style: TextStyle(
                fontFamily: theme.monoFontFamily,
                fontWeight: FontWeight.w700,
                fontSize: 10,
                color: badgeTextColor,
              ),
            ),
          ),
        ],
      ),
    );

    if (widget.onTap != null) {
      row = MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: row,
        ),
      );
    }

    return row;
  }
}

class _CheckIcon extends StatelessWidget {
  const _CheckIcon({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(12, 12),
      painter: _CheckIconPainter(color: color),
    );
  }
}

class _CheckIconPainter extends CustomPainter {
  const _CheckIconPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Circle
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2 - 0.5,
      paint,
    );

    // Checkmark
    final path = Path()
      ..moveTo(size.width * 0.28, size.height * 0.50)
      ..lineTo(size.width * 0.45, size.height * 0.67)
      ..lineTo(size.width * 0.75, size.height * 0.33);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CheckIconPainter oldDelegate) =>
      color != oldDelegate.color;
}

class _WarningTriangleIcon extends StatelessWidget {
  const _WarningTriangleIcon({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(12, 12),
      painter: _WarningTrianglePainter(color: color),
    );
  }
}

class _WarningTrianglePainter extends CustomPainter {
  const _WarningTrianglePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Triangle
    final path = Path()
      ..moveTo(size.width * 0.5, size.height * 0.08)
      ..lineTo(size.width * 0.95, size.height * 0.88)
      ..lineTo(size.width * 0.05, size.height * 0.88)
      ..close();
    canvas.drawPath(path, paint);

    // Exclamation line
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.38),
      Offset(size.width * 0.5, size.height * 0.58),
      paint,
    );

    // Exclamation dot
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.72),
      1.0,
      paint..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_WarningTrianglePainter oldDelegate) =>
      color != oldDelegate.color;
}

class _TimeRow extends StatelessWidget {
  const _TimeRow({required this.time, this.date, required this.theme});

  final String time;
  final String? date;
  final NavToggleTheme theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: theme.textDim.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Center(
              child: CustomPaint(
                size: const Size(12, 12),
                painter: _ClockIconPainter(color: theme.textDim),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    fontFamily: theme.monoFontFamily,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: theme.text,
                    height: 1.2,
                  ),
                ),
                if (date != null)
                  Text(
                    date!,
                    style: TextStyle(
                      fontFamily: theme.navFontFamily,
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                      color: theme.textDim,
                      height: 1.3,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ClockIconPainter extends CustomPainter {
  const _ClockIconPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Circle outline
    final circlePaint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(cx, cy), cx - 0.8, circlePaint);

    // Clock hands
    final handPaint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    // Minute hand pointing to 12 (up)
    canvas.drawLine(Offset(cx, cy), Offset(cx, cy - cx * 0.6), handPaint);
    // Hour hand pointing to 3 (right)
    canvas.drawLine(Offset(cx, cy), Offset(cx + cx * 0.45, cy + cx * 0.15), handPaint);
  }

  @override
  bool shouldRepaint(_ClockIconPainter oldDelegate) =>
      color != oldDelegate.color;
}

class _UserNameRow extends StatelessWidget {
  const _UserNameRow({required this.name, required this.theme});

  final String name;
  final NavToggleTheme theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '\u{1F464}',
          style: TextStyle(fontSize: 12, color: theme.textDim),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            name,
            style: TextStyle(
              fontFamily: theme.navFontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: theme.text,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
