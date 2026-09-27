/// The single registry for every asset bundled with the app.
///
/// Paths are `const`, so a typo is a compile error rather than a grey box at
/// runtime, and `app_assets_test.dart` walks [all] to prove each file exists on
/// disk and is actually declared in pubspec.yaml. Nothing outside this file
/// should spell an asset path as a string literal.
///
/// Adding an asset means three things: drop the file in `assets/`, add a const
/// here, and add it to [all]. The test fails if you skip either of the last
/// two.
abstract final class AppAssets {
  static const String _images = 'assets/images';

  static const String mapArrow = 'assets/icons/map_arrow.svg';
  static const String mapArrowLeft = 'assets/icons/map_ arrow_ left.svg';
  static const String trackingMenu = 'assets/icons/tracking_menu.svg';
  static const String mapLayers = 'assets/icons/layers.svg';
  static const String mapNotification = 'assets/icons/notification.svg';
  static const String mapZoomIn = 'assets/icons/zoom_in.svg';
  static const String mapZoomOut = 'assets/icons/zoom_out.svg';
  static const String playIcon = 'assets/icons/play_icon.svg';
  static const String playOutlineIcon = 'assets/icons/play_outline_icon.svg';
  static const String pauseIcon = 'assets/icons/pause_icon.svg';
  static const String gps = 'assets/icons/GPS.svg';
  static const String message = 'assets/icons/message.svg';
  static const String videoCameraRecord = 'assets/icons/video_camer_record.svg';
  static const String email = 'assets/icons/email.svg';
  static const String phoneCalling = 'assets/icons/phone_ calling.svg';

  // Images.
  static const String successMark = '$_images/password_reset_success.png';
  static const String splashBackground = '$_images/splash_background.png';
  static const String splashParticles = '$_images/signal_particles_splash.gif';
  static const String logoMark = '$_images/logo_mark.png';
  static const String logoVector = '$_images/Vector.svg';
  static const String onboarding1 = '$_images/onboarding_1.png';
  static const String onboarding2 = '$_images/onboarding_2.png';
  static const String onboarding3 = '$_images/onboarding_3.jpg';
  static const String mapPlaceholder = '$_images/map_placeholder.png';
  static const String drawerBottomBackground =
      '$_images/drawerBottomBackground.png';

  /// The full-bleed backdrop behind every auth screen. A real vector, unlike
  /// `logoVector` — no `<pattern>` fill, so flutter_svg draws it.
  static const String authBackground = '$_images/auth_background.svg';

  /// Every path above. Dart has no runtime reflection here, so this list is
  /// what the test iterates — and the test also re-reads this source file to
  /// check the list did not fall behind the constants.
  static const List<String> all = <String>[
    drawerBottomBackground,
    mapArrow,
    mapArrowLeft,
    trackingMenu,
    mapLayers,
    mapNotification,
    mapZoomIn,
    mapZoomOut,
    playIcon,
    playOutlineIcon,
    pauseIcon,
    gps,
    message,
    videoCameraRecord,
    email,
    phoneCalling,
    successMark,
    splashBackground,
    splashParticles,
    logoMark,
    logoVector,
    onboarding1,
    onboarding2,
    onboarding3,
    mapPlaceholder,
    authBackground,
  ];
}
