import 'package:flutter/widgets.dart';
import '../models/nav_item.dart';
import '../theme/nav_toggle_theme.dart';

/// The sidebar navigation panel — 200px wide, fills height below the button.
///
/// Supports hierarchical items: parent items with [NavItem.children] can be
/// expanded/collapsed to reveal child items.
class SidebarPanel extends StatefulWidget {
  const SidebarPanel({
    super.key,
    required this.items,
    required this.selectedId,
    required this.onItemSelected,
  });

  final List<NavItem> items;
  final String selectedId;
  final ValueChanged<String> onItemSelected;

  @override
  State<SidebarPanel> createState() => _SidebarPanelState();
}

class _SidebarPanelState extends State<SidebarPanel> {
  final Set<String> _expandedIds = {};

  @override
  void initState() {
    super.initState();
    // Auto-expand groups that contain the selected item.
    _autoExpandSelected();
  }

  @override
  void didUpdateWidget(SidebarPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedId != widget.selectedId) {
      _autoExpandSelected();
    }
  }

  void _autoExpandSelected() {
    for (final item in widget.items) {
      if (item.hasChildren &&
          item.children!.any((c) => c.id == widget.selectedId)) {
        _expandedIds.add(item.id);
      }
    }
  }

  void _toggleExpanded(String id) {
    setState(() {
      if (_expandedIds.contains(id)) {
        _expandedIds.remove(id);
      } else {
        _expandedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = NavToggleTheme.of(context);

    return Container(
      width: theme.sidebarWidth,
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              children: [
                for (int i = 0; i < widget.items.length; i++) ...[
                  if (i > 0) const SizedBox(height: 2),
                  _buildItem(widget.items[i], theme),
                ],
              ],
            ),
          ),
          // Bottom status area
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'v1.0.0',
              style: TextStyle(
                fontFamily: theme.monoFontFamily,
                fontSize: 11,
                color: theme.textDim,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(NavItem item, NavToggleTheme theme) {
    if (item.hasChildren) {
      final isExpanded = _expandedIds.contains(item.id);
      return _ExpandableGroup(
        item: item,
        isExpanded: isExpanded,
        selectedId: widget.selectedId,
        onToggleExpanded: () => _toggleExpanded(item.id),
        onChildSelected: widget.onItemSelected,
        theme: theme,
      );
    }
    return _SidebarItem(
      item: item,
      isSelected: item.id == widget.selectedId,
      onTap: () => widget.onItemSelected(item.id),
      theme: theme,
    );
  }
}

/// An expandable group header with animated children list.
class _ExpandableGroup extends StatefulWidget {
  const _ExpandableGroup({
    required this.item,
    required this.isExpanded,
    required this.selectedId,
    required this.onToggleExpanded,
    required this.onChildSelected,
    required this.theme,
  });

  final NavItem item;
  final bool isExpanded;
  final String selectedId;
  final VoidCallback onToggleExpanded;
  final ValueChanged<String> onChildSelected;
  final NavToggleTheme theme;

  @override
  State<_ExpandableGroup> createState() => _ExpandableGroupState();
}

class _ExpandableGroupState extends State<_ExpandableGroup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _expandController;
  late final Animation<double> _expandAnimation;
  late final Animation<double> _rotateAnimation;
  bool _hovering = false;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: widget.isExpanded ? 1.0 : 0.0,
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeOut,
    );
    _rotateAnimation = Tween<double>(begin: -0.25, end: 0.0).animate(
      CurvedAnimation(parent: _expandController, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(_ExpandableGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final hasSelectedChild =
        widget.item.children!.any((c) => c.id == widget.selectedId);

    Color bg;
    Color textColor;

    if (hasSelectedChild && !widget.isExpanded) {
      bg = theme.accent.withValues(alpha: 0.05);
      textColor = theme.accent;
    } else if (_hovering) {
      bg = theme.hoverSurface;
      textColor = theme.text;
    } else {
      bg = const Color(0x00000000);
      textColor = theme.textDim;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Group header
        MouseRegion(
          onEnter: (_) => setState(() => _hovering = true),
          onExit: (_) => setState(() => _hovering = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: widget.onToggleExpanded,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(theme.itemRadius),
              ),
              child: Row(
                children: [
                  Icon(widget.item.icon, size: 18, color: textColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.item.label,
                      style: TextStyle(
                        fontFamily: theme.navFontFamily,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: textColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  RotationTransition(
                    turns: _rotateAnimation,
                    child: Text(
                      '▼',
                      style: TextStyle(fontSize: 8, color: textColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Animated children list
        SizeTransition(
          sizeFactor: _expandAnimation,
          axisAlignment: -1.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final child in widget.item.children!)
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: _SidebarItem(
                    item: child,
                    isSelected: child.id == widget.selectedId,
                    onTap: () => widget.onChildSelected(child.id),
                    theme: theme,
                    isChild: true,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SidebarItem extends StatefulWidget {
  const _SidebarItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.theme,
    this.isChild = false,
  });

  final NavItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final NavToggleTheme theme;
  final bool isChild;

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
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

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: widget.isChild ? 8 : 10,
          ),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(theme.itemRadius),
          ),
          child: Row(
            children: [
              if (widget.isChild) ...[
                Text(
                  '·',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                  ),
                ),
                const SizedBox(width: 10),
              ] else ...[
                Icon(widget.item.icon, size: 18, color: textColor),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  widget.item.label,
                  style: TextStyle(
                    fontFamily: theme.navFontFamily,
                    fontWeight:
                        widget.isChild ? FontWeight.w600 : FontWeight.w700,
                    fontSize: widget.isChild ? 13 : 14,
                    color: textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
