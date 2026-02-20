# NavToggle Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a standalone Flutter package that provides a dual-mode navigation toggle (sidebar ↔ tab bar) with animated clip-path transitions, morphing icon, and full theme customization.

**Architecture:** Single AnimationController with phased intervals (collapse 420ms → expand 550ms). Provider + ChangeNotifier for state. ClipRect + CustomClipper for directional panel collapse/expand. InheritedWidget for theme propagation.

**Tech Stack:** Flutter SDK ^3.0.0, provider ^6.1.2, bundled Syne + DM Mono fonts

---

## Task 1: Scaffold the package

**Files:**
- Create: `pubspec.yaml`
- Create: `lib/nav_toggle.dart`
- Create: `lib/src/models/nav_item.dart`
- Create: `lib/src/models/nav_mode.dart`
- Create: `example/lib/main.dart`
- Create: `example/pubspec.yaml`

**Step 1: Create pubspec.yaml**

```yaml
name: nav_toggle
description: >
  A dual-mode navigation toggle widget that smoothly morphs between
  sidebar and tab bar layouts with clip-path animations.

version: 1.0.0

environment:
  sdk: ^3.0.0
  flutter: ">=3.0.0"

dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0

flutter:
  uses-material-design: true
  fonts:
    - family: Syne
      fonts:
        - asset: assets/fonts/Syne-Regular.ttf
          weight: 400
        - asset: assets/fonts/Syne-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Syne-Bold.ttf
          weight: 700
        - asset: assets/fonts/Syne-ExtraBold.ttf
          weight: 800
    - family: DMMono
      fonts:
        - asset: assets/fonts/DMMono-Regular.ttf
          weight: 400
        - asset: assets/fonts/DMMono-Medium.ttf
          weight: 500
```

**Step 2: Create models**

`lib/src/models/nav_mode.dart`:
```dart
/// Navigation display modes.
enum NavMode { sidebar, tabBar }

/// Animation state machine states.
enum NavAnimState { idle, collapsing, expanding }
```

`lib/src/models/nav_item.dart`:
```dart
import 'package:flutter/widgets.dart';

/// A single navigation item with an id, label, and icon.
class NavItem {
  const NavItem({
    required this.id,
    required this.label,
    required this.icon,
  });

  final String id;
  final String label;
  final IconData icon;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NavItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
```

**Step 3: Create public API exports**

`lib/nav_toggle.dart`:
```dart
/// A dual-mode navigation toggle widget that morphs between
/// sidebar and tab bar layouts.
library;

// Models
export 'src/models/nav_item.dart';
export 'src/models/nav_mode.dart';
```

**Step 4: Create minimal example app**

`example/pubspec.yaml`:
```yaml
name: nav_toggle_example
description: Demo app for nav_toggle package.

environment:
  sdk: ^3.0.0
  flutter: ">=3.0.0"

dependencies:
  flutter:
    sdk: flutter
  nav_toggle:
    path: ..

flutter:
  uses-material-design: true
```

`example/lib/main.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:nav_toggle/nav_toggle.dart';

void main() => runApp(const NavToggleExampleApp());

class NavToggleExampleApp extends StatelessWidget {
  const NavToggleExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NavToggle Demo',
      theme: ThemeData.dark(useMaterial3: true),
      home: const Scaffold(
        body: Center(child: Text('NavToggle coming soon')),
      ),
    );
  }
}
```

**Step 5: Download and place fonts**

Download Syne and DM Mono TTF files from Google Fonts and place them in `assets/fonts/`.

**Step 6: Run flutter pub get to verify**

```bash
cd /Users/hualinliang/Project/flutter_tmp && flutter pub get
cd /Users/hualinliang/Project/flutter_tmp/example && flutter pub get
```

Expected: No errors.

**Step 7: Commit**

```bash
git init
git add pubspec.yaml lib/ example/ assets/
git commit -m "feat: scaffold nav_toggle package with models and example app"
```

---

## Task 2: Theme system

**Files:**
- Create: `lib/src/theme/nav_toggle_theme.dart`
- Modify: `lib/nav_toggle.dart` (add export)

**Step 1: Write the theme class with design tokens and InheritedWidget**

