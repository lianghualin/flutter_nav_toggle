import 'package:flutter/foundation.dart';
import '../models/nav_mode.dart';
import '../models/system_status.dart';

/// Manages navigation mode, selected item, and animation state.
class NavToggleController extends ChangeNotifier {
  NavToggleController({
    NavMode initialMode = NavMode.sidebar,
    String? initialSelectedId,
  })  : _mode = initialMode,
        _pendingMode = initialMode,
        _selectedItemId = initialSelectedId ?? '',
        _animState = NavAnimState.idle;

  NavMode _mode;
  NavMode _pendingMode;
  String _selectedItemId;
  NavAnimState _animState;
  bool _railAnimating = false;
  SystemStatus? _status;
  bool _isOverlay = false;
  bool _userOverride = false;

  /// The current navigation mode (only changes at collapse->expand boundary).
  NavMode get mode => _mode;

  /// The mode we're transitioning to (equals [mode] when idle).
  NavMode get pendingMode => _pendingMode;

  /// Current animation state.
  NavAnimState get animState => _animState;

  /// Currently selected item id.
  String get selectedItemId => _selectedItemId;

  /// Whether the sidebar is displayed as an overlay (floating over content).
  bool get isOverlay => _isOverlay;

  /// Whether the toggle button should be interactive.
  bool get canToggle => _animState == NavAnimState.idle && !_railAnimating;

  /// Begin a transition to [target] mode via collapse/expand animation.
  ///
  /// Only valid transitions: sidebar<->tabBar. No direct iconRail<->tabBar.
  void beginTransitionTo(NavMode target) {
    if (!canToggle) return;
    if (target == _mode) return;
    _pendingMode = target;
    _animState = NavAnimState.collapsing;
    notifyListeners();
  }

  /// Begin a mode toggle (legacy convenience — toggles sidebar<->tabBar).
  void beginToggle() {
    if (!canToggle) return;
    _pendingMode = _mode == NavMode.sidebar ? NavMode.tabBar : NavMode.sidebar;
    _animState = NavAnimState.collapsing;
    notifyListeners();
  }

  /// Set mode immediately without collapse/expand animation.
  ///
  /// Used for rail transitions managed by the scaffold's second AnimationController.
  void setModeImmediate(NavMode mode) {
    _mode = mode;
    _pendingMode = mode;
    notifyListeners();
  }

  /// Mark whether a rail animation is in progress.
  void setRailAnimating(bool value) {
    _railAnimating = value;
    notifyListeners();
  }

  /// Called when collapse phase completes. Flips the actual mode.
  void onCollapseComplete() {
    _mode = _pendingMode;
    _animState = NavAnimState.expanding;
    notifyListeners();
  }

  /// Called when expand phase completes. Returns to idle.
  void onExpandComplete() {
    _animState = NavAnimState.idle;
    notifyListeners();
  }

  /// Select a nav item by id.
  void selectItem(String id) {
    if (_selectedItemId == id) return;
    _selectedItemId = id;
    notifyListeners();
  }

  /// Current system status (if set).
  SystemStatus? get status => _status;

  /// Update system status and notify listeners.
  void updateStatus(SystemStatus status) {
    _status = status;
    notifyListeners();
  }

  /// Update system status without notifying listeners.
  ///
  /// Use this for high-frequency updates (e.g. real-time CPU/memory ticks)
  /// to avoid excessive rebuilds. Call [notifyListeners] manually when ready.
  void updateStatusSilent(SystemStatus status) {
    _status = status;
  }

  /// Show the sidebar as an overlay (floating over content with scrim).
  void showOverlaySidebar() {
    _isOverlay = true;
    _mode = NavMode.sidebar;
    _pendingMode = NavMode.sidebar;
    notifyListeners();
  }

  /// Dismiss the overlay sidebar, reverting to the given [fallbackMode].
  void dismissOverlay({NavMode fallbackMode = NavMode.tabBar}) {
    if (!_isOverlay) return;
    _isOverlay = false;
    _mode = fallbackMode;
    _pendingMode = fallbackMode;
    notifyListeners();
  }

  /// Update mode based on screen width and theme breakpoints.
  ///
  /// Called by the scaffold when [autoResponsive] is true.
  /// Returns true if mode changed, false otherwise.
  bool updateForScreenWidth(double width, double breakpointSidebar,
      double breakpointRail) {
    // If overlay is showing, don't auto-switch
    if (_isOverlay) return false;

    NavMode target;
    if (width >= breakpointSidebar) {
      target = NavMode.sidebar;
    } else if (width >= breakpointRail) {
      target = NavMode.iconRail;
    } else {
      target = NavMode.tabBar;
    }

    if (target == _mode) {
      _userOverride = false;
      return false;
    }

    // Reset user override when crossing a breakpoint
    _userOverride = false;
    _mode = target;
    _pendingMode = target;
    notifyListeners();
    return true;
  }

  /// Whether the user has manually overridden auto-responsive mode.
  bool get isUserOverride => _userOverride;

  /// Mark that the user manually toggled, overriding auto-responsive.
  void setUserOverride() {
    _userOverride = true;
  }
}
