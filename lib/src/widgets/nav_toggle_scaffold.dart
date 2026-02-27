import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../animation/nav_transition.dart';
import '../controller/nav_toggle_controller.dart';
import '../models/nav_item.dart';
import '../models/nav_mode.dart';
import '../models/system_status.dart';
import '../models/user_info.dart';
import '../theme/nav_toggle_theme.dart';
import 'icon_rail_panel.dart';
import 'sidebar_panel.dart';
import 'tab_bar_panel.dart';
import 'package:morphing_button/morphing_button.dart';

/// Top-level scaffold that manages the toggle button, sidebar/tab bar/icon rail
/// panels, content area, and all transition animations.
class NavToggleScaffold extends StatefulWidget {
  const NavToggleScaffold({
    super.key,
    required this.items,
    required this.child,
    this.theme,
    this.initialMode = NavMode.sidebar,
    this.initialSelectedId,
    this.onItemSelected,
    this.systemStatus,
    this.userInfo,
  });

  final List<NavItem> items;
  final Widget child;
  final NavToggleTheme? theme;
  final NavMode initialMode;
  final String? initialSelectedId;
  final ValueChanged<String>? onItemSelected;
  final SystemStatus? systemStatus;
  final UserInfo? userInfo;

  @override
  State<NavToggleScaffold> createState() => _NavToggleScaffoldState();
}

