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
    this.badge,
    this.iconColor,
  });

  final String id;
  final String label;
  final IconData icon;
  final List<NavItem>? children;
  final int? badge;

  /// Optional per-item icon color. When set, the icon always displays in this
  /// color (selection is indicated by the background highlight instead).
  /// When null, the icon color follows the theme (accent when selected,
  /// textDim when idle).
  final Color? iconColor;

  /// Whether this item has child items.
  bool get hasChildren => children != null && children!.isNotEmpty;

  /// Whether this item has a badge count > 0.
  bool get hasBadge => badge != null && badge! > 0;

  /// Aggregate badge count from children (if any), plus own badge.
  int get aggregateBadge {
    int total = badge ?? 0;
    if (hasChildren) {
      for (final child in children!) {
        total += child.badge ?? 0;
      }
    }
    return total;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NavItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
