import 'package:flutter/widgets.dart';
import '../models/user_info.dart';
import '../theme/nav_toggle_theme.dart';

/// Displays user avatar, name, and optional role at the sidebar bottom.
class UserInfoPanel extends StatelessWidget {
  const UserInfoPanel({super.key, required this.userInfo});

  final UserInfo userInfo;

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
          Expanded(
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
    );
  }
}