`lib/src/theme/nav_toggle_theme.dart`:
```dart
import 'package:flutter/widgets.dart';

/// Design tokens and theme configuration for NavToggle.
class NavToggleTheme {
  const NavToggleTheme({
    this.buttonHeight = 52.0,
    this.buttonWidth = 200.0,
    this.sidebarWidth = 200.0,
    this.background = const Color(0xFF0D0E11),
    this.surface = const Color(0xFF161820),
    this.border = const Color(0x12FFFFFF), // rgba(255,255,255,0.07)
    this.accent = const Color(0xFF7DF3C0),
    this.accent2 = const Color(0xFF5BC8F5),
    this.text = const Color(0xFFC8CDD8),
    this.textDim = const Color(0xFF5A6070),
    this.cornerRadius = 14.0,
    this.itemRadius = 8.0,
    this.collapseDuration = const Duration(milliseconds: 420),
    this.expandDuration = const Duration(milliseconds: 550),
    this.iconMorphDuration = const Duration(milliseconds: 450),
    this.contentShiftDuration = const Duration(milliseconds: 480),
    this.easeCurve = const Cubic(0.77, 0, 0.18, 1),
    this.navFontFamily = 'Syne',
    this.monoFontFamily = 'DMMono',
  });

  final double buttonHeight;
  final double buttonWidth;
  final double sidebarWidth;
  final Color background;
  final Color surface;
  final Color border;
  final Color accent;
  final Color accent2;
  final Color text;
  final Color textDim;
  final double cornerRadius;
  final double itemRadius;
  final Duration collapseDuration;
  final Duration expandDuration;
  final Duration iconMorphDuration;
  final Duration contentShiftDuration;
  final Cubic easeCurve;
  final String navFontFamily;
  final String monoFontFamily;

  /// Total animation duration (collapse + expand).
  Duration get totalDuration => Duration(
        milliseconds:
            collapseDuration.inMilliseconds + expandDuration.inMilliseconds,
      );

  /// Collapse phase ends at this fraction of total duration.
  double get collapseEnd =>
      collapseDuration.inMilliseconds / totalDuration.inMilliseconds;

  /// Icon morph fraction of total duration.
  double get iconMorphEnd =>
      iconMorphDuration.inMilliseconds / totalDuration.inMilliseconds;

  NavToggleTheme copyWith({
    double? buttonHeight,
    double? buttonWidth,
    double? sidebarWidth,
    Color? background,
    Color? surface,
    Color? border,
    Color? accent,
    Color? accent2,
    Color? text,
    Color? textDim,
    double? cornerRadius,
    double? itemRadius,
    Duration? collapseDuration,
    Duration? expandDuration,
    Duration? iconMorphDuration,
    Duration? contentShiftDuration,
    Cubic? easeCurve,
    String? navFontFamily,
    String? monoFontFamily,
  }) {
    return NavToggleTheme(
      buttonHeight: buttonHeight ?? this.buttonHeight,
      buttonWidth: buttonWidth ?? this.buttonWidth,
      sidebarWidth: sidebarWidth ?? this.sidebarWidth,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      border: border ?? this.border,
      accent: accent ?? this.accent,
      accent2: accent2 ?? this.accent2,
      text: text ?? this.text,
      textDim: textDim ?? this.textDim,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      itemRadius: itemRadius ?? this.itemRadius,
      collapseDuration: collapseDuration ?? this.collapseDuration,
      expandDuration: expandDuration ?? this.expandDuration,
      iconMorphDuration: iconMorphDuration ?? this.iconMorphDuration,
      contentShiftDuration: contentShiftDuration ?? this.contentShiftDuration,
      easeCurve: easeCurve ?? this.easeCurve,
      navFontFamily: navFontFamily ?? this.navFontFamily,
      monoFontFamily: monoFontFamily ?? this.monoFontFamily,
    );
  }

  /// Retrieve the theme from the widget tree.
  static NavToggleTheme of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<NavToggleThemeProvider>();
    return provider?.theme ?? const NavToggleTheme();
  }
}

/// InheritedWidget that propagates [NavToggleTheme] down the tree.
class NavToggleThemeProvider extends InheritedWidget {
  const NavToggleThemeProvider({
    super.key,
    required this.theme,
    required super.child,
  });

  final NavToggleTheme theme;

  @override
  bool updateShouldNotify(NavToggleThemeProvider oldWidget) =>
      theme != oldWidget.theme;
}
```

