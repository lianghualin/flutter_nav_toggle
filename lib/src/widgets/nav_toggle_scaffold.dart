import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../animation/nav_transition.dart';
import '../animation/page_transitions.dart';
import '../controller/nav_toggle_controller.dart';
import '../models/nav_header.dart';
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
    this.header,
    this.pages,
    this.pageTransitionType,
    this.showPageHeader = false,
    this.enableKeyboardShortcuts = false,
  });

  final List<NavItem> items;
  final Widget child;
  final NavToggleTheme? theme;
  final NavMode initialMode;
  final String? initialSelectedId;
  final ValueChanged<String>? onItemSelected;
  final SystemStatus? systemStatus;
  final UserInfo? userInfo;
  final NavHeader? header;

  /// Page map for automatic content switching. When non-null, the scaffold
  /// shows the page matching [NavToggleController.selectedItemId] instead of
  /// [child].
  final Map<String, Widget>? pages;

  /// Transition type used when switching pages (defaults to fade).
  final PageTransitionType? pageTransitionType;

  /// Whether to show a header bar above the content area with the selected
  /// item's icon and label.
  final bool showPageHeader;

  /// Whether to enable keyboard shortcuts (T to toggle navigation mode).
  final bool enableKeyboardShortcuts;

  /// Named constructor that accepts a page map for automatic content switching.
  const NavToggleScaffold.withPages({
    super.key,
    required this.items,
    required Map<String, Widget> this.pages,
    this.theme,
    this.initialMode = NavMode.sidebar,
    this.initialSelectedId,
    this.onItemSelected,
    this.systemStatus,
    this.userInfo,
    this.header,
    this.pageTransitionType = PageTransitionType.fade,
    this.showPageHeader = false,
    this.enableKeyboardShortcuts = false,
  }) : child = const SizedBox.shrink();

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

  // Overlay sidebar scrim animation
  late final AnimationController _scrimController;

  // Track screen width for auto-responsive
  double _lastWidth = 0.0;

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

    // Scrim for overlay sidebar
    _scrimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
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
    // Auto-dismiss overlay sidebar on item selection
    if (_controller.isOverlay) {
      _dismissOverlay();
    }
  }

  /// Show the sidebar as overlay (narrow screen toggle).
  void _showOverlaySidebar() {
    _controller.showOverlaySidebar();
    _scrimController.forward();
    // Set rail to 0 so full sidebar is shown
    _railAnimController.value = 0.0;
  }

  /// Dismiss the overlay sidebar with scrim fade-out.
  void _dismissOverlay() {
    final theme = _theme;
    NavMode fallback;
    if (theme.autoResponsive) {
      if (_lastWidth >= theme.breakpointRail) {
        fallback = NavMode.iconRail;
      } else {
        fallback = NavMode.tabBar;
      }
    } else {
      fallback = NavMode.tabBar;
    }
    _scrimController.reverse();
    _controller.dismissOverlay(fallbackMode: fallback);
  }

  /// Compute the correct auto-responsive mode for the current width.
  void _handleAutoResponsive(double width) {
    if (!_theme.autoResponsive) return;
    if (width == _lastWidth) return;
    _lastWidth = width;
    _controller.updateForScreenWidth(
      width,
      _theme.breakpointSidebar,
      _theme.breakpointRail,
    );
    // Sync rail animation value to match mode
    if (_controller.mode == NavMode.iconRail) {
      _railAnimController.value = 1.0;
    } else if (_controller.mode == NavMode.sidebar) {
      _railAnimController.value = 0.0;
    }
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
    _scrimController.dispose();
    _controller.dispose();
    super.dispose();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey != LogicalKeyboardKey.keyT) {
      return KeyEventResult.ignored;
    }
    if (!_controller.canToggle) return KeyEventResult.ignored;

    // Dismiss overlay if showing
    if (_controller.isOverlay) {
      _dismissOverlay();
      return KeyEventResult.handled;
    }

    final mode = _controller.mode;
    final theme = _theme;

    // On narrow screens with autoResponsive, show overlay sidebar
    if (theme.autoResponsive &&
        _lastWidth < theme.breakpointSidebar &&
        mode != NavMode.sidebar) {
      _showOverlaySidebar();
      return KeyEventResult.handled;
    }

    switch (mode) {
      case NavMode.sidebar:
        _onToggleToTabBar();
      case NavMode.tabBar:
        _onBackToSidebar();
      case NavMode.iconRail:
        _onExpandFromRail();
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    Widget inner = AnimatedBuilder(
      animation: _animController,
      builder: (context, _) {
        return AnimatedBuilder(
          animation: _railAnimController,
          builder: (context, _) {
            return AnimatedBuilder(
              animation: _scrimController,
              builder: (context, _) {
                return Consumer<NavToggleController>(
                  builder: (context, controller, _) {
                    return _buildLayout(controller);
                  },
                );
              },
            );
          },
        );
      },
    );

    // Wrap in LayoutBuilder for auto-responsive mode
    if (_theme.autoResponsive) {
      final content = inner;
      inner = LayoutBuilder(
        builder: (context, constraints) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleAutoResponsive(constraints.maxWidth);
          });
          return content;
        },
      );
    }

    Widget scaffold = NavToggleThemeProvider(
      theme: _theme,
      child: ChangeNotifierProvider.value(
        value: _controller,
        child: Container(
          color: _theme.background,
          child: inner,
        ),
      ),
    );

    if (widget.enableKeyboardShortcuts) {
      scaffold = Focus(
        autofocus: true,
        onKeyEvent: _handleKeyEvent,
        child: scaffold,
      );
    }

    return scaffold;
  }

  /// Finds a [NavItem] by id from the flat+nested items list.
  NavItem? _findItemById(String id) {
    for (final item in widget.items) {
      if (item.id == id) return item;
      if (item.hasChildren) {
        for (final child in item.children!) {
          if (child.id == id) return child;
        }
      }
    }
    return null;
  }

  /// Builds the content area: either the page from [pages] map
  /// (with transitions) or the static [child].
  Widget _buildContentArea(NavToggleController controller) {
    final theme = _theme;

    Widget content;
    if (widget.pages != null) {
      final selectedId = controller.selectedItemId;
      final page = widget.pages![selectedId] ??
          const Center(child: Text('Page not found'));
      final transitionType =
          widget.pageTransitionType ?? PageTransitionType.fade;

      content = AnimatedSwitcher(
        duration: theme.pageTransitionDuration,
        transitionBuilder: pageTransitionBuilder(transitionType),
        child: KeyedSubtree(
          key: ValueKey(selectedId),
          child: page,
        ),
      );
    } else {
      content = widget.child;
    }

    if (widget.showPageHeader) {
      final selectedItem = _findItemById(controller.selectedItemId);
      return Column(
        children: [
          if (selectedItem != null)
            _PageHeader(item: selectedItem, theme: theme),
          Expanded(child: content),
        ],
      );
    }

    return content;
  }

  Widget _buildLayout(NavToggleController controller) {
    final theme = _theme;
    final mode = controller.mode;
    final animState = controller.animState;
    final isOverlay = controller.isOverlay;

    // Rail animation progress: 0 = full sidebar, 1 = icon rail
    final r = _railCurvedAnim.value;

    // Animated widths based on rail progress
    final currentNavWidth = lerpDouble(theme.sidebarWidth, theme.railWidth, r)!;
    final currentButtonWidth =
        lerpDouble(theme.buttonWidth, theme.railWidth, r)!;

    // Calculate sidebar<->tabBar panel visibility progress
    double sidebarProgress;
    double tabBarProgress;

    if (isOverlay) {
      // Overlay: sidebar always fully visible, keep underlying tab bar
      sidebarProgress = 1.0;
      tabBarProgress = 1.0;
    } else if (animState == NavAnimState.idle) {
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

    // Content padding targets — overlay sidebar doesn't push content
    final bool isLeftPanel =
        !isOverlay && (mode == NavMode.sidebar || mode == NavMode.iconRail);
    final targetLeft = isLeftPanel ? currentNavWidth : 0.0;
    final targetTop =
        (isOverlay || mode == NavMode.tabBar) ? theme.buttonHeight : 0.0;

    // Determine button callbacks based on current mode
    VoidCallback? onLeftPressed;
    VoidCallback? onRightPressed;

    if (isOverlay) {
      // In overlay mode, button dismisses the overlay
      onLeftPressed = _dismissOverlay;
      onRightPressed = null;
    } else if (theme.autoResponsive &&
        _lastWidth < theme.breakpointSidebar &&
        mode != NavMode.sidebar) {
      // Narrow screen + auto-responsive: toggle shows overlay
      onLeftPressed = _showOverlaySidebar;
      onRightPressed = null;
    } else {
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
    }

    // Scrim opacity
    final scrimOpacity = _scrimController.value;

    // For toggle button, use the underlying mode when overlay is active
    final buttonMode = isOverlay ? NavMode.sidebar : mode;
    // Button width when overlay: full sidebar width
    final overlayButtonWidth = isOverlay ? theme.buttonWidth : currentButtonWidth;

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
          child: _buildContentArea(controller),
        ),

        // Tab bar panel (under scrim when overlay is active)
        if (tabBarProgress > 0 && !isOverlay)
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

        // Icon rail panel (visible when r > 0.0 and not in overlay)
        if (r > 0.0 && !isOverlay)
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

        // Scrim overlay (tap to dismiss)
        if (scrimOpacity > 0)
          Positioned.fill(
            child: GestureDetector(
              onTap: _dismissOverlay,
              child: Container(
                color: const Color(0xFF000000)
                    .withValues(alpha: 0.4 * scrimOpacity),
              ),
            ),
          ),

        // Sidebar panel — normal or overlay mode
        if (sidebarProgress > 0 && r < 1.0 && !isOverlay)
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

        // Overlay sidebar (floats above scrim)
        if (isOverlay)
          Positioned(
            left: 0,
            top: theme.buttonHeight,
            bottom: 0,
            child: SidebarPanel(
              items: widget.items,
              selectedId: controller.selectedItemId,
              onItemSelected: _onItemSelected,
              systemStatus: widget.systemStatus,
              userInfo: widget.userInfo,
            ),
          ),

        // Toggle button / header (always on top)
        Positioned(
          left: 0,
          top: 0,
          child: Container(
            width: overlayButtonWidth,
            height: theme.buttonHeight,
            decoration: BoxDecoration(
              color: theme.surface,
              border: Border(
                bottom: BorderSide(color: theme.border, width: 1),
                right: BorderSide(color: theme.border, width: 1),
              ),
            ),
            child: ModeToggleButton(
              state: _navModeToToggleState(buttonMode),
              expandedWidth: theme.buttonWidth,
              collapsedWidth: theme.railWidth,
              splitRatio: 0.5,
              icon: widget.header?.logo,
              label: widget.header?.title,
              showModeIcon: widget.header == null,
              onTap: buttonMode != NavMode.sidebar && controller.canToggle
                  ? onLeftPressed
                  : isOverlay
                      ? _dismissOverlay
                      : null,
              onLeftTap: controller.canToggle ? onLeftPressed : null,
              onRightTap: controller.canToggle ? onRightPressed : null,
              accentColor: theme.accent,
              textColor: theme.textDim,
              enabled: controller.canToggle || isOverlay,
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

/// A thin header bar that shows the selected item's icon and label above content.
class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.item, required this.theme});

  final NavItem item;
  final NavToggleTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: theme.pageHeaderHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border(
          bottom: BorderSide(color: theme.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(item.icon, size: 18, color: theme.text),
          const SizedBox(width: 10),
          Text(
            item.label,
            style: TextStyle(
              fontFamily: theme.navFontFamily,
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: theme.text,
            ),
          ),
        ],
      ),
    );
  }
}