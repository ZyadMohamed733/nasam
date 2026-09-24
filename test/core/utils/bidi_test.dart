import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/core/utils/bidi.dart';

void main() {
  test('each part is isolated, the separators are not', () {
    expect(
      joinIsolated(['AST-0017', '07 م 09 ث'], ' • '),
      '\u2068AST-0017\u2069 • \u206807 م 09 ث\u2069',
    );
  });
}