**Step 2: Add export to nav_toggle.dart**

Add to `lib/nav_toggle.dart`:
```dart
// Theme
export 'src/theme/nav_toggle_theme.dart';
```

**Step 3: Commit**

```bash
git add lib/src/theme/ lib/nav_toggle.dart
git commit -m "feat: add NavToggleTheme with design tokens and InheritedWidget"
```

---

## Task 3: Controller (NavToggleController)

**Files:**
- Create: `lib/src/controller/nav_toggle_controller.dart`
- Modify: `lib/nav_toggle.dart` (add export)

**Step 1: Write the controller**

`lib/src/controller/nav_toggle_controller.dart`:
```dart
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
```

**Step 2: Add export**

Add to `lib/nav_toggle.dart`:
```dart
// Controller
export 'src/controller/nav_toggle_controller.dart';
```

**Step 3: Commit**

```bash
git add lib/src/controller/ lib/nav_toggle.dart
git commit -m "feat: add NavToggleController with mode toggle state machine"
```

---

## Task 4: Animation helpers (NavTransition + CustomClippers)

**Files:**
- Create: `lib/src/animation/nav_transition.dart`
- Modify: `lib/nav_toggle.dart` (add export)

**Step 1: Write the transition helpers**

`lib/src/animation/nav_transition.dart`:
```dart
import 'dart:ui';
import 'package:flutter/widgets.dart';

/// Custom clipper that clips a sidebar panel from full size down to zero height,
/// or expands from zero height to full size.
class SidebarClipper extends CustomClipper<Rect> {
  SidebarClipper({required this.progress});

  /// 0.0 = fully clipped (hidden), 1.0 = fully visible.
  final double progress;

  @override
  Rect getClip(Size size) {
    // Clip from top, revealing downward as progress increases.
    final visibleHeight = size.height * progress;
    return Rect.fromLTWH(0, 0, size.width, visibleHeight);
  }

  @override
  bool shouldReclip(SidebarClipper oldClipper) =>
      oldClipper.progress != progress;
}

/// Custom clipper that clips a tab bar from zero width to full width,
/// or collapses from full width to zero.
class TabBarClipper extends CustomClipper<Rect> {
  TabBarClipper({required this.progress});

  /// 0.0 = fully clipped (hidden), 1.0 = fully visible.
  final double progress;

  @override
  Rect getClip(Size size) {
    // Clip from left, revealing rightward as progress increases.
    final visibleWidth = size.width * progress;
    return Rect.fromLTWH(0, 0, visibleWidth, size.height);
  }

  @override
  bool shouldReclip(TabBarClipper oldClipper) =>
      oldClipper.progress != progress;
}

/// Holds the phased CurvedAnimations derived from a single controller.
class NavTransitionAnimations {
  NavTransitionAnimations({
    required AnimationController controller,
    required double collapseEnd,
    required double iconMorphEnd,
    required Curve curve,
  })  : collapse = CurvedAnimation(
          parent: controller,
          curve: Interval(0.0, collapseEnd, curve: curve),
        ),
        expand = CurvedAnimation(
          parent: controller,
          curve: Interval(collapseEnd, 1.0, curve: curve),
        ),
        iconMorph = CurvedAnimation(
          parent: controller,
          curve: Interval(0.0, iconMorphEnd, curve: curve),
        );

  /// Collapse phase: 0.0 → 1.0 during the first portion.
  final CurvedAnimation collapse;

  /// Expand phase: 0.0 → 1.0 during the second portion.
  final CurvedAnimation expand;

  /// Icon morph: 0.0 → 1.0 over its own interval.
  final CurvedAnimation iconMorph;

  void dispose() {
    collapse.dispose();
    expand.dispose();
    iconMorph.dispose();
  }
}
```

**Step 2: Add export**

Add to `lib/nav_toggle.dart`:
```dart
// Animation
export 'src/animation/nav_transition.dart';
```

**Step 3: Commit**

```bash
git add lib/src/animation/ lib/nav_toggle.dart
git commit -m "feat: add NavTransition clippers and phased animation helpers"
```

