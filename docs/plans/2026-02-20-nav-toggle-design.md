# NavToggle — Flutter Package Design

**Date:** 2026-02-20
**Status:** Approved

---

## Overview

A standalone Flutter package providing a dual-mode navigation toggle widget. A fixed 200x52 button at the viewport's top-left corner switches the app layout between Sidebar mode and Tab Bar mode. The button and its associated panel are one unified object — the panel physically expands from / collapses into the button.

## Decisions

| Decision | Choice | Rationale |
|---|---|---|
| Package type | Standalone reusable package | Consistent with existing flutter_morphing_navigation |
| Animation approach | Faithful adaptation of CSS spec | ClipRect + AnimationController, same timing/easing |
| State management | Provider + ChangeNotifier | Matches existing project patterns |
| Fonts | Bundled in package | No network dependency (Syne, DM Mono) |
| Implementation | Single AnimationController with phased intervals | Clean state machine, centralized logic |

## Package Structure

```
nav_toggle/
├── lib/
│   ├── nav_toggle.dart                    # Public API exports
│   └── src/
│       ├── models/
│       │   ├── nav_item.dart              # NavItem data model
│       │   └── nav_mode.dart              # NavMode enum + NavAnimState enum
│       ├── controller/
│       │   └── nav_toggle_controller.dart # ChangeNotifier
│       ├── theme/
│       │   └── nav_toggle_theme.dart      # Design tokens + InheritedWidget
│       ├── widgets/
│       │   ├── nav_toggle_scaffold.dart   # Top-level scaffold
│       │   ├── toggle_button.dart         # 200x52 toggle button
│       │   ├── sidebar_panel.dart         # Sidebar nav items
│       │   ├── tab_bar_panel.dart         # Tab bar strip
│       │   └── morphing_icon.dart         # CustomPainter for icon morph
│       └── animation/
│           └── nav_transition.dart        # Interval defs + CustomClipper
├── assets/fonts/                          # Bundled Syne + DM Mono
├── example/lib/main.dart                  # Demo app
└── pubspec.yaml
```

## Models

```dart
class NavItem {
  final String id;
  final String label;
  final IconData icon;
  final bool isActive;
}

enum NavMode { sidebar, tabBar }

enum NavAnimState { idle, collapsing, expanding }
```

## Animation Architecture

Single AnimationController, total duration 970ms.

| Phase | Interval | Duration | Purpose |
|---|---|---|---|
| Collapse | 0.0–0.433 | 420ms | Old panel shrinks into button |
| Expand | 0.433–1.0 | 550ms | New panel grows from button |
| Icon morph | 0.0–0.464 | 450ms | Icon transitions between states |

Easing: `Cubic(0.77, 0, 0.18, 1)` on all phases.

### Collapse/Expand Mechanics

- ClipRect + CustomClipper driven by animation value
- Sidebar: clips vertically (shrinks height toward top)
- Tab bar: clips horizontally (shrinks width toward left)
- Mode flips at interval boundary (0.433)

### Content Area

AnimatedPadding (480ms, same easing) shifts from left:200 (sidebar) to top:52 (tab bar).

### Button Lock

Button onTap is null when NavAnimState != idle.

### Reduced Motion

MediaQuery.disableAnimations → instant state swap, duration = 0.

## Widget Tree

```
NavToggleScaffold (StatefulWidget — owns AnimationController)
├── NavToggleThemeProvider (InheritedWidget)
├── ChangeNotifierProvider<NavToggleController>
└── Stack
    ├── AnimatedPadding (content area)
    ├── Positioned (sidebar panel + ClipRect)
    ├── Positioned (tab bar panel + ClipRect)
    └── Positioned (toggle button — always on top)
```

## Visual Design Tokens

| Token | Value |
|---|---|
| Button height / tab bar height | 52px |
| Button width / sidebar width | 200px |
| Page background | #0d0e11 |
| Surface color | #161820 |
| Border | rgba(255,255,255,0.07) |
| Accent | #7DF3C0 |
| Accent2 | #5BC8F5 |
| Text | #c8cdd8 |
| Text dim | #5a6070 |
| Easing | cubic-bezier(0.77, 0, 0.18, 1) |
| Nav font | Syne 600–800 |
| Mono font | DM Mono |

## Toggle Button

- 200x52, positioned at (0,0), flush to viewport
- Only bottom-right corner radius: 14px
- Border on bottom and right edges only
- Hover: lighter background + accent inset ring
- CustomPaint icon morphs between sidebar/tabbar states

## Sidebar Panel

- 200px wide, full remaining height below button
- Items: icon + label, rounded 8px, three states (default/hover/active)
- Active: accent.withOpacity(0.1) background + accent text
- Bottom section for status/version info

## Tab Bar Panel

- Extends from x=200 to screen right, 52px tall
- Pill-style tabs: uppercase, Syne 12–13px, letter-spacing 1.5
- Vertical dividers between tabs
- + button at far right
- Active: same accent tint as sidebar
