import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nasam/app/app_config.dart';
import 'package:nasam/core/di/injection_container.dart';
import 'package:nasam/core/router/app_router.dart';
import 'package:nasam/core/router/app_routes.dart';
import 'package:nasam/core/services/auth_service.dart';
import 'package:nasam/features/auth/domain/entities/auth_session_entity.dart';
import 'package:nasam/features/auth/domain/entities/login_result.dart';
import 'package:nasam/features/auth/domain/usecases/login_usecase.dart';
import 'package:nasam/features/auth/presentation/pages/login_page.dart';
import 'package:nasam/features/home/presentation/pages/home_page.dart';
import 'package:nasam/features/play_back/data/datasources/playback_datasource.dart';
import 'package:nasam/features/play_back/data/datasources/playback_fixture_datasource.dart';
import 'package:nasam/features/play_back/presentation/pages/playback_page.dart';
import 'package:nasam/features/play_back/presentation/pages/playback_map_page.dart';
import 'package:nasam/features/play_back/presentation/utils/playback_range.dart';
import 'package:nasam/features/tracking/data/datasources/tracking_datasource.dart';
import 'package:nasam/features/tracking/data/datasources/tracking_fixture_datasource.dart';
import 'package:nasam/features/tracking/presentation/pages/tracking_asset_details_page.dart';
import 'package:nasam/features/tracking/presentation/widgets/tracking_asset_not_found.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/app_harness.dart';
import '../../helpers/fake_map_platform.dart';
import '../../helpers/fixture_bundle.dart';

/// The real [AppRouter] and guard, opened the way the OS opens a link: the
/// platform's initial route is set before the router exists, so go_router
/// starts there rather than at splash. Only the edges are faked — the
/// session, the login call, the map plugin and asset IO.

class _FakeAuthService implements AuthService {
  bool signedIn = false;

  @override
  Future<bool> get isAuthenticated async => signedIn;
  @override
  Future<String?> get accessToken async => signedIn ? 'token' : null;
  @override
  Future<String?> get currentUser async => null;
}

class _MockLogin extends Mock implements LoginUseCase {}

class _MockSession extends Mock implements AuthSessionEntity {}

/// An asset the fixture has.
const _knownId = 'AST-0017';