---

## Task 5: Morphing icon (CustomPainter)

**Files:**
- Create: `lib/src/widgets/morphing_icon.dart`

**Step 1: Write the morphing icon painter and widget**

`lib/src/widgets/morphing_icon.dart`:
```dart
import 'dart:ui';
import 'package:flutter/widgets.dart';

/// Paints the toggle button icon that morphs between sidebar and tab bar states.
///
/// Sidebar state (t=0): 3 horizontal lines of unequal length + vertical bar on right.
/// Tab bar state (t=1): 3 horizontal lines of equal wider length, vertical bar faded out.
class MorphingIconPainter extends CustomPainter {
  MorphingIconPainter({
    required this.t,
    required this.color,
  });

  /// Animation value: 0.0 = sidebar icon, 1.0 = tab bar icon.
  final double t;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.5;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // --- Three horizontal lines ---
    // Sidebar: unequal widths (18, 14, 10), offset left of center.
    // Tab bar: equal width (20), centered.
    const lineGap = 6.0;

    // Line widths: sidebar → tabbar
    final w1 = lerpDouble(18, 20, t)!;
    final w2 = lerpDouble(14, 20, t)!;
    final w3 = lerpDouble(10, 20, t)!;

    // X positions: sidebar lines start from a left offset; tabbar lines are centered.
    // In sidebar mode, lines are left-aligned at cx - 10.
    // In tabbar mode, lines are centered at cx.
    final sidebarLeft = cx - 10;
    final tabBarCenter = cx;

    final x1Start = lerpDouble(sidebarLeft, tabBarCenter - w1 / 2, t)!;
    final x2Start = lerpDouble(sidebarLeft, tabBarCenter - w2 / 2, t)!;
    final x3Start = lerpDouble(sidebarLeft, tabBarCenter - w3 / 2, t)!;

    final y1 = cy - lineGap;
    final y2 = cy;
    final y3 = cy + lineGap;

    canvas.drawLine(Offset(x1Start, y1), Offset(x1Start + w1, y1), paint);
    canvas.drawLine(Offset(x2Start, y2), Offset(x2Start + w2, y2), paint);
    canvas.drawLine(Offset(x3Start, y3), Offset(x3Start + w3, y3), paint);

    // --- Vertical bar (sidebar only, fades out) ---
    if (t < 1.0) {
      final barPaint = Paint()
        ..color = color.withValues(alpha: color.a * (1.0 - t))
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 2.5;

      final barX = lerpDouble(cx + 8, cx + 12, t)!;
      final barTop = cy - lineGap - 2;
      final barBottom = cy + lineGap + 2;

      canvas.drawLine(Offset(barX, barTop), Offset(barX, barBottom), barPaint);
    }
  }

  @override
  bool shouldRepaint(MorphingIconPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.color != color;
}

/// Widget wrapper for the morphing icon, driven by an Animation<double>.
class MorphingIcon extends StatelessWidget {
  const MorphingIcon({
    super.key,
    required this.animation,
    required this.color,
    this.size = 40.0,
  });

  final Animation<double> animation;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return CustomPaint(
          size: Size(size, size),
          painter: MorphingIconPainter(
            t: animation.value,
            color: color,
          ),
        );
      },
    );
  }
}
```

**Step 2: Commit**

```bash
git add lib/src/widgets/morphing_icon.dart
git commit -m "feat: add MorphingIconPainter with sidebar/tabbar icon morph"
```

---

## Task 6: Toggle button widget

**Files:**
- Create: `lib/src/widgets/toggle_button.dart`

**Step 1: Write the toggle button**

