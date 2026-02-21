import 'package:flutter/widgets.dart';
import '../models/nav_item.dart';
import '../theme/nav_toggle_theme.dart';

/// The sidebar navigation panel — 200px wide, fills height below the button.
class SidebarPanel extends StatelessWidget {
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
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 2),
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = item.id == selectedId;
                return _SidebarItem(
                  item: item,
                  isSelected: isSelected,
                  onTap: () => onItemSelected(item.id),
                  theme: theme,
                );
              },
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
}

class _SidebarItem extends StatefulWidget {
  const _SidebarItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  final NavItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final NavToggleTheme theme;

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
    Color iconColor;

    if (widget.isSelected) {
      bg = theme.accent.withValues(alpha: 0.1);
      textColor = theme.accent;
      iconColor = theme.accent;
    } else if (_hovering) {
      bg = theme.hoverSurface;
      textColor = theme.text;
      iconColor = theme.text;
    } else {
      bg = const Color(0x00000000);
      textColor = theme.textDim;
      iconColor = theme.textDim;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(theme.itemRadius),
          ),
          child: Row(
            children: [
              Icon(widget.item.icon, size: 18, color: iconColor),
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
            ],
          ),
        ),
      ),
    );
  }
}
