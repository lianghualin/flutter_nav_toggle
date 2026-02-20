import 'package:flutter/widgets.dart';

/// A single navigation item with an id, label, and icon.
class NavItem {
  const NavItem({
    required this.id,
    required this.label,
    required this.icon,
  });

  final String id;
  final String label;
  final IconData icon;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NavItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