`lib/src/widgets/toggle_button.dart`:
```dart
import 'package:flutter/widgets.dart';
import '../theme/nav_toggle_theme.dart';

/// The 200×52 toggle button fixed at the top-left corner.
///
/// Contains the morphing icon and handles hover state.
/// The button is non-interactive during animations.
class ToggleButton extends StatefulWidget {
  const ToggleButton({
    super.key,
    required this.iconAnimation,
    required this.onPressed,
    required this.isSidebarMode,
    this.enabled = true,
  });

  final Animation<double> iconAnimation;
  final VoidCallback? onPressed;
  final bool isSidebarMode;
  final bool enabled;

  @override
  State<ToggleButton> createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<ToggleButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = NavToggleTheme.of(context);
    final hoverBg = _hovering && widget.enabled
        ? HSLColor.fromColor(theme.surface).withLightness(
            (HSLColor.fromColor(theme.surface).lightness + 0.05)
                .clamp(0.0, 1.0),
          ).toColor()
        : theme.surface;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: widget.enabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.enabled ? widget.onPressed : null,
        child: Semantics(
          button: true,
          label: widget.isSidebarMode
              ? 'Switch to tab bar navigation'
              : 'Switch to sidebar navigation',
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: theme.buttonWidth,
            height: theme.buttonHeight,
            decoration: BoxDecoration(
              color: hoverBg,
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(theme.cornerRadius),
              ),
              border: Border(
                bottom: BorderSide(color: theme.border, width: 1),
                right: BorderSide(color: theme.border, width: 1),
              ),
              boxShadow: _hovering && widget.enabled
                  ? [
                      BoxShadow(
                        color: theme.accent.withValues(alpha: 0.15),
                        blurRadius: 0,
                        spreadRadius: 1,
                        // Inset ring effect simulated with a tight shadow
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: AnimatedBuilder(
                animation: widget.iconAnimation,
                builder: (context, _) {
                  return CustomPaint(
                    size: const Size(40, 40),
                    painter: _MorphingIconPainter(
                      t: widget.iconAnimation.value,
                      color: theme.accent,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Inline painter — same logic as MorphingIconPainter but kept here
/// to avoid circular imports and keep toggle_button self-contained.
class _MorphingIconPainter extends CustomPainter {
  _MorphingIconPainter({required this.t, required this.color});

  final double t;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.5;

    final cx = size.width / 2;
    final cy = size.height / 2;
    const lineGap = 6.0;

    final w1 = _lerp(18, 20, t);
    final w2 = _lerp(14, 20, t);
    final w3 = _lerp(10, 20, t);

    final sidebarLeft = cx - 10;
    final x1 = _lerp(sidebarLeft, cx - w1 / 2, t);
    final x2 = _lerp(sidebarLeft, cx - w2 / 2, t);
    final x3 = _lerp(sidebarLeft, cx - w3 / 2, t);

    canvas.drawLine(
        Offset(x1, cy - lineGap), Offset(x1 + w1, cy - lineGap), paint);
    canvas.drawLine(Offset(x2, cy), Offset(x2 + w2, cy), paint);
    canvas.drawLine(
        Offset(x3, cy + lineGap), Offset(x3 + w3, cy + lineGap), paint);

    if (t < 1.0) {
      final barPaint = Paint()
        ..color = color.withValues(alpha: color.a * (1.0 - t))
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 2.5;
      final barX = _lerp(cx + 8, cx + 12, t);
      canvas.drawLine(
        Offset(barX, cy - lineGap - 2),
        Offset(barX, cy + lineGap + 2),
        barPaint,
      );
    }
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  @override
  bool shouldRepaint(_MorphingIconPainter old) =>
      old.t != t || old.color != color;
}
```

**Step 2: Commit**

```bash
git add lib/src/widgets/toggle_button.dart
git commit -m "feat: add ToggleButton with hover states and morphing icon"
```

---

## Task 7: Sidebar panel widget

**Files:**
- Create: `lib/src/widgets/sidebar_panel.dart`

**Step 1: Write the sidebar panel**

