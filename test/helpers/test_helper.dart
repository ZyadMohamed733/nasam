import 'package:mocktail/mocktail.dart';
import 'package:nasam/core/errors/failures.dart';

import 'fixtures.dart';

class TestHelper {
  static void registerFallbackValues() {
    // Register custom Mocktail fallback values if needed for parameters
    registerFallbackValue(Fixtures.templateEntity);
    registerFallbackValue(Fixtures.templateModel);
    registerFallbackValue(const UnknownFailure(message: 'Error'));
  }
}
