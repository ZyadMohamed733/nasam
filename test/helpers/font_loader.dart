import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Registers every bundled font with the test engine.
///
/// `flutter test` does not load the fonts an app declares: text is drawn with
/// the built-in `FlutterTest` face, which renders Latin as filled rectangles
/// and anything else — Arabic included — as tofu, and icons as empty boxes.
/// Goldens taken without this prove nothing about the typeface or the icons,
/// only about layout and colour.
///
/// Reads `FontManifest.json`, so it covers both the app's own families and
/// `MaterialIcons`, and keeps covering whatever is added to pubspec later
/// without this file needing to change.
///
/// Call from `setUpAll` in any golden test.
Future<void> loadAppFonts() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  final manifest =
      json.decode(await rootBundle.loadString('FontManifest.json'))
          as List<dynamic>;

  if (manifest.isEmpty) {
    throw StateError(
      'FontManifest.json is empty, so the goldens would silently fall back to '
      'the test face. Has the asset bundle been built?',
    );
  }

  for (final entry in manifest.cast<Map<String, dynamic>>()) {
    final family = entry['family'] as String;
    final loader = FontLoader(family);
    for (final font
        in (entry['fonts'] as List<dynamic>).cast<Map<String, dynamic>>()) {
      loader.addFont(rootBundle.load(font['asset'] as String));
    }
    await loader.load();
  }
}