`lib/src/widgets/sidebar_panel.dart`:
```dart
import 'package:flutter/widgets.dart';
import '../models/nav_item.dart';
import '../theme/nav_toggle_theme.dart';

/// The sidebar navigation panel — 200px wide, fills height below the button.
class SidebarPanel extends StatelessWidget {
  const SidebarPanel({
    super.key,
    required this.items,
    required this.selectedId,
    required this.onItemSelected,
  });

  final List<NavItem> items;
  final String selectedId;
  final ValueChanged<String> onItemSelected;

  @override
  Widget build(BuildContext context) {
    final theme = NavToggleTheme.of(context);

    return Container(
      width: theme.sidebarWidth,
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border(
          right: BorderSide(color: theme.border, width: 1),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 2),
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = item.id == selectedId;
                return _SidebarItem(
                  item: item,
                  isSelected: isSelected,
                  onTap: () => onItemSelected(item.id),
                  theme: theme,
                );
              },
            ),
          ),
          // Bottom status area
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'v1.0.0',
              style: TextStyle(
                fontFamily: theme.monoFontFamily,
                fontSize: 11,
                color: theme.textDim,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  const _SidebarItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  final NavItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final NavToggleTheme theme;

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    Color bg;
    Color textColor;
    Color iconColor;

    if (widget.isSelected) {
      bg = theme.accent.withValues(alpha: 0.1);
      textColor = theme.accent;
      iconColor = theme.accent;
    } else if (_hovering) {
      bg = const Color(0xFF1E2030);
      textColor = theme.text;
      iconColor = theme.text;
    } else {
      bg = const Color(0x00000000);
      textColor = theme.textDim;
      iconColor = theme.textDim;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(theme.itemRadius),
          ),
          child: Row(
            children: [
              Icon(widget.item.icon, size: 18, color: iconColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.item.label,
                  style: TextStyle(
                    fontFamily: theme.navFontFamily,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

**Step 2: Commit**

```bash
git add lib/src/widgets/sidebar_panel.dart
git commit -m "feat: add SidebarPanel with nav items and hover/active states"
```

---

## Task 8: Tab bar panel widget

**Files:**
- Create: `lib/src/widgets/tab_bar_panel.dart`

**Step 1: Write the tab bar panel**

`lib/src/widgets/tab_bar_panel.dart`:
```dart
import 'package:flutter/widgets.dart';
import '../models/nav_item.dart';
import '../theme/nav_toggle_theme.dart';

/// The horizontal tab bar panel — extends from button's right edge to screen right.
class TabBarPanel extends StatelessWidget {
  const TabBarPanel({
    super.key,
    required this.items,
    required this.selectedId,
    required this.onItemSelected,
    this.onAddPressed,
  });

  final List<NavItem> items;
  final String selectedId;
  final ValueChanged<String> onItemSelected;
  final VoidCallback? onAddPressed;

