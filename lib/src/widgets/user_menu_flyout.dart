import 'package:flutter/widgets.dart';
import '../models/user_info.dart';
import '../models/user_menu_item.dart';
import '../theme/nav_toggle_theme.dart';

/// Shared flyout card content for the user menu popup.
///
/// Shows avatar + name + role header, divider, and a list of [UserMenuItem]
/// rows. Used by sidebar, icon rail, and tab bar panels.
class UserMenuFlyout extends StatelessWidget {
  const UserMenuFlyout({
    super.key,
    required this.userInfo,
    required this.theme,
    required this.onClose,
    this.showHeader = true,
  });

  final UserInfo userInfo;
  final NavToggleTheme theme;
  final VoidCallback onClose;

  /// Whether to show the avatar + name + role header.
  /// Set to false when the info is already visible (e.g. sidebar).
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    final items = userInfo.menuItems ?? [];

    return Container(
      constraints: const BoxConstraints(minWidth: 180),
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
            if (showHeader) ...[
              // Header: avatar + name + role
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: theme.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          userInfo.initials,
                          style: TextStyle(
                            fontFamily: theme.navFontFamily,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: theme.accent,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            userInfo.name,
                            style: TextStyle(
                              fontFamily: theme.navFontFamily,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: theme.text,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (userInfo.role != null)
                            Text(
                              userInfo.role!,
                              style: TextStyle(
                                fontFamily: theme.navFontFamily,
                                fontWeight: FontWeight.w500,
                                fontSize: 11,
                                color: theme.textDim,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Divider
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Container(height: 1, color: theme.border),
              ),
            ],
            // Menu items
            for (int i = 0; i < items.length; i++) ...[
              if (i > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Container(height: 1, color: theme.border),
                ),
              _UserMenuItemRow(
                item: items[i],
                theme: theme,
                onClose: onClose,
                isFirst: i == 0 && !showHeader,
                isLast: i == items.length - 1,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _UserMenuItemRow extends StatefulWidget {
  const _UserMenuItemRow({
    required this.item,
    required this.theme,
    required this.onClose,
    required this.isFirst,
    required this.isLast,
  });

  final UserMenuItem item;
  final NavToggleTheme theme;
  final VoidCallback onClose;
  final bool isFirst;
  final bool isLast;

  @override
  State<_UserMenuItemRow> createState() => _UserMenuItemRowState();
}

class _UserMenuItemRowState extends State<_UserMenuItemRow> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    final bg = _hovering ? theme.hoverSurface : const Color(0x00000000);
    final textColor = _hovering ? theme.text : theme.textDim;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          widget.onClose();
          widget.item.onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.vertical(
              top: widget.isFirst
                  ? Radius.circular(theme.itemRadius)
                  : Radius.zero,
              bottom: widget.isLast
                  ? Radius.circular(theme.itemRadius)
                  : Radius.zero,
            ),
          ),
          child: Row(
            children: [
              if (widget.item.icon != null) ...[
                Icon(widget.item.icon, size: 16, color: textColor),
                const SizedBox(width: 10),
              ],
              Text(
                widget.item.label,
                style: TextStyle(
                  fontFamily: theme.navFontFamily,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
