## 1.2.3

- Fix CJK text rendering artifacts — `navFontFamily` and `monoFontFamily` now default to `null` (system font) instead of Latin-only `'Syne'`/`'DMMono'`
- Remove boilerplate example test and fix example analysis configuration

## 1.2.2

- Fix yellow double-underlined text by wrapping widgets with `DefaultTextStyle` to override the default inherited style

## 1.2.1

- Fix infinite widget tree loop when `autoResponsive` is enabled — `LayoutBuilder` was returning itself instead of its child content

## 1.2.0

- Add auto-responsive mode with configurable breakpoints (`autoResponsive`, `breakpointSidebar`, `breakpointRail` on `NavToggleTheme`)
- Add overlay sidebar mode — floating sidebar with scrim dismiss on narrow screens when auto-responsive is enabled
- Add `userName`, `onWarningTap`, and `copyWith()` to `SystemStatus` model
- Add `updateStatus()` and `updateStatusSilent()` to `NavToggleController` for high-frequency status updates
- Tappable warning row with hover feedback when `onWarningTap` is set
- Add `isOverlay`, `showOverlaySidebar()`, `dismissOverlay()` to `NavToggleController`
- Keyboard shortcut `T` supports overlay show/dismiss on narrow screens

## 1.1.1

- Add `UserMenuItem` model and `UserInfo.menuItems` for flyout popup menus
- User avatar tap opens a configurable flyout menu (sidebar: right, icon rail: right, tab bar: down)
- Flyout dismissed by tapping outside or toggling the avatar
- Falls back to `onTap` when `menuItems` is null/empty (backward compatible)
- Sidebar flyout hides header to avoid duplicating visible name/role
- Add `iconColor` field on `NavItem` for per-item icon coloring
- Add `time` field on `SystemStatus` with clock display in all panel modes

## 1.1.0

- Add badge support on `NavItem` with aggregate counts on expandable parents
- Add `NavHeader` model for branding (logo, title, subtitle) merged into toggle button
- Add `NavToggleScaffold.withPages()` constructor with animated page transitions (fade, slide, fadeThrough)
- Add `showPageHeader` option to display selected item icon and label above content
- Add keyboard shortcut support (`T` key to toggle navigation mode)
- Add `onTap` callback to `UserInfo` with hover feedback on all panel variants
- Hide hamburger icon when header branding is present via `showModeIcon`
- Fix badge vertical alignment across all sidebar items
- Upgrade `morphing_button` to ^0.1.3

## 1.0.1

- Fix example GIF not displaying on pub.dev (use absolute URL)

## 1.0.0

- Dual-mode navigation: sidebar and tab bar layouts with smooth morphing transitions
- Phased clip-path animations driven by a single `AnimationController`
- Morphing toggle button with cursor-tracking directional arrows (powered by `morphing_button`)
- Hierarchical navigation items with expand/collapse (sidebar) and overlay dropdowns (tab bar)
- Status panel with CPU/MEM/DISK progress bars and color-coded thresholds
- User info display (avatar panel in sidebar, chip in tab bar)
- 4 built-in theme presets: Light, Dark, Ocean, Sunset
- Full theming via `NavToggleTheme` with `copyWith` support
- Accessibility: respects `MediaQuery.disableAnimations`
