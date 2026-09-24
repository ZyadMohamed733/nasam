import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nasam/core/auth/auth_session_notifier.dart';
import 'package:nasam/core/router/app_routes.dart';
import 'package:nasam/core/router/route_guard.dart';

import '../../helpers/mock_helper.dart';

class _FakeGoRouterState extends Fake implements GoRouterState {
  _FakeGoRouterState(String location) : uri = Uri.parse(location);

  @override
  final Uri uri;

  /// As go_router reports it: the path, without the query.
  @override
  String get matchedLocation => uri.path;
}

class _FakeBuildContext extends Fake implements BuildContext {}

void main() {
  late RouteGuard guard;
  late MockAuthService authService;
  late AuthSessionNotifier session;

  setUp(() {
    authService = MockAuthService();
    final storage = MockSecureStorageService();
    when(() => storage.hasAccessToken).thenReturn(true);
    session = AuthSessionNotifier(storage);
    guard = RouteGuard(authService, session);
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

    test('can reach password-reset success without signing in', () async {
      expect(await redirectFor(AppRoutes.passwordResetSuccess), isNull);
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

  group('deep links and the return target', () {
    test('an unauthenticated deep link carries its target to login', () async {
      givenAuthenticated(value: false);
      final redirect = await redirectFor(
        '/assets/AST-1/playback?from=2026-09-01',
      );

      final uri = Uri.parse(redirect!);
      expect(uri.path, AppRoutes.login);
      expect(
        uri.queryParameters[AppRoutes.returnToParam],
        '/assets/AST-1/playback?from=2026-09-01',
      );
    });

    test(
      'a signed-in user following a login link goes to its target',
      () async {
        givenAuthenticated(value: true);
        expect(
          await redirectFor(AppRoutes.loginReturningTo('/assets/AST-1')),
          '/assets/AST-1',
        );
      },
    );

    test(
      'a playback target keeps its dates through the login round trip',
      () async {
        const target = '/assets/AST-1/playback?from=2026-09-01&to=2026-09-10';

        givenAuthenticated(value: false);
        final toLogin = await redirectFor(target);
        final loginUri = Uri.parse(toLogin!);
        expect(
          loginUri.queryParameters.keys,
          [AppRoutes.returnToParam],
          reason: 'the dates travel inside returnTo, not beside it',
        );

        givenAuthenticated(value: true);
        final back = await redirectFor(toLogin);
        expect(back, target);
        final backUri = Uri.parse(back!);
        expect(backUri.queryParameters[AppRoutes.fromDateParam], '2026-09-01');
        expect(backUri.queryParameters[AppRoutes.toDateParam], '2026-09-10');
      },
    );

    test('an expired session keeps the screen it was on', () async {
      session.expire();
      givenAuthenticated(value: false);

      final redirect = await redirectFor('/assets/AST-1');

      expect(
        Uri.parse(redirect!).queryParameters[AppRoutes.returnToParam],
        '/assets/AST-1',
      );
    });

    // Whoever signs in next may not be the person who left.
    test('a deliberate sign-out goes to a plain login', () async {
      session.signOut();
      givenAuthenticated(value: false);

      expect(await redirectFor('/assets/AST-1'), AppRoutes.login);
    });

    // The target is untrusted query input; it must not become an open
    // redirect even for a user who is already signed in.
    test('a hostile target is dropped for home', () async {
      givenAuthenticated(value: true);
      expect(
        await redirectFor(
          AppRoutes.loginReturningTo('https://evil.example/phish'),
        ),
        AppRoutes.home,
      );
    });
  });
}
