import 'package:flutter/widgets.dart';

/// A single item in the user flyout menu.
class UserMenuItem {
  const UserMenuItem({
    required this.label,
    this.icon,
    required this.onTap,
  });

  final String label;
  final IconData? icon;
  final VoidCallback onTap;
}