void main() {
  late _FakeAuthService auth;
  late _MockLogin login;

  setUp(() async {
    await getIt.reset();
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    await configureDependencies(
      const AppConfig(
        flavor: Flavor.dev,
        appName: 'Nasam',
        baseUrl: 'https://api-dev.nasam.app/v1',
        wsUrl: 'wss://ws-dev.nasam.app',
        tenant: 'test-tenant',
      ),
    );
    getIt.allowReassignment = true;

    auth = _FakeAuthService()..signedIn = true;
    login = _MockLogin();
    getIt
      ..registerSingleton<AuthService>(auth)
      ..registerSingleton<LoginUseCase>(login)
      ..registerSingleton<TrackingDataSource>(
        TrackingFixtureDataSource(
          bundle: DiskAssetBundle(),
          latency: Duration.zero,
        ),
      )
      ..registerSingleton<PlaybackDataSource>(
        PlaybackFixtureDataSource(
          bundle: DiskAssetBundle(),
          latency: Duration.zero,
        ),
      );
    GoogleMapsFlutterPlatform.instance = FakeMapPlatform();
  });

  tearDown(() async {
    getIt.allowReassignment = false;
    await getIt.reset();
  });

  Future<AppRouter> open(WidgetTester tester, String location) =>
      openApp(tester, location);

  String location(AppRouter router) => currentLocation(router);

  /// The system back gesture, as the OS delivers it.
  Future<void> back(WidgetTester tester) async {
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
  }

  testWidgets('a cold link to details opens it over home; back goes home', (
    tester,
  ) async {
    final router = await open(tester, AppRoutes.assetDetails(_knownId));

    expect(location(router), '/assets/$_knownId');
    expect(find.byType(TrackingAssetDetailsPage), findsOneWidget);
    expect(find.text(_knownId), findsWidgets, reason: 'resolved from the id');

    await back(tester);

    expect(location(router), AppRoutes.home);
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(TrackingAssetDetailsPage), findsNothing);
  });

  testWidgets('a cold link to playback backs out through details to home', (
    tester,
  ) async {
    final router = await open(tester, AppRoutes.assetPlayback(_knownId));

    expect(find.byType(PlaybackPage), findsOneWidget);
    expect(
      find.textContaining(_knownId),
      findsWidgets,
      reason: 'header from the id',
    );

    await back(tester);
    expect(location(router), '/assets/$_knownId');
    expect(find.byType(TrackingAssetDetailsPage), findsOneWidget);

    await back(tester);
    expect(location(router), AppRoutes.home);
    expect(find.byType(HomePage), findsOneWidget);
  });

  testWidgets('the start playback button opens the map playback child route', (
    tester,
  ) async {
    final router = await open(tester, AppRoutes.assetPlayback(_knownId));
    await tester.tap(find.text('Start playback'));
    await tester.pumpAndSettle();
    expect(location(router), startsWith(AppRoutes.assetPlaybackMap(_knownId)));
    expect(find.byType(PlaybackMapPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a valid range in the link reaches the page', (tester) async {
    final today = PlaybackRange.today();
    final from = today.from.subtract(const Duration(days: 3));
    await open(tester, AppRoutes.assetPlayback(_knownId, from: from));

    final page = tester.widget<PlaybackPage>(find.byType(PlaybackPage));
    expect(page.initialRange.from, from);
    expect(page.initialRange.to, today.to, reason: 'no to: through today');
  });

  testWidgets('an invalid range in the link falls back to today', (
    tester,
  ) async {
    await open(
      tester,
      '/assets/$_knownId/playback?from=not-a-date&to=2999-01-01',
    );

    final page = tester.widget<PlaybackPage>(find.byType(PlaybackPage));
    expect(page.initialRange, PlaybackRange.today());
    expect(tester.takeException(), isNull);
  });

  for (final link in [
    AppRoutes.assetDetails('NO-SUCH-ASSET'),
    AppRoutes.assetPlayback('NO-SUCH-ASSET'),
    '/assets/%20',
  ]) {
    testWidgets('unknown id $link shows not-found, with a way home', (
      tester,
    ) async {
      final router = await open(tester, link);

      expect(find.byType(TrackingAssetNotFound), findsOneWidget);
      expect(location(router), startsWith('/assets/'), reason: 'no redirect');
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Back to home'));
      await tester.pumpAndSettle();

      expect(location(router), AppRoutes.home);
      expect(find.byType(HomePage), findsOneWidget);
    });
  }

  testWidgets('signed out, a deep link goes through login and on to it', (
    tester,
  ) async {
    auth.signedIn = false;
    when(
      () => login(
        username: any(named: 'username'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async {
      auth.signedIn = true;
      return Right(LoginSucceeded(_MockSession()));
    });
    final day = PlaybackRange.today().from;
    final from = day.subtract(const Duration(days: 5));
    final to = day.subtract(const Duration(days: 2));
    final target = AppRoutes.assetPlayback(_knownId, from: from, to: to);

    final router = await open(tester, target);

    expect(find.byType(LoginPage), findsOneWidget);
    final atLogin = Uri.parse(location(router));
    expect(atLogin.path, AppRoutes.login);
    expect(atLogin.queryParameters[AppRoutes.returnToParam], target);

    final fields = find.byType(EditableText);
    await tester.enterText(fields.at(0), 'aya');
    await tester.enterText(fields.at(1), 'correct horse');
    await tester.tap(find.text('Sign in').last);
    await tester.pumpAndSettle();

    expect(location(router), target);
    final page = tester.widget<PlaybackPage>(find.byType(PlaybackPage));
    expect(page.initialRange.from, from, reason: 'dates survive the detour');
    expect(page.initialRange.to, to);
  });

  testWidgets('a hostile login target lands on home after sign-in', (
    tester,
  ) async {
    auth.signedIn = false;
    when(
      () => login(
        username: any(named: 'username'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async {
      auth.signedIn = true;
      return Right(LoginSucceeded(_MockSession()));
    });

    final router = await open(
      tester,
      AppRoutes.loginReturningTo('//evil.example/phish'),
    );
    expect(find.byType(LoginPage), findsOneWidget);

    final fields = find.byType(EditableText);
    await tester.enterText(fields.at(0), 'aya');
    await tester.enterText(fields.at(1), 'correct horse');
    await tester.tap(find.text('Sign in').last);
    await tester.pumpAndSettle();

    expect(location(router), AppRoutes.home);
  });
}
