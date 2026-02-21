import 'package:flutter/widgets.dart';

/// A single navigation item with an id, label, and icon.
///
/// Items can optionally have [children] to create hierarchical navigation.
/// In sidebar mode, parent items expand/collapse to show children.
/// In tab bar mode, parent items show a dropdown menu.
class NavItem {
  const NavItem({
    required this.id,
    required this.label,
    required this.icon,
    this.children,
  });

  final String id;
  final String label;
  final IconData icon;
  final List<NavItem>? children;

  /// Whether this item has child items.
  bool get hasChildren => children != null && children!.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NavItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
