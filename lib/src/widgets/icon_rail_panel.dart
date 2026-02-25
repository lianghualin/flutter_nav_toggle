import 'package:flutter/widgets.dart';
import '../models/nav_item.dart';
import '../models/system_status.dart';
import '../models/user_info.dart';
import '../theme/nav_toggle_theme.dart';

/// A narrow vertical icon rail — shows only nav item icons.
///
/// Parent items with children show a small chevron indicator and open a
/// flyout popup to the right via [Overlay] + [CompositedTransformFollower].
class IconRailPanel extends StatefulWidget {
  const IconRailPanel({
    super.key,
    required this.items,
    required this.selectedId,
    required this.onItemSelected,
    this.systemStatus,
    this.userInfo,
  });

  final List<NavItem> items;
  final String selectedId;
  final ValueChanged<String> onItemSelected;
  final SystemStatus? systemStatus;
  final UserInfo? userInfo;

  @override
  State<IconRailPanel> createState() => _IconRailPanelState();
}

class _IconRailPanelState extends State<IconRailPanel> {
  String? _openFlyoutId;
  OverlayEntry? _overlayEntry;
  final Map<String, LayerLink> _layerLinks = {};

  @override
  void initState() {
    super.initState();
    _ensureLayerLinks();
  }

  @override
  void didUpdateWidget(IconRailPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _ensureLayerLinks();
    if (_overlayEntry != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _overlayEntry?.markNeedsBuild();
      });
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _ensureLayerLinks() {
    for (final item in widget.items) {
      if (item.hasChildren) {
        _layerLinks.putIfAbsent(item.id, () => LayerLink());
      }
    }
  }

  void _onItemTap(NavItem item) {
    if (item.hasChildren) {
      if (_openFlyoutId == item.id) {
        _closeFlyout();
      } else {
        _openFlyout(item);
      }
    } else {
      _closeFlyout();
      widget.onItemSelected(item.id);
    }
  }

