import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/core/router/app_routes.dart';
import 'package:nasam/core/router/return_path.dart';

void main() {
  group('ReturnPath.sanitize', () {
    test('accepts in-app paths, query included', () {
      expect(ReturnPath.sanitize('/assets/AST-1'), '/assets/AST-1');
      expect(
        ReturnPath.sanitize('/assets/AST-1/playback?from=2026-03-01'),
        '/assets/AST-1/playback?from=2026-03-01',
      );
      expect(ReturnPath.sanitize('/'), '/');
    });

    // Every one of these would, somewhere, send the user off the app.
    for (final attack in [
      'https://evil.example/phish',
      'http://evil.example',
      '//evil.example/path',
      r'/\evil.example',
      r'\\evil.example',
      'javascript:alert(1)',
      'evil.example/assets/1',
      'assets/AST-1',
      '/assets/AST-1\u0000',
      '/assets/AST-1\n',
    ]) {
      test('rejects ${Uri.encodeComponent(attack)}', () {
        expect(ReturnPath.sanitize(attack), isNull);
      });
    }

    test('rejects the sign-in screens, which would loop', () {
      for (final path in [
        AppRoutes.login,
        '${AppRoutes.login}?returnTo=/assets/1',
        AppRoutes.otpVerification,
        AppRoutes.forgotPassword,
        AppRoutes.splash,
        AppRoutes.onboarding,
      ]) {
        expect(ReturnPath.sanitize(path), isNull, reason: path);
      }
    });

    test('rejects nothing, blank and absurdly long input', () {
      expect(ReturnPath.sanitize(null), isNull);
      expect(ReturnPath.sanitize('   '), isNull);
      expect(ReturnPath.sanitize('/${'a' * 3000}'), isNull);
    });
  });

  group('AppRoutes builders', () {
    test('encode the id, so it cannot escape its segment', () {
      expect(AppRoutes.assetDetails('AST-1'), '/assets/AST-1');
      expect(AppRoutes.assetDetails('a/b c'), '/assets/a%2Fb%20c');
    });

    test('playback carries the range as ISO dates, or no query at all', () {
      expect(AppRoutes.assetPlayback('AST-1'), '/assets/AST-1/playback');
      expect(
        AppRoutes.assetPlayback(
          'AST-1',
          from: DateTime(2026, 3, 1, 14, 30),
          to: DateTime(2026, 3, 9),
        ),
        '/assets/AST-1/playback?from=2026-03-01&to=2026-03-09',
      );
    });

    test('the login return target round-trips through the query', () {
      final url = AppRoutes.loginReturningTo('/assets/AST-1/playback?to=x');
      expect(
        Uri.parse(url).queryParameters[AppRoutes.returnToParam],
        '/assets/AST-1/playback?to=x',
      );
      expect(Uri.parse(url).path, AppRoutes.login);
    });
  });
}
