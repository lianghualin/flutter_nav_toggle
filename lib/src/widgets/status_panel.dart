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
          _WarningRow(
            count: status.warnings,
            theme: theme,
          ),
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

class _WarningRow extends StatelessWidget {
  const _WarningRow({required this.count, required this.theme});

  final int count;
  final NavToggleTheme theme;

  @override
  Widget build(BuildContext context) {
    final hasWarnings = count > 0;
    final color = hasWarnings ? const Color(0xFFF59E0B) : theme.textDim;

    return Row(
      children: [
        Text(
          '\u26A0',
          style: TextStyle(fontSize: 12, color: color),
        ),
        const SizedBox(width: 6),
        Text(
          '$count warning${count == 1 ? '' : 's'}',
          style: TextStyle(
            fontFamily: theme.navFontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: color,
          ),
        ),
      ],
    );
  }
}