  void _openFlyout(NavItem item) {
    _removeOverlay();
    setState(() => _openFlyoutId = item.id);

    final theme = NavToggleTheme.of(context);

    _overlayEntry = OverlayEntry(
      builder: (_) => _FlyoutOverlay(
        link: _layerLinks[item.id]!,
        items: item.children!,
        selectedId: widget.selectedId,
        theme: theme,
        onItemSelected: (childId) {
          _closeFlyout();
          widget.onItemSelected(childId);
        },
        onClose: _closeFlyout,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _closeFlyout() {
    _removeOverlay();
    if (_openFlyoutId != null) {
      setState(() => _openFlyoutId = null);
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  bool _parentContainsSelected(NavItem item) {
    if (!item.hasChildren) return false;
    return item.children!.any((c) => c.id == widget.selectedId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = NavToggleTheme.of(context);

    return Container(
      width: theme.railWidth,
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border(
          right: BorderSide(color: theme.border, width: 1),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                for (int i = 0; i < widget.items.length; i++) ...[
                  if (i > 0) const SizedBox(height: 2),
                  _buildRailItem(widget.items[i], theme),
                ],
              ],
            ),
          ),
          if (widget.systemStatus != null)
            _RailStatusCircles(status: widget.systemStatus!),
          if (widget.userInfo != null)
            _RailUserAvatar(userInfo: widget.userInfo!, theme: theme),
        ],
      ),
    );
  }

  Widget _buildRailItem(NavItem item, NavToggleTheme theme) {
    final isSelected = item.id == widget.selectedId ||
        _parentContainsSelected(item);
    final isFlyoutOpen = _openFlyoutId == item.id;

    Widget railItem = _RailItem(
      item: item,
      isSelected: isSelected,
      isFlyoutOpen: isFlyoutOpen,
      onTap: () => _onItemTap(item),
      theme: theme,
    );

    if (item.hasChildren) {
      railItem = CompositedTransformTarget(
        link: _layerLinks[item.id]!,
        child: railItem,
      );
    }

    return railItem;
  }
}

class _RailItem extends StatefulWidget {
  const _RailItem({
    required this.item,
    required this.isSelected,
    required this.isFlyoutOpen,
    required this.onTap,
    required this.theme,
  });

  final NavItem item;
  final bool isSelected;
  final bool isFlyoutOpen;
  final VoidCallback onTap;
  final NavToggleTheme theme;

  @override
  State<_RailItem> createState() => _RailItemState();
}

class _RailItemState extends State<_RailItem> {
  bool _hovering = false;
  OverlayEntry? _tooltipEntry;
  final LayerLink _tooltipLink = LayerLink();

  @override
  void dispose() {
    _hideTooltip();
    super.dispose();
  }

  void _showTooltip() {
    if (_tooltipEntry != null) return;
    final theme = widget.theme;
    _tooltipEntry = OverlayEntry(
      builder: (_) => CompositedTransformFollower(
        link: _tooltipLink,
        targetAnchor: Alignment.centerRight,
        followerAnchor: Alignment.centerLeft,
        offset: const Offset(8, 0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: theme.border, width: 1),
            ),
            child: Text(
              widget.item.label,
              style: TextStyle(
                fontFamily: theme.navFontFamily,
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: theme.text,
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_tooltipEntry!);
  }

  void _hideTooltip() {
    _tooltipEntry?.remove();
    _tooltipEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    Color bg;
    Color iconColor;

    if (widget.isSelected || widget.isFlyoutOpen) {
      bg = theme.accent.withValues(alpha: 0.1);
      iconColor = theme.accent;
    } else if (_hovering) {
      bg = theme.hoverSurface;
      iconColor = theme.text;
    } else {
      bg = const Color(0x00000000);
      iconColor = theme.textDim;
    }

    return CompositedTransformTarget(
      link: _tooltipLink,
      child: MouseRegion(
        onEnter: (_) {
          setState(() => _hovering = true);
          if (!widget.isFlyoutOpen) _showTooltip();
        },
        onExit: (_) {
          setState(() => _hovering = false);
          _hideTooltip();
        },
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            _hideTooltip();
            widget.onTap();
          },
          child: Container(
            height: theme.buttonHeight,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(theme.itemRadius),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(widget.item.icon, size: 20, color: iconColor),
                if (widget.item.hasChildren)
                  Positioned(
                    right: 6,
                    child: Text(
                      '\u203A',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: iconColor.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Flyout overlay for rail parent items — appears to the right.
class _FlyoutOverlay extends StatelessWidget {
  const _FlyoutOverlay({
    required this.link,
    required this.items,
    required this.selectedId,
    required this.theme,
    required this.onItemSelected,
    required this.onClose,
  });

  final LayerLink link;
  final List<NavItem> items;
  final String selectedId;
  final NavToggleTheme theme;
  final ValueChanged<String> onItemSelected;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: onClose,
            behavior: HitTestBehavior.opaque,
            child: const ColoredBox(color: Color(0x00000000)),
          ),
        ),
        CompositedTransformFollower(
          link: link,
          targetAnchor: Alignment.centerRight,
          followerAnchor: Alignment.centerLeft,
          offset: const Offset(4, 0),
          child: _FlyoutMenu(
            items: items,
            selectedId: selectedId,
            onItemSelected: onItemSelected,
            theme: theme,
          ),
        ),
      ],
    );
  }
}

class _FlyoutMenu extends StatelessWidget {
  const _FlyoutMenu({
    required this.items,
    required this.selectedId,
    required this.onItemSelected,
    required this.theme,
  });

  final List<NavItem> items;
  final String selectedId;
  final ValueChanged<String> onItemSelected;
  final NavToggleTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 120),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(theme.itemRadius),
        border: Border.all(color: theme.border, width: 1),
      ),
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (int i = 0; i < items.length; i++) ...[
              if (i > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Container(height: 1, color: theme.border),
                ),
              _FlyoutItem(
                item: items[i],
                isSelected: items[i].id == selectedId,
                onTap: () => onItemSelected(items[i].id),
                theme: theme,
                isFirst: i == 0,
                isLast: i == items.length - 1,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FlyoutItem extends StatefulWidget {
  const _FlyoutItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.theme,
    required this.isFirst,
    required this.isLast,
  });

  final NavItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final NavToggleTheme theme;
  final bool isFirst;
  final bool isLast;

  @override
  State<_FlyoutItem> createState() => _FlyoutItemState();
}

class _FlyoutItemState extends State<_FlyoutItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    Color bg;
    Color textColor;

    if (widget.isSelected) {
      bg = theme.accent.withValues(alpha: 0.1);
      textColor = theme.accent;
    } else if (_hovering) {
      bg = theme.hoverSurface;
      textColor = theme.text;
    } else {
      bg = const Color(0x00000000);
      textColor = theme.textDim;
    }

    final radius = theme.itemRadius;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.vertical(
              top: widget.isFirst ? Radius.circular(radius) : Radius.zero,
              bottom: widget.isLast ? Radius.circular(radius) : Radius.zero,
            ),
          ),
          child: Text(
            widget.item.label,
            style: TextStyle(
              fontFamily: theme.navFontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}

/// Colored circles showing CPU/MEM/DISK percentage and warning count.
class _RailStatusCircles extends StatelessWidget {
  const _RailStatusCircles({required this.status});

  final SystemStatus status;

  static const _green = Color(0xFF10B981);
  static const _amber = Color(0xFFF59E0B);
  static const _red = Color(0xFFEF4444);

  static Color _thresholdColor(double value) {
    if (value >= 0.8) return _red;
    if (value >= 0.6) return _amber;
    return _green;
  }

  @override
  Widget build(BuildContext context) {
    final theme = NavToggleTheme.of(context);
    final hasWarnings = status.warnings > 0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: theme.border, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StatusCircle(
            label: 'CPU ${(status.cpu * 100).round()}%',
            text: '${(status.cpu * 100).round()}',
            color: _thresholdColor(status.cpu),
            theme: theme,
          ),
          const SizedBox(height: 6),
          _StatusCircle(
            label: 'MEM ${(status.memory * 100).round()}%',
            text: '${(status.memory * 100).round()}',
            color: _thresholdColor(status.memory),
            theme: theme,
          ),
          const SizedBox(height: 6),
          _StatusCircle(
            label: 'DISK ${(status.disk * 100).round()}%',
            text: '${(status.disk * 100).round()}',
            color: _thresholdColor(status.disk),
            theme: theme,
          ),
          const SizedBox(height: 6),
          _StatusCircle(
            label: '${status.warnings} warning${status.warnings == 1 ? '' : 's'}',
            text: '\u26A0${status.warnings}',
            color: hasWarnings ? _amber : theme.textDim,
            theme: theme,
          ),
        ],
      ),
    );
  }
}

/// A single 28x28 status circle with a number inside and tooltip on hover.
class _StatusCircle extends StatefulWidget {
  const _StatusCircle({
    required this.label,
    required this.text,
    required this.color,
    required this.theme,
  });

