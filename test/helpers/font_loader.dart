import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Registers the app's bundled fonts with the test engine.
///
/// `flutter test` does not load the fonts declared in pubspec.yaml: every
/// glyph is drawn with the built-in `FlutterTest` face, which renders Latin as
/// filled rectangles and anything else — Arabic included — as tofu. Goldens
/// taken without this therefore prove nothing about the typeface, only about
/// layout and colour.
///
/// Call from `setUpAll` in any golden test so the file under review shows the
/// face a device would actually draw.
Future<void> loadAppFonts() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Read from disk rather than through rootBundle: tests run from the package
  // root, and this stays true whether or not a test asset bundle was built.
  final loader = FontLoader('Almarai');
  for (final path in const [
    'assets/fonts/Almarai-Regular.ttf',
    'assets/fonts/Almarai-Bold.ttf',
  ]) {
    final file = File(path);
    if (!file.existsSync()) {
      throw StateError(
        'Missing font $path. pubspec.yaml declares the Almarai family, so a '
        'missing file here means the goldens would silently fall back.',
      );
    }
    final bytes = file.readAsBytesSync();
    loader.addFont(
      Future<ByteData>.value(ByteData.sublistView(Uint8List.fromList(bytes))),
    );
  }
  await loader.load();
}
