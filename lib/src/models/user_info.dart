import 'dart:ui';

/// User information displayed in the navigation panels.
class UserInfo {
  const UserInfo({
    required this.name,
    this.role,
    this.onTap,
  });

  final String name;
  final String? role;
  final VoidCallback? onTap;

  /// Returns the user's initials (up to 2 characters).
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '';
  }
}
