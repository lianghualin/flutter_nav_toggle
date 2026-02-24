import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../animation/nav_transition.dart';
import '../controller/nav_toggle_controller.dart';
import '../models/nav_item.dart';
import '../models/nav_mode.dart';
import '../models/system_status.dart';
import '../theme/nav_toggle_theme.dart';
import 'sidebar_panel.dart';
import 'tab_bar_panel.dart';
import 'toggle_button.dart';

/// Top-level scaffold that manages the toggle button, sidebar/tab bar panels,
/// content area, and all transition animations.
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
  });

  final List<NavItem> items;
  final Widget child;
  final NavToggleTheme? theme;
  final NavMode initialMode;
  final String? initialSelectedId;
  final ValueChanged<String>? onItemSelected;
  final SystemStatus? systemStatus;

  @override
  State<NavToggleScaffold> createState() => _NavToggleScaffoldState();
}

class _NavToggleScaffoldState extends State<NavToggleScaffold>
    with SingleTickerProviderStateMixin {
  late final NavToggleController _controller;
  late final AnimationController _animController;
  late NavTransitionAnimations _animations;
  bool _collapseHandled = false;

  NavToggleTheme get _theme => widget.theme ?? const NavToggleTheme();

  @override
  void initState() {
    super.initState();
    _controller = NavToggleController(
      initialMode: widget.initialMode,
      initialSelectedId: widget.initialSelectedId ?? widget.items.first.id,
    );

    _animController = AnimationController(
      vsync: this,
      duration: _theme.totalDuration,
    );

    _animations = NavTransitionAnimations(
      controller: _animController,
      collapseEnd: _theme.collapseEnd,
      iconMorphEnd: _theme.iconMorphEnd,
      curve: _theme.easeCurve,
    );

    _animController.addListener(_checkCollapseComplete);
    _animController.addStatusListener(_onAnimationStatus);
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

  void _onTogglePressed() {
    if (!_controller.canToggle) return;

    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    if (reduceMotion) {
      _controller.beginToggle();
      _controller.onCollapseComplete();
      _controller.onExpandComplete();
    } else {
      _controller.beginToggle();
      _collapseHandled = false;
      _animController.forward(from: 0.0);
    }
  }

  void _onItemSelected(String id) {
    _controller.selectItem(id);
    widget.onItemSelected?.call(id);
  }

  @override
  void dispose() {
    _animController.removeListener(_checkCollapseComplete);
    _animController.removeStatusListener(_onAnimationStatus);
    _animations.dispose();
    _animController.dispose();
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
              return Consumer<NavToggleController>(
                builder: (context, controller, _) {
                  return _buildLayout(controller);
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

    // Calculate panel visibility progress
    double sidebarProgress;
    double tabBarProgress;

    if (animState == NavAnimState.idle) {
      sidebarProgress = mode == NavMode.sidebar ? 1.0 : 0.0;
      tabBarProgress = mode == NavMode.tabBar ? 1.0 : 0.0;
    } else if (animState == NavAnimState.collapsing) {
      if (mode == NavMode.sidebar) {
        sidebarProgress = 1.0 - _animations.collapse.value;
        tabBarProgress = 0.0;
      } else {
        tabBarProgress = 1.0 - _animations.collapse.value;
        sidebarProgress = 0.0;
      }
    } else {
      // expanding
      if (mode == NavMode.sidebar) {
        sidebarProgress = _animations.expand.value;
        tabBarProgress = 0.0;
      } else {
        tabBarProgress = _animations.expand.value;
        sidebarProgress = 0.0;
      }
    }

    // Content padding targets
    final targetLeft = mode == NavMode.sidebar ? theme.sidebarWidth : 0.0;
    final targetTop = mode == NavMode.tabBar ? theme.buttonHeight : 0.0;

    return Stack(
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

        // Sidebar panel
        if (sidebarProgress > 0)
          Positioned(
            left: 0,
            top: theme.buttonHeight,
            bottom: 0,
            child: ClipRect(
              clipper: SidebarClipper(progress: sidebarProgress),
              child: SidebarPanel(
                items: widget.items,
                selectedId: controller.selectedItemId,
                onItemSelected: _onItemSelected,
                systemStatus: widget.systemStatus,
              ),
            ),
          ),

        // Tab bar panel
        if (tabBarProgress > 0)
          Positioned(
            left: theme.buttonWidth,
            top: 0,
            right: 0,
            child: ClipRect(
              clipper: TabBarClipper(progress: tabBarProgress),
              child: TabBarPanel(
                items: widget.items,
                selectedId: controller.selectedItemId,
                onItemSelected: _onItemSelected,
                systemStatus: widget.systemStatus,
              ),
            ),
          ),

        // Toggle button (always on top)
        Positioned(
          left: 0,
          top: 0,
          child: ToggleButton(
            iconAnimation: _animations.iconMorph,
            onPressed: _onTogglePressed,
            isSidebarMode: mode == NavMode.sidebar,
            enabled: controller.canToggle,
          ),
        ),
      ],
    );
  }
}
