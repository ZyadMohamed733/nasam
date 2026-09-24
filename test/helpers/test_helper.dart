import 'package:mocktail/mocktail.dart';
import 'package:nasam/core/errors/failures.dart';

class TestHelper {
  static void registerFallbackValues() {
    // Register custom Mocktail fallback values if needed for parameters.
    // The two template fixtures that used to be here went with that slice.
    registerFallbackValue(const UnknownFailure(message: 'Error'));
  }
}
