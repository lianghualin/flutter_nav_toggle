import 'package:flutter/widgets.dart';

/// The type of transition used when switching between pages.
enum PageTransitionType {
  /// Simple opacity crossfade.
  fade,

  /// Horizontal slide (new page slides in from the right).
  slideHorizontal,

  /// Material fade-through: old page fades out, new page fades in with scale.
  fadeThrough,
}

/// Returns an [AnimatedSwitcher] transition builder for the given type.
AnimatedSwitcherTransitionBuilder pageTransitionBuilder(
  PageTransitionType type,
) {
  switch (type) {
    case PageTransitionType.fade:
      return (child, animation) => FadeTransition(
            opacity: animation,
            child: child,
          );
    case PageTransitionType.slideHorizontal:
      return (child, animation) => SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            )),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
    case PageTransitionType.fadeThrough:
      return (child, animation) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 0.5),
          ),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
            ),
            child: child,
          ),
        );
      };
  }
}
