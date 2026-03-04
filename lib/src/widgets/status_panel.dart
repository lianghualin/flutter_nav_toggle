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
            onTap: status.onWarningTap,
            theme: theme,
          ),
          if (status.time != null) ...[
            const SizedBox(height: 8),
            _TimeRow(time: status.time!, theme: theme),
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
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final hasWarnings = widget.count > 0;
    final color = hasWarnings ? const Color(0xFFF59E0B) : widget.theme.textDim;

    Widget row = Row(
      children: [
        Text(
          '\u26A0',
          style: TextStyle(fontSize: 12, color: color),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            '${widget.count} warning${widget.count == 1 ? '' : 's'}',
            style: TextStyle(
              fontFamily: widget.theme.navFontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: color,
              decoration:
                  _hovering && widget.onTap != null ? TextDecoration.underline : null,
              decorationColor: color,
            ),
          ),
        ),
      ],
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

class _TimeRow extends StatelessWidget {
  const _TimeRow({required this.time, required this.theme});

  final String time;
  final NavToggleTheme theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '\u{1F551}',
          style: TextStyle(fontSize: 12, color: theme.textDim),
        ),
        const SizedBox(width: 6),
        Text(
          time,
          style: TextStyle(
            fontFamily: theme.monoFontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: theme.text,
          ),
        ),
      ],
    );
  }
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
