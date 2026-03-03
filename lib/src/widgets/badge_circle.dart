import 'package:flutter/widgets.dart';
import '../theme/nav_toggle_theme.dart';

/// A small circular badge showing a count. Internal widget, not exported.
class BadgeCircle extends StatelessWidget {
  const BadgeCircle({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    final theme = NavToggleTheme.of(context);
    final label = count > 99 ? '99+' : '$count';

    return Container(
      constraints: BoxConstraints(
        minWidth: theme.badgeSize,
        minHeight: theme.badgeSize,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: theme.badgeColor,
        borderRadius: BorderRadius.circular(theme.badgeSize / 2),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontFamily: theme.monoFontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 10,
            color: theme.badgeTextColor,
            height: 1,
          ),
        ),
      ),
    );
  }
}
