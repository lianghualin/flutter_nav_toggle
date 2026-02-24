import 'package:flutter/widgets.dart';
import '../models/nav_item.dart';
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
    this.onAddPressed,
  });

  final List<NavItem> items;
  final String selectedId;
  final ValueChanged<String> onItemSelected;
  final VoidCallback? onAddPressed;

  @override
  State<TabBarPanel> createState() => _TabBarPanelState();
}

class _TabBarPanelState extends State<TabBarPanel> {
  String? _openDropdownId;
  OverlayEntry? _overlayEntry;
  final Map<String, LayerLink> _layerLinks = {};

  @override
  void initState() {
    super.initState();
    _ensureLayerLinks();
  }

  @override
  void didUpdateWidget(TabBarPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _ensureLayerLinks();
    // Rebuild overlay if selection changed while dropdown is open
    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
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
          const Spacer(),
          if (widget.onAddPressed != null)
            _AddButton(onTap: widget.onAddPressed!, theme: theme),
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

class _AddButton extends StatefulWidget {
  const _AddButton({required this.onTap, required this.theme});

  final VoidCallback onTap;
  final NavToggleTheme theme;

  @override
  State<_AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<_AddButton> {
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
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _hovering
                ? widget.theme.accent.withValues(alpha: 0.1)
                : const Color(0x00000000),
            borderRadius: BorderRadius.circular(widget.theme.itemRadius),
          ),
          child: Center(
            child: Text(
              '+',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color:
                    _hovering ? widget.theme.accent : widget.theme.textDim,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