class _NavToggleScaffoldState extends State<NavToggleScaffold>
    with TickerProviderStateMixin {
  late final NavToggleController _controller;

  // Sidebar <-> TabBar animation
  late final AnimationController _animController;
  late NavTransitionAnimations _animations;
  bool _collapseHandled = false;

  // Sidebar <-> IconRail animation
  late final AnimationController _railAnimController;
  late final CurvedAnimation _railCurvedAnim;

  NavToggleTheme get _theme => widget.theme ?? const NavToggleTheme();

  @override
  void initState() {
    super.initState();
    _controller = NavToggleController(
      initialMode: widget.initialMode,
      initialSelectedId: widget.initialSelectedId ?? widget.items.first.id,
    );

    // Main sidebar<->tabBar animation controller
    _animController = AnimationController(
      vsync: this,
      duration: _theme.totalDuration,
    );

    _animations = NavTransitionAnimations(
      controller: _animController,
      collapseEnd: _theme.collapseEnd,
      curve: _theme.easeCurve,
    );

    _animController.addListener(_checkCollapseComplete);
    _animController.addStatusListener(_onAnimationStatus);

    // Rail animation controller
    _railAnimController = AnimationController(
      vsync: this,
      duration: _theme.railDuration,
      value: widget.initialMode == NavMode.iconRail ? 1.0 : 0.0,
    );

    _railCurvedAnim = CurvedAnimation(
      parent: _railAnimController,
      curve: _theme.easeCurve,
    );
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _controller.onExpandComplete();
      _animController.reset();
      _collapseHandled = false;
    }
  }

  void _checkCollapseComplete() {
    if (_collapseHandled) return;
    final collapseEnd = _theme.collapseEnd;
    if (_animController.value >= collapseEnd &&
        _controller.animState == NavAnimState.collapsing) {
      _collapseHandled = true;
      _controller.onCollapseComplete();
    }
  }

  /// Collapse sidebar to icon rail (smooth width morph).
  void _onCollapseToRail() {
    if (!_controller.canToggle) return;

    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    _controller.setRailAnimating(true);
    _controller.setModeImmediate(NavMode.iconRail);

    if (reduceMotion) {
      _railAnimController.value = 1.0;
      _controller.setRailAnimating(false);
    } else {
      _railAnimController.forward().then((_) {
        _controller.setRailAnimating(false);
      });
    }
  }

  /// Expand from icon rail back to sidebar.
  void _onExpandFromRail() {
    if (!_controller.canToggle) return;

    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    _controller.setRailAnimating(true);
    _controller.setModeImmediate(NavMode.sidebar);

    if (reduceMotion) {
      _railAnimController.value = 0.0;
      _controller.setRailAnimating(false);
    } else {
      _railAnimController.reverse().then((_) {
        _controller.setRailAnimating(false);
      });
    }
  }

  /// Toggle from sidebar to tab bar (existing collapse/expand animation).
  void _onToggleToTabBar() {
    if (!_controller.canToggle) return;

    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    if (reduceMotion) {
      _controller.beginTransitionTo(NavMode.tabBar);
      _controller.onCollapseComplete();
      _controller.onExpandComplete();
    } else {
      _controller.beginTransitionTo(NavMode.tabBar);
      _collapseHandled = false;
      _animController.forward(from: 0.0);
    }
  }

  /// Toggle from tab bar back to sidebar.
  void _onBackToSidebar() {
    if (!_controller.canToggle) return;

    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    if (reduceMotion) {
      _controller.beginTransitionTo(NavMode.sidebar);
      _controller.onCollapseComplete();
      _controller.onExpandComplete();
    } else {
      _controller.beginTransitionTo(NavMode.sidebar);
      _collapseHandled = false;
      _animController.forward(from: 0.0);
    }
  }

  void _onItemSelected(String id) {
    _controller.selectItem(id);
    widget.onItemSelected?.call(id);
  }

  @override
  void didUpdateWidget(NavToggleScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldTheme = oldWidget.theme ?? const NavToggleTheme();
    final newTheme = _theme;
    if (oldTheme.totalDuration != newTheme.totalDuration ||
        oldTheme.collapseEnd != newTheme.collapseEnd ||
        oldTheme.easeCurve != newTheme.easeCurve) {
      _animController.duration = newTheme.totalDuration;
      _animations.dispose();
      _animations = NavTransitionAnimations(
        controller: _animController,
        collapseEnd: newTheme.collapseEnd,
        curve: newTheme.easeCurve,
      );
    }
    if (oldTheme.railDuration != newTheme.railDuration) {
      _railAnimController.duration = newTheme.railDuration;
    }
  }

  @override
  void dispose() {
    _animController.removeListener(_checkCollapseComplete);
    _animController.removeStatusListener(_onAnimationStatus);
    _animations.dispose();
    _animController.dispose();
    _railCurvedAnim.dispose();
    _railAnimController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NavToggleThemeProvider(
      theme: _theme,
      child: ChangeNotifierProvider.value(
        value: _controller,
        child: Container(
          color: _theme.background,
          child: AnimatedBuilder(
            animation: _animController,
            builder: (context, _) {
              return AnimatedBuilder(
                animation: _railAnimController,
                builder: (context, _) {
                  return Consumer<NavToggleController>(
                    builder: (context, controller, _) {
                      return _buildLayout(controller);
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLayout(NavToggleController controller) {
    final theme = _theme;
    final mode = controller.mode;
    final animState = controller.animState;

    // Rail animation progress: 0 = full sidebar, 1 = icon rail
    final r = _railCurvedAnim.value;

    // Animated widths based on rail progress
    final currentNavWidth = lerpDouble(theme.sidebarWidth, theme.railWidth, r)!;
    final currentButtonWidth =
        lerpDouble(theme.buttonWidth, theme.railWidth, r)!;

    // Calculate sidebar<->tabBar panel visibility progress
    double sidebarProgress;
    double tabBarProgress;

    if (animState == NavAnimState.idle) {
      sidebarProgress = (mode == NavMode.sidebar || mode == NavMode.iconRail)
          ? 1.0
          : 0.0;
      tabBarProgress = mode == NavMode.tabBar ? 1.0 : 0.0;
    } else if (animState == NavAnimState.collapsing) {
      if (mode == NavMode.sidebar || mode == NavMode.iconRail) {
        sidebarProgress = 1.0 - _animations.collapse.value;
        tabBarProgress = 0.0;
      } else {
        tabBarProgress = 1.0 - _animations.collapse.value;
        sidebarProgress = 0.0;
      }
    } else {
      // expanding
      if (mode == NavMode.sidebar || mode == NavMode.iconRail) {
        sidebarProgress = _animations.expand.value;
        tabBarProgress = 0.0;
      } else {
        tabBarProgress = _animations.expand.value;
        sidebarProgress = 0.0;
      }
    }

    // Content padding targets
    final bool isLeftPanel =
        mode == NavMode.sidebar || mode == NavMode.iconRail;
    final targetLeft = isLeftPanel ? currentNavWidth : 0.0;
    final targetTop = mode == NavMode.tabBar ? theme.buttonHeight : 0.0;

    // Determine button callbacks based on current mode
    VoidCallback? onLeftPressed;
    VoidCallback? onRightPressed;

    switch (mode) {
      case NavMode.sidebar:
        onLeftPressed = _onCollapseToRail;
        onRightPressed = _onToggleToTabBar;
      case NavMode.iconRail:
        onLeftPressed = _onExpandFromRail;
        onRightPressed = null;
      case NavMode.tabBar:
        onLeftPressed = _onBackToSidebar;
        onRightPressed = null;
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Content area with animated padding
        AnimatedPadding(
          duration: theme.contentShiftDuration,
          curve: theme.easeCurve,
          padding: EdgeInsets.only(
            left: targetLeft,
            top: targetTop,
          ),
          child: widget.child,
        ),

        // Sidebar panel (visible when r < 1.0, i.e. not fully collapsed to rail)
        if (sidebarProgress > 0 && r < 1.0)
          Positioned(
            left: 0,
            top: theme.buttonHeight,
            bottom: 0,
            child: ClipRect(
              clipper: SidebarClipper(progress: sidebarProgress),
              child: Opacity(
                opacity: (1.0 - r).clamp(0.0, 1.0),
                child: ClipRect(
                  clipper: _WidthClipper(width: currentNavWidth),
                  child: SidebarPanel(
                    items: widget.items,
                    selectedId: controller.selectedItemId,
                    onItemSelected: _onItemSelected,
                    systemStatus: widget.systemStatus,
                    userInfo: widget.userInfo,
                  ),
                ),
              ),
            ),
          ),

        // Icon rail panel (visible when r > 0.0)
        if (r > 0.0)
          Positioned(
            left: 0,
            top: theme.buttonHeight,
            bottom: 0,
            child: Opacity(
              opacity: r.clamp(0.0, 1.0),
              child: IconRailPanel(
                items: widget.items,
                selectedId: controller.selectedItemId,
                onItemSelected: _onItemSelected,
                systemStatus: widget.systemStatus,
                userInfo: widget.userInfo,
              ),
            ),
          ),

        // Tab bar panel
        if (tabBarProgress > 0)
          Positioned(
            left: currentButtonWidth,
            top: 0,
            right: 0,
            child: ClipRect(
              clipper: TabBarClipper(progress: tabBarProgress),
              child: TabBarPanel(
                items: widget.items,
                selectedId: controller.selectedItemId,
                onItemSelected: _onItemSelected,
                systemStatus: widget.systemStatus,
                userInfo: widget.userInfo,
              ),
            ),
          ),

        // Toggle button (always on top)
        Positioned(
          left: 0,
          top: 0,
          child: Container(
            width: currentButtonWidth,
            height: theme.buttonHeight,
            decoration: BoxDecoration(
              color: theme.surface,
              border: Border(
                bottom: BorderSide(color: theme.border, width: 1),
                right: BorderSide(color: theme.border, width: 1),
              ),
            ),
            child: ModeToggleButton(
              state: _navModeToToggleState(mode),
              expandedWidth: theme.buttonWidth,
              collapsedWidth: theme.railWidth,
              splitRatio: 0.5,
              onTap: mode != NavMode.sidebar && controller.canToggle
                  ? onLeftPressed
                  : null,
              onLeftTap: controller.canToggle ? onLeftPressed : null,
              onRightTap: controller.canToggle ? onRightPressed : null,
              accentColor: theme.accent,
              textColor: theme.textDim,
              enabled: controller.canToggle,
              animationDuration: theme.railDuration,
            ),
          ),
        ),
      ],
    );
  }
}

ModeToggleState _navModeToToggleState(NavMode mode) => switch (mode) {
      NavMode.sidebar => ModeToggleState.split,
      NavMode.iconRail => ModeToggleState.collapsedLeft,
      NavMode.tabBar => ModeToggleState.collapsedRight,
    };

/// Clips a widget to a fixed width, allowing it to render at its natural size
/// but only showing the left portion up to [width].
class _WidthClipper extends CustomClipper<Rect> {
  _WidthClipper({required this.width});

  final double width;

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, width, size.height);
  }

  @override
  bool shouldReclip(_WidthClipper oldClipper) => oldClipper.width != width;
}
