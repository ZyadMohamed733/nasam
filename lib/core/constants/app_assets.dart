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

  // Images.
  static const String passwordResetSuccess =
      '$_images/password_reset_success.png';
  static const String splashBackground = '$_images/splash_background.png';
  static const String splashParticles = '$_images/signal_particles_splash.gif';
  static const String logoMark = '$_images/logo_mark.png';
  static const String logoVector = '$_images/Vector.svg';
  static const String onboarding1 = '$_images/onboarding_1.jpg';
  static const String onboarding2 = '$_images/onboarding_2.png';
  static const String onboarding3 = '$_images/onboarding_3.jpg';
  static const String mapPlaceholder = '$_images/map_placeholder.png';

  /// The full-bleed backdrop behind every auth screen. A real vector, unlike
  /// `logoVector` — no `<pattern>` fill, so flutter_svg draws it.
  static const String authBackground = '$_images/auth_background.svg';

  /// Every path above. Dart has no runtime reflection here, so this list is
  /// what the test iterates — and the test also re-reads this source file to
  /// check the list did not fall behind the constants.
  static const List<String> all = <String>[
    passwordResetSuccess,
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
