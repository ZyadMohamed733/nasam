import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nasam/core/router/app_routes.dart';
import 'package:nasam/core/router/route_guard.dart';

import '../../helpers/mock_helper.dart';

class _FakeGoRouterState extends Fake implements GoRouterState {
  _FakeGoRouterState(this._location);
  final String _location;

  @override
  String get matchedLocation => _location;
}

class _FakeBuildContext extends Fake implements BuildContext {}

void main() {
  late RouteGuard guard;
  late MockAuthService authService;

  setUp(() {
    authService = MockAuthService();
    guard = RouteGuard(authService);
  });

  Future<String?> redirectFor(String location) =>
      guard.handleRedirect(_FakeBuildContext(), _FakeGoRouterState(location));

  void givenAuthenticated({required bool value}) {
    when(() => authService.isAuthenticated).thenAnswer((_) async => value);
  }

  group('splash', () {
    // Splash must resolve before any auth check, or the app cannot show a
    // loading state while the token is read.
    test('passes through without consulting auth', () async {
      expect(await redirectFor(AppRoutes.splash), isNull);
      verifyNever(() => authService.isAuthenticated);
    });
  });

  group('unauthenticated', () {
    setUp(() => givenAuthenticated(value: false));

    test('is redirected to login from a protected route', () async {
      expect(await redirectFor(AppRoutes.home), AppRoutes.login);
    });

    test('is left alone on login', () async {
      expect(await redirectFor(AppRoutes.login), isNull);
    });
  });

  group('authenticated', () {
    setUp(() => givenAuthenticated(value: true));

    test('is left alone on a protected route', () async {
      expect(await redirectFor(AppRoutes.home), isNull);
    });

    // Otherwise a signed-in user can sit on the login screen.
    test('is redirected away from login to home', () async {
      expect(await redirectFor(AppRoutes.login), AppRoutes.home);
    });
  });
}
