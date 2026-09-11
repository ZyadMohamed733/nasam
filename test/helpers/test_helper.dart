import 'package:mocktail/mocktail.dart';
import 'package:nasam/core/errors/failures.dart';
import 'package:nasam/features/_template/domain/entities/template_entity.dart';

class TestHelper {
  static void registerFallbackValues() {
    // Register custom Mocktail fallback values if needed for parameters
    registerFallbackValue(
      const TemplateEntity(id: '1', title: 'Test', description: 'Desc'),
    );
    registerFallbackValue(const UnknownFailure(message: 'Error'));
  }
}
