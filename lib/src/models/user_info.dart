import 'dart:ui';

import 'user_menu_item.dart';

/// User information displayed in the navigation panels.
class UserInfo {
  const UserInfo({
    required this.name,
    this.role,
    this.onTap,
    this.menuItems,
  });

  final String name;
  final String? role;
  final VoidCallback? onTap;

  /// Optional flyout menu items. When non-empty, tapping the avatar
  /// opens a flyout popup instead of calling [onTap].
  final List<UserMenuItem>? menuItems;

  /// Whether this user info should show a flyout menu on tap.
  bool get hasMenu => menuItems != null && menuItems!.isNotEmpty;

  /// Returns the user's initials (up to 2 characters).
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '';
  }
}
