# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Development Commands

```bash
flutter pub get                          # Install dependencies
flutter analyze                          # Lint / static analysis
flutter test                             # Run all tests
cd example && flutter run -d chrome      # Run example app (web)
```

No test files exist yet. The package uses `flutter_lints` for analysis rules.

## Architecture

This is a Flutter package (`flutter_nav_toggle`) that provides a dual-mode navigation widget morphing between sidebar and tab bar layouts.

### State Machine

`NavToggleController` (ChangeNotifier) drives a three-state animation machine:

```
idle → collapsing → expanding → idle
```

- `beginToggle()` starts the sequence, sets `_pendingMode` to the opposite mode
- At the collapse→expand boundary, `onCollapseComplete()` flips `_mode` to `_pendingMode`
- `canToggle` returns false during animation, disabling the button

### Animation System

A single `AnimationController` in `NavToggleScaffold` drives all transitions via phased `Interval`s defined in `NavTransitionAnimations`:

- **Collapse phase** (0.0–0.433): old panel shrinks via `SidebarClipper`/`TabBarClipper`
- **Expand phase** (0.433–1.0): new panel grows
- **Icon morph** (0.0–0.464): toggle button icon transitions

Custom easing: `Cubic(0.77, 0, 0.18, 1)`. Respects `MediaQuery.disableAnimations`.

### Theme System

`NavToggleTheme` holds all design tokens (colors, dimensions, durations, font families). Propagated via `NavToggleThemeProvider` (InheritedWidget), accessed with `NavToggleTheme.of(context)`.

Key defaults: buttonWidth=200, sidebarWidth=200, buttonHeight=52, accent=#10B981, fonts: Syne (nav labels), DMMono (mono/values).

### Widget Hierarchy

`NavToggleScaffold` owns the AnimationController and composes everything in a Stack:
1. `AnimatedPadding` — content area with dynamic left/top insets
2. `SidebarPanel` — positioned left, clipped during transitions
3. `TabBarPanel` — positioned top, clipped during transitions
4. `ToggleButton` — always on top (z-order)

### Hierarchical Navigation

`NavItem` supports optional `children`. In sidebar mode, parents expand/collapse with `SizeTransition`. In tab bar mode, parents open an `Overlay`-based dropdown positioned via `CompositedTransformFollower` + `LayerLink`.

### Status Panel

`StatusPanel` shows CPU/MEM/DISK progress bars and warning count at the sidebar bottom. Color-coded by threshold: green (<60%), amber (60-80%), red (>=80%). Pass `SystemStatus` to `NavToggleScaffold` to enable; otherwise falls back to version text.

## Key Conventions

- Private widgets use underscore prefix and live in the same file as their parent (e.g., `_SidebarItem`, `_TabItem`)
- Hover state: `MouseRegion` + `setState` with instant `Container` (no `AnimatedContainer` — causes double-highlight blink)
- Selected state: `theme.accent.withValues(alpha: 0.1)` background, `theme.accent` text
- All colors/dimensions come from `NavToggleTheme` — no hardcoded values in widgets
- Single dependency: `provider` ^6.1.2 for ChangeNotifier propagation
- Public API exported from `lib/flutter_nav_toggle.dart` barrel file