  @override
  Widget build(BuildContext context) {
    final theme = NavToggleTheme.of(context);

    return Container(
      height: theme.buttonHeight,
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border(
          bottom: BorderSide(color: theme.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Tab items
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0)
              Container(
                width: 1,
                height: 24,
                color: theme.border,
              ),
            _TabItem(
              item: items[i],
              isSelected: items[i].id == selectedId,
              onTap: () => onItemSelected(items[i].id),
              theme: theme,
            ),
          ],
          const Spacer(),
          // Add button
          if (onAddPressed != null)
            _AddButton(onTap: onAddPressed!, theme: theme),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _TabItem extends StatefulWidget {
  const _TabItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  final NavItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final NavToggleTheme theme;

  @override
  State<_TabItem> createState() => _TabItemState();
}

class _TabItemState extends State<_TabItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    Color bg;
    Color textColor;

    if (widget.isSelected) {
      bg = theme.accent.withValues(alpha: 0.1);
      textColor = theme.accent;
    } else if (_hovering) {
      bg = const Color(0xFF1E2030);
      textColor = theme.text;
    } else {
      bg = const Color(0x00000000);
      textColor = theme.textDim;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(theme.itemRadius),
          ),
          child: Center(
            child: Text(
              widget.item.label.toUpperCase(),
              style: TextStyle(
                fontFamily: theme.navFontFamily,
                fontWeight: FontWeight.w700,
                fontSize: 12,
                letterSpacing: 1.5,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AddButton extends StatefulWidget {
  const _AddButton({required this.onTap, required this.theme});

  final VoidCallback onTap;
  final NavToggleTheme theme;

  @override
  State<_AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<_AddButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _hovering
                ? widget.theme.accent.withValues(alpha: 0.1)
                : const Color(0x00000000),
            borderRadius: BorderRadius.circular(widget.theme.itemRadius),
          ),
          child: Center(
            child: Text(
              '+',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _hovering
                    ? widget.theme.accent
                    : widget.theme.textDim,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

**Step 2: Commit**

```bash
git add lib/src/widgets/tab_bar_panel.dart
git commit -m "feat: add TabBarPanel with pill-style tabs and add button"
```

---

## Task 9: NavToggleScaffold — the main orchestrator

**Files:**
- Create: `lib/src/widgets/nav_toggle_scaffold.dart`
- Modify: `lib/nav_toggle.dart` (add widget exports)

**Step 1: Write the scaffold that orchestrates everything**

`lib/src/widgets/nav_toggle_scaffold.dart`:
```dart
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../animation/nav_transition.dart';
import '../controller/nav_toggle_controller.dart';
import '../models/nav_item.dart';
import '../models/nav_mode.dart';
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
    this.onAddPressed,
  });

  final List<NavItem> items;
  final Widget child;
  final NavToggleTheme? theme;
  final NavMode initialMode;
  final String? initialSelectedId;
  final ValueChanged<String>? onItemSelected;
  final VoidCallback? onAddPressed;

  @override
  State<NavToggleScaffold> createState() => _NavToggleScaffoldState();
}

class _NavToggleScaffoldState extends State<NavToggleScaffold>
    with SingleTickerProviderStateMixin {
  late final NavToggleController _controller;
  late final AnimationController _animController;
  late NavTransitionAnimations _animations;

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

    _animController.addStatusListener(_onAnimationStatus);
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _controller.onExpandComplete();
      _animController.reset();
    }
  }

  /// Listen to collapse progress to trigger mode flip.
  void _checkCollapseComplete() {
    final collapseEnd = _theme.collapseEnd;
    if (_animController.value >= collapseEnd &&
        _controller.animState == NavAnimState.collapsing) {
      _controller.onCollapseComplete();
    }
  }

  void _onTogglePressed() {
    if (!_controller.canToggle) return;

    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    if (reduceMotion) {
      // Instant swap
      _controller.beginToggle();
      _controller.onCollapseComplete();
      _controller.onExpandComplete();
    } else {
      _controller.beginToggle();
      _animController.addListener(_checkCollapseComplete);
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
      // Old panel is collapsing
      if (mode == NavMode.sidebar) {
        sidebarProgress = 1.0 - _animations.collapse.value;
        tabBarProgress = 0.0;
      } else {
        tabBarProgress = 1.0 - _animations.collapse.value;
        sidebarProgress = 0.0;
      }
    } else {
      // New panel is expanding
      if (mode == NavMode.sidebar) {
        sidebarProgress = _animations.expand.value;
        tabBarProgress = 0.0;
      } else {
        tabBarProgress = _animations.expand.value;
        sidebarProgress = 0.0;
      }
    }

    // Content padding
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
                onAddPressed: widget.onAddPressed,
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
```

**Step 2: Update exports in nav_toggle.dart**

Final `lib/nav_toggle.dart`:
```dart
/// A dual-mode navigation toggle widget that morphs between
/// sidebar and tab bar layouts.
library;

// Models
export 'src/models/nav_item.dart';
export 'src/models/nav_mode.dart';

// Controller
export 'src/controller/nav_toggle_controller.dart';

// Theme
export 'src/theme/nav_toggle_theme.dart';

// Animation
export 'src/animation/nav_transition.dart';

// Widgets
export 'src/widgets/nav_toggle_scaffold.dart';
export 'src/widgets/toggle_button.dart';
export 'src/widgets/sidebar_panel.dart';
export 'src/widgets/tab_bar_panel.dart';
export 'src/widgets/morphing_icon.dart';
```

**Step 3: Commit**

```bash
git add lib/
git commit -m "feat: add NavToggleScaffold orchestrating panels, button, and animations"
```

---

## Task 10: Example app

**Files:**
- Modify: `example/lib/main.dart`

**Step 1: Write the full example app**

`example/lib/main.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:nav_toggle/nav_toggle.dart';

void main() => runApp(const NavToggleExampleApp());

class NavToggleExampleApp extends StatelessWidget {
  const NavToggleExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NavToggle Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D0E11),
      ),
      home: const NavToggleDemo(),
    );
  }
}

class NavToggleDemo extends StatefulWidget {
  const NavToggleDemo({super.key});

  @override
  State<NavToggleDemo> createState() => _NavToggleDemoState();
}

class _NavToggleDemoState extends State<NavToggleDemo> {
  String _selectedId = 'home';

  static const _items = [
    NavItem(id: 'home', label: 'Home', icon: Icons.home_outlined),
    NavItem(id: 'explore', label: 'Explore', icon: Icons.explore_outlined),
    NavItem(id: 'library', label: 'Library', icon: Icons.library_books_outlined),
    NavItem(id: 'favorites', label: 'Favorites', icon: Icons.favorite_outline),
    NavItem(id: 'settings', label: 'Settings', icon: Icons.settings_outlined),
  ];

  static const _pageColors = {
    'home': Color(0xFF7DF3C0),
    'explore': Color(0xFF5BC8F5),
    'library': Color(0xFFF5A55B),
    'favorites': Color(0xFFF57B7B),
    'settings': Color(0xFFB57BF5),
  };

  @override
  Widget build(BuildContext context) {
    final color = _pageColors[_selectedId] ?? const Color(0xFF7DF3C0);
    final label = _items.firstWhere((i) => i.id == _selectedId).label;

    return NavToggleScaffold(
      items: _items,
      initialSelectedId: 'home',
      onItemSelected: (id) => setState(() => _selectedId = id),
      onAddPressed: () {
        // Demo: show a snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add button pressed')),
        );
      },
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _items.firstWhere((i) => i.id == _selectedId).icon,
              size: 64,
              color: color,
            ),
            const SizedBox(height: 16),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Syne',
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Click the toggle button to switch modes',
              style: TextStyle(
                fontFamily: 'DMMono',
                fontSize: 14,
                color: const Color(0xFF5A6070),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Step 2: Commit**

```bash
git add example/
git commit -m "feat: add example app demonstrating NavToggle"
```

---

## Task 11: Download and bundle fonts

**Files:**
- Create: `assets/fonts/Syne-Regular.ttf`
- Create: `assets/fonts/Syne-SemiBold.ttf`
- Create: `assets/fonts/Syne-Bold.ttf`
- Create: `assets/fonts/Syne-ExtraBold.ttf`
- Create: `assets/fonts/DMMono-Regular.ttf`
- Create: `assets/fonts/DMMono-Medium.ttf`

**Step 1: Download fonts from Google Fonts**

```bash
mkdir -p assets/fonts
# Download Syne family
curl -L "https://fonts.google.com/download?family=Syne" -o /tmp/syne.zip
unzip -o /tmp/syne.zip -d /tmp/syne_fonts
cp /tmp/syne_fonts/static/Syne-Regular.ttf assets/fonts/
cp /tmp/syne_fonts/static/Syne-SemiBold.ttf assets/fonts/
cp /tmp/syne_fonts/static/Syne-Bold.ttf assets/fonts/
cp /tmp/syne_fonts/static/Syne-ExtraBold.ttf assets/fonts/

# Download DM Mono family
curl -L "https://fonts.google.com/download?family=DM+Mono" -o /tmp/dmmono.zip
unzip -o /tmp/dmmono.zip -d /tmp/dmmono_fonts
cp /tmp/dmmono_fonts/DMMono-Regular.ttf assets/fonts/
cp /tmp/dmmono_fonts/DMMono-Medium.ttf assets/fonts/
```

**Step 2: Verify fonts are in place**

```bash
ls -la assets/fonts/
```

Expected: 6 TTF files present.

**Step 3: Commit**

```bash
git add assets/
git commit -m "feat: bundle Syne and DM Mono font families"
```

---

## Task 12: Integration test — run the example app

**Step 1: Run flutter analyze**

```bash
cd /Users/hualinliang/Project/flutter_tmp && flutter analyze
```

Expected: No errors.

**Step 2: Run flutter test (if any tests exist)**

```bash
flutter test
```

**Step 3: Run the example app**

```bash
cd example && flutter run -d macos
```

Expected: App launches, toggle button visible at top-left, clicking it transitions between sidebar and tab bar modes.

**Step 4: Verify animation behavior**

- Click toggle button → sidebar collapses into button, then tab bar expands from button
- Click again → tab bar collapses, sidebar expands
- Button is non-interactive during animation
- Hover states work on button and nav items
- Content area slides with the mode change

**Step 5: Final commit**

```bash
git add -A
git commit -m "chore: verify integration and fix any remaining issues"
```
