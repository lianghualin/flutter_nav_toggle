import 'package:flutter/widgets.dart';
import '../models/user_info.dart';
import '../theme/nav_toggle_theme.dart';

/// Displays user avatar, name, and optional role at the sidebar bottom.
class UserInfoPanel extends StatefulWidget {
  const UserInfoPanel({super.key, required this.userInfo});

  final UserInfo userInfo;

  @override
  State<UserInfoPanel> createState() => _UserInfoPanelState();
}

class _UserInfoPanelState extends State<UserInfoPanel> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = NavToggleTheme.of(context);
    final hasTap = widget.userInfo.onTap != null;

    Widget content = Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: BoxDecoration(
        color: _hovering && hasTap
            ? theme.hoverSurface
            : const Color(0x00000000),
        border: Border(
          top: BorderSide(color: theme.border, width: 1),
        ),
      ),
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
                widget.userInfo.initials,
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.userInfo.name,
                  style: TextStyle(
                    fontFamily: theme.navFontFamily,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: theme.text,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.userInfo.role != null)
                  Text(
                    widget.userInfo.role!,
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
    );

    if (hasTap) {
      content = MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.userInfo.onTap,
          child: content,
        ),
      );
    }

    return content;
  }
}
