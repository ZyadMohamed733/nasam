import 'package:flutter/material.dart';

import 'breakpoints.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (AppBreakpoints.isDesktop(width)) {
          return desktop ?? tablet ?? mobile;
        } else if (AppBreakpoints.isTablet(width)) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}
