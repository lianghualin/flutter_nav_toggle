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