  final String label;
  final String text;
  final Color color;
  final NavToggleTheme theme;

  @override
  State<_StatusCircle> createState() => _StatusCircleState();
}

class _StatusCircleState extends State<_StatusCircle> {
  bool _hovering = false;
  OverlayEntry? _tooltipEntry;
  final LayerLink _tooltipLink = LayerLink();

  @override
  void dispose() {
    _hideTooltip();
    super.dispose();
  }

  void _showTooltip() {
    if (_tooltipEntry != null) return;
    final theme = widget.theme;
    _tooltipEntry = OverlayEntry(
      builder: (_) => CompositedTransformFollower(
        link: _tooltipLink,
        targetAnchor: Alignment.centerRight,
        followerAnchor: Alignment.centerLeft,
        offset: const Offset(8, 0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: theme.border, width: 1),
            ),
            child: Text(
              widget.label,
              style: TextStyle(
                fontFamily: theme.navFontFamily,
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: theme.text,
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_tooltipEntry!);
  }

  void _hideTooltip() {
    _tooltipEntry?.remove();
    _tooltipEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    final circleColor = _hovering
        ? widget.color
        : widget.color.withValues(alpha: 0.85);

    return CompositedTransformTarget(
      link: _tooltipLink,
      child: MouseRegion(
        onEnter: (_) {
          setState(() => _hovering = true);
          _showTooltip();
        },
        onExit: (_) {
          setState(() => _hovering = false);
          _hideTooltip();
        },
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: circleColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              widget.text,
              style: TextStyle(
                fontFamily: widget.theme.monoFontFamily,
                fontWeight: FontWeight.w700,
                fontSize: 9,
                color: const Color(0xFFFFFFFF),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact user avatar for the icon rail — 28x28 circle with initials.
class _RailUserAvatar extends StatelessWidget {
  const _RailUserAvatar({required this.userInfo, required this.theme});

  final UserInfo userInfo;
  final NavToggleTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: theme.border, width: 1),
        ),
      ),
      child: Center(
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: theme.accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              userInfo.initials,
              style: TextStyle(
                fontFamily: theme.navFontFamily,
                fontWeight: FontWeight.w700,
                fontSize: 11,
                color: theme.accent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
