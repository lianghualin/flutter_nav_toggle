import 'package:flutter/widgets.dart';
import '../models/nav_item.dart';
import '../models/system_status.dart';
import '../models/user_info.dart';
import '../theme/nav_toggle_theme.dart';

/// The horizontal tab bar panel — extends from button's right edge to screen right.
///
/// Supports hierarchical items: items with [NavItem.children] show a ▾ indicator
/// and open a dropdown menu that hangs directly below the parent tab.
/// The dropdown is rendered via [Overlay] so it is not clipped by ancestor widgets.
class TabBarPanel extends StatefulWidget {
  const TabBarPanel({
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
  State<TabBarPanel> createState() => _TabBarPanelState();
}

class _TabBarPanelState extends State<TabBarPanel> {
  String? _openDropdownId;
  OverlayEntry? _overlayEntry;
  final Map<String, LayerLink> _layerLinks = {};
  final ScrollController _scrollController = ScrollController();
  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  @override
  void initState() {
    super.initState();
    _ensureLayerLinks();
    _scrollController.addListener(_updateScrollIndicators);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateScrollIndicators();
    });
  }

  @override
  void didUpdateWidget(TabBarPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _ensureLayerLinks();
    // Rebuild overlay after the current frame to avoid markNeedsBuild
    // during the build phase (the OverlayEntry lives outside our ancestor
    // chain, so it cannot be marked dirty mid-build).
    if (_overlayEntry != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _overlayEntry?.markNeedsBuild();
      });
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    _scrollController.removeListener(_updateScrollIndicators);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateScrollIndicators() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    final left = pos.pixels > 0;
    final right = pos.pixels < pos.maxScrollExtent;
    if (left != _canScrollLeft || right != _canScrollRight) {
      setState(() {
        _canScrollLeft = left;
        _canScrollRight = right;
      });
    }
  }

  void _scrollBy(double delta) {
    if (!_scrollController.hasClients) return;
    final target = (_scrollController.offset + delta).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
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
      if (_openDropdownId == item.id) {
        _closeDropdown();
      } else {
        _openDropdown(item);
      }
    } else {
      _closeDropdown();
      widget.onItemSelected(item.id);
    }
  }

  void _openDropdown(NavItem item) {
    _removeOverlay();
    setState(() => _openDropdownId = item.id);

    final theme = NavToggleTheme.of(context);

    _overlayEntry = OverlayEntry(
      builder: (_) => _DropdownOverlay(
        link: _layerLinks[item.id]!,
        items: item.children!,
        selectedId: widget.selectedId,
        theme: theme,
        onItemSelected: (childId) {
          _closeDropdown();
          widget.onItemSelected(childId);
        },
        onClose: _closeDropdown,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _closeDropdown() {
    _removeOverlay();
    if (_openDropdownId != null) {
      setState(() => _openDropdownId = null);
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

  /// Returns the selected child's label if one is active, otherwise the item's own label.
  String _displayLabelFor(NavItem item) {
    if (!item.hasChildren) return item.label;
    for (final child in item.children!) {
      if (child.id == widget.selectedId) return child.label;
    }
    return item.label;
  }

  @override
  Widget build(BuildContext context) {
    final theme = NavToggleTheme.of(context);

    return Container(
      height: theme.buttonHeight,
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border(
          bottom: BorderSide(color: theme.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          if (_canScrollLeft)
            _ScrollArrow(
              icon: '\u25C0',
              onTap: () => _scrollBy(-120),
              theme: theme,
            ),
          Expanded(
            child: NotificationListener<ScrollMetricsNotification>(
              onNotification: (_) {
                _updateScrollIndicators();
                return false;
              },
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (int i = 0; i < widget.items.length; i++) ...[
                      if (i > 0)
                        Container(
                          width: 1,
                          height: 24,
                          color: theme.border,
                        ),
                      _TabItem(
                        item: widget.items[i],
                        displayLabel: _displayLabelFor(widget.items[i]),
                        isSelected: widget.items[i].id == widget.selectedId ||
                            _parentContainsSelected(widget.items[i]),
                        isDropdownOpen: _openDropdownId == widget.items[i].id,
                        onTap: () => _onItemTap(widget.items[i]),
                        theme: theme,
                        layerLink: _layerLinks[widget.items[i].id],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (_canScrollRight)
            _ScrollArrow(
              icon: '\u25B6',
              onTap: () => _scrollBy(120),
              theme: theme,
            ),
          if (widget.systemStatus != null)
            _StatusChips(status: widget.systemStatus!, theme: theme),
          if (widget.userInfo != null)
            _UserChip(userInfo: widget.userInfo!, theme: theme),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

/// Overlay widget that shows the dropdown menu and a tap-to-close backdrop.
class _DropdownOverlay extends StatelessWidget {
  const _DropdownOverlay({
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
        // Tap-to-close backdrop (full screen, transparent)
        Positioned.fill(
          child: GestureDetector(
            onTap: onClose,
            behavior: HitTestBehavior.opaque,
            child: const ColoredBox(color: Color(0x00000000)),
          ),
        ),
        // Dropdown positioned below the parent tab
        CompositedTransformFollower(
          link: link,
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          offset: const Offset(0, 2),
          child: _DropdownMenu(
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

class _TabItem extends StatefulWidget {
  const _TabItem({
    required this.item,
    required this.displayLabel,
    required this.isSelected,
    required this.isDropdownOpen,
    required this.onTap,
    required this.theme,
    this.layerLink,
  });

  final NavItem item;
  final String displayLabel;
  final bool isSelected;
  final bool isDropdownOpen;
  final VoidCallback onTap;
  final NavToggleTheme theme;
  final LayerLink? layerLink;

  @override
  State<_TabItem> createState() => _TabItemState();
}

class _TabItemState extends State<_TabItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    Color bg;
    Color textColor;

    if (widget.isSelected || widget.isDropdownOpen) {
      bg = theme.accent.withValues(alpha: 0.1);
      textColor = theme.accent;
    } else if (_hovering) {
      bg = theme.hoverSurface;
      textColor = theme.text;
    } else {
      bg = const Color(0x00000000);
      textColor = theme.textDim;
    }

    Widget tab = MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(theme.itemRadius),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.displayLabel.toUpperCase(),
                  style: TextStyle(
                    fontFamily: theme.navFontFamily,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 1.5,
                    color: textColor,
                  ),
                ),
                if (widget.item.hasChildren) ...[
                  const SizedBox(width: 4),
                  Text(
                    '▼',
                    style: TextStyle(
                      fontSize: 7,
                      color: textColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    if (widget.layerLink != null) {
      tab = CompositedTransformTarget(
        link: widget.layerLink!,
        child: tab,
      );
    }

    return tab;
  }
}

class _DropdownMenu extends StatelessWidget {
  const _DropdownMenu({
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
      constraints: const BoxConstraints(minWidth: 140),
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
              _DropdownItem(
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

class _DropdownItem extends StatefulWidget {
  const _DropdownItem({
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
  State<_DropdownItem> createState() => _DropdownItemState();
}

class _DropdownItemState extends State<_DropdownItem> {
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

class _StatusChips extends StatelessWidget {
  const _StatusChips({required this.status, required this.theme});

  final SystemStatus status;
  final NavToggleTheme theme;

  static const _green = Color(0xFF10B981);
  static const _amber = Color(0xFFF59E0B);
  static const _red = Color(0xFFEF4444);

  static Color _chipColor(double value) {
    if (value >= 0.8) return _red;
    if (value >= 0.6) return _amber;
    return _green;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Chip(label: 'C', value: '${(status.cpu * 100).round()}%', color: _chipColor(status.cpu), theme: theme),
        const SizedBox(width: 4),
        _Chip(label: 'M', value: '${(status.memory * 100).round()}%', color: _chipColor(status.memory), theme: theme),
        const SizedBox(width: 4),
        _Chip(label: 'D', value: '${(status.disk * 100).round()}%', color: _chipColor(status.disk), theme: theme),
        const SizedBox(width: 4),
        _WarningChip(count: status.warnings, theme: theme),
        const SizedBox(width: 8),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.value,
    required this.color,
    required this.theme,
  });

  final String label;
  final String value;
  final Color color;
  final NavToggleTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: theme.monoFontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 10,
              color: color,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            value,
            style: TextStyle(
              fontFamily: theme.monoFontFamily,
              fontWeight: FontWeight.w500,
              fontSize: 10,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _WarningChip extends StatelessWidget {
  const _WarningChip({required this.count, required this.theme});

  final int count;
  final NavToggleTheme theme;

  @override
  Widget build(BuildContext context) {
    final hasWarnings = count > 0;
    final color = hasWarnings ? const Color(0xFFF59E0B) : theme.textDim;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '\u26A0',
            style: TextStyle(fontSize: 9, color: color),
          ),
          const SizedBox(width: 2),
          Text(
            '$count',
            style: TextStyle(
              fontFamily: theme.monoFontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 10,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _UserChip extends StatelessWidget {
  const _UserChip({required this.userInfo, required this.theme});

  final UserInfo userInfo;
  final NavToggleTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: theme.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: theme.accent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Center(
              child: Text(
                userInfo.initials,
                style: TextStyle(
                  fontFamily: theme.navFontFamily,
                  fontWeight: FontWeight.w700,
                  fontSize: 9,
                  color: theme.accent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScrollArrow extends StatefulWidget {
  const _ScrollArrow({
    required this.icon,
    required this.onTap,
    required this.theme,
  });

  final String icon;
  final VoidCallback onTap;
  final NavToggleTheme theme;

  @override
  State<_ScrollArrow> createState() => _ScrollArrowState();
}

class _ScrollArrowState extends State<_ScrollArrow> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 24,
          height: 24,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: _hovering
                ? widget.theme.hoverSurface
                : const Color(0x00000000),
            borderRadius: BorderRadius.circular(widget.theme.itemRadius),
          ),
          child: Center(
            child: Text(
              widget.icon,
              style: TextStyle(
                fontSize: 8,
                color: _hovering ? widget.theme.text : widget.theme.textDim,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
