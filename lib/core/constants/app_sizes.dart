class AppSizes {
  // The design frame: iPhone 16 Pro, the device every screen in
  // `Nasam _ Mobile.fig` is drawn on. Every `.sp` and `.w` in the app is
  // scaled against this, so it lives here rather than being repeated at each
  // ScreenUtilInit call site.
  static const double designWidth = 402.0;
  static const double designHeight = 874.0;

  // Spacing and Padding
  static const double p2 = 2.0;
  static const double p4 = 4.0;
  static const double p8 = 8.0;
  static const double p12 = 12.0;
  static const double p16 = 16.0;
  static const double p20 = 20.0;
  static const double p24 = 24.0;
  static const double p32 = 32.0;
  static const double p40 = 40.0;
  static const double p48 = 48.0;

  // Border Radii
  static const double r4 = 4.0;
  static const double r8 = 8.0;
  static const double r12 = 12.0;
  static const double r16 = 16.0;
  static const double r20 = 20.0;
  static const double r24 = 24.0;
  static const double r32 = 32.0;

  // Icon Sizes
  static const double iconXs = 12.0;
  static const double iconSm = 16.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;

  // Button and Input Heights
  static const double buttonHeight = 50.0;
  static const double inputHeight = 50.0;
  static const double appBarHeight = 56.0;
}
