import 'package:flutter/widgets.dart';

/// Custom clipper that clips a sidebar panel.
/// Progress 0.0 = fully clipped (hidden), 1.0 = fully visible.
/// Clips vertically — reveals downward as progress increases.
class SidebarClipper extends CustomClipper<Rect> {
  SidebarClipper({required this.progress});

  final double progress;

  @override
  Rect getClip(Size size) {
    final visibleHeight = size.height * progress;
    return Rect.fromLTWH(0, 0, size.width, visibleHeight);
  }

  @override
  bool shouldReclip(SidebarClipper oldClipper) =>
      oldClipper.progress != progress;
}

/// Custom clipper that clips a tab bar panel.
/// Progress 0.0 = fully clipped (hidden), 1.0 = fully visible.
/// Clips horizontally — reveals rightward as progress increases.
class TabBarClipper extends CustomClipper<Rect> {
  TabBarClipper({required this.progress});

  final double progress;

  @override
  Rect getClip(Size size) {
    final visibleWidth = size.width * progress;
    return Rect.fromLTWH(0, 0, visibleWidth, size.height);
  }

  @override
  bool shouldReclip(TabBarClipper oldClipper) =>
      oldClipper.progress != progress;
}

/// Holds the phased CurvedAnimations derived from a single controller.
///
/// The total animation is divided into:
/// - Collapse phase (0.0 → collapseEnd): old panel shrinks
/// - Expand phase (collapseEnd → 1.0): new panel grows
class NavTransitionAnimations {
  NavTransitionAnimations({
    required AnimationController controller,
    required double collapseEnd,
    required Curve curve,
  })  : collapse = CurvedAnimation(
          parent: controller,
          curve: Interval(0.0, collapseEnd, curve: curve),
        ),
        expand = CurvedAnimation(
          parent: controller,
          curve: Interval(collapseEnd, 1.0, curve: curve),
        );

  final CurvedAnimation collapse;
  final CurvedAnimation expand;

  void dispose() {
    collapse.dispose();
    expand.dispose();
  }
}
