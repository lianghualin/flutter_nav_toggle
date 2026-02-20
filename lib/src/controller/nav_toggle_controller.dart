import 'package:flutter/foundation.dart';
import '../models/nav_mode.dart';

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

  /// The current navigation mode (only changes at collapse→expand boundary).
  NavMode get mode => _mode;

  /// The mode we're transitioning to (equals [mode] when idle).
  NavMode get pendingMode => _pendingMode;

  /// Current animation state.
  NavAnimState get animState => _animState;

  /// Currently selected item id.
  String get selectedItemId => _selectedItemId;

  /// Whether the toggle button should be interactive.
  bool get canToggle => _animState == NavAnimState.idle;

  /// Begin a mode toggle. Called by the scaffold when the button is pressed.
  void beginToggle() {
    if (!canToggle) return;
    _pendingMode = _mode == NavMode.sidebar ? NavMode.tabBar : NavMode.sidebar;
    _animState = NavAnimState.collapsing;
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
}
