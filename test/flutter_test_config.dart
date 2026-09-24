import 'dart:async';

import 'helpers/font_loader.dart';

/// Runs before every test file: registers the app's real fonts (Almarai and
/// MaterialIcons, read from FontManifest.json) so goldens show the actual
/// typeface and icons instead of the test face's grey boxes, and every
/// layout test measures the text the app really draws.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await loadAppFonts();
  await testMain();
}
