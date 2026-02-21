import 'package:flutter/widgets.dart';

/// Design tokens and theme configuration for NavToggle.
class NavToggleTheme {
  const NavToggleTheme({
    this.buttonHeight = 52.0,
    this.buttonWidth = 200.0,
    this.sidebarWidth = 200.0,
    this.background = const Color(0xFFF5F5F7),
    this.surface = const Color(0xFFFFFFFF),
    this.border = const Color(0x1A000000),
    this.accent = const Color(0xFF10B981),
    this.accent2 = const Color(0xFF3B82F6),
    this.text = const Color(0xFF1F2937),
    this.textDim = const Color(0xFF9CA3AF),
    this.hoverSurface = const Color(0xFFF0F0F2),
    this.cornerRadius = 0.0,
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
  final Color hoverSurface;
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
    Color? hoverSurface,
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
      hoverSurface: hoverSurface ?? this.hoverSurface,
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
