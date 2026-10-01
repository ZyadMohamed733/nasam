class AppSizes {
  // The design frame: iPhone 16 Pro, the device every screen in
  // `Nasam _ Mobile.fig` is drawn on. Every `.sp` and `.w` in the app is
  // scaled against this, so it lives here rather than being repeated at each
  // ScreenUtilInit call site.
  static const double designWidth = 402.0;
  static const double designHeight = 874.0;

  // Shared drawer geometry relative to the design frame.
  static const double drawerOpenRatio = .73;
  static const double drawerOpenScale = .94;
  static const double drawerInitialScale = .92;
  static const double drawerSlideRatio = .12;
  static const double drawerMaxWidth = 360;
  static const double drawerArtworkAspectRatio = 402 / 268;
  static const double drawerFooterHeight = 120;
  static const double drawerAvatarRadius = 21;
  static const double drawerIconSize = 19;

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
  static const double iconXXl = 64.0;

  // Button and Input Heights, measured from the Figma components.
  static const double buttonHeight = 44.0;
  static const double inputHeight = 44.0;
  static const double appBarHeight = 44.0;

  // Layout values measured from the design, named for the job they do rather
  // than their number: unlike the p*/r*/icon* scales above these are semantic,
  // so a screen that needs "the auth form column" should not have to know that
  // it happens to be 328 wide this month.
  //
  // All are design points against the 402x874 frame.

  /// Side padding on onboarding and general screens.
  static const double screenPadding = 16.0;

  /// Auth form column width — 328 inside the 402pt frame, so 37 a side.
  static const double formContentWidth = 328.0;

  /// Onboarding content column width — 370 inside the frame, so 16 a side.
  static const double onboardingContentWidth = 370.0;

  /// The onboarding call-to-action button, narrower than its content column.
  static const double onboardingButtonWidth = 297.0;

  static const double iconButtonMedium = 40.0;
  static const double iconButtonSmall = 32.0;

  /// Label row + field, no helper text, at the design's own text scale. The
  /// block grows past this when the user raises the system font size, so treat
  /// it as the space to reserve, not as a fixed height to impose.
  static const double inputBlockHeight = 72.0;

  /// Label row + field + helper text, at the design's own text scale.
  static const double inputBlockWithHelper = 91.0;

  /// The logo as it appears on the auth screens.
  static const double logoAuth = 48.0;

  /// The OTP entry block: digit fields, countdown line and resend action.
  static const double otpBlockHeight = 294.0;
}
