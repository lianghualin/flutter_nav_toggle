import 'package:flutter/widgets.dart';
import '../models/nav_item.dart';
import '../theme/nav_toggle_theme.dart';

/// The horizontal tab bar panel — extends from button's right edge to screen right.
class TabBarPanel extends StatelessWidget {
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
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0)
              Container(
                width: 1,
                height: 24,
                color: theme.border,
              ),
            _TabItem(
              item: items[i],
              isSelected: items[i].id == selectedId,
              onTap: () => onItemSelected(items[i].id),
              theme: theme,
            ),
          ],
          const Spacer(),
          if (onAddPressed != null)
            _AddButton(onTap: onAddPressed!, theme: theme),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _TabItem extends StatefulWidget {
  const _TabItem({
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
  State<_TabItem> createState() => _TabItemState();
}

class _TabItemState extends State<_TabItem> {
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
      bg = const Color(0xFF1E2030);
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(theme.itemRadius),
          ),
          child: Center(
            child: Text(
              widget.item.label.toUpperCase(),
              style: TextStyle(
                fontFamily: theme.navFontFamily,
                fontWeight: FontWeight.w700,
                fontSize: 12,
                letterSpacing: 1.5,
                color: textColor,
              ),
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
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
