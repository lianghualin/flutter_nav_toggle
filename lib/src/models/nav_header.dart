import 'package:flutter/widgets.dart';

/// Header configuration displayed at the top of navigation panels.
class NavHeader {
  const NavHeader({
    this.logo,
    this.title,
    this.subtitle,
  });

  /// An optional logo widget (e.g. Image, Icon, SvgPicture).
  final Widget? logo;

  /// Optional title text shown beside or below the logo.
  final String? title;

  /// Optional subtitle text shown below the title.
  final String? subtitle;
}
