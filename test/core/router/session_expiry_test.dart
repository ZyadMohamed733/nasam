import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nasam/app/app_config.dart';
import 'package:nasam/core/auth/auth_session_notifier.dart';
import 'package:nasam/core/auth/token_refresher.dart';
import 'package:nasam/core/constants/app_strings.dart';
import 'package:nasam/core/di/injection_container.dart';
import 'package:nasam/core/network/dio_client.dart';
import 'package:nasam/core/router/app_routes.dart';
import 'package:nasam/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:nasam/features/auth/data/models/account_model.dart';
import 'package:nasam/features/auth/data/models/auth_session_model.dart';
import 'package:nasam/features/auth/data/models/currency_model.dart';
import 'package:nasam/features/auth/data/models/user_model.dart';
import 'package:nasam/features/auth/domain/usecases/logout_usecase.dart';
import 'package:nasam/features/auth/presentation/pages/login_page.dart';
import 'package:nasam/features/tracking/data/datasources/tracking_datasource.dart';
import 'package:nasam/features/tracking/data/datasources/tracking_fixture_datasource.dart';
import 'package:nasam/features/tracking/presentation/pages/tracking_asset_details_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/app_harness.dart';
import '../../helpers/fake_map_platform.dart';
import '../../helpers/fixture_bundle.dart';
import '../../helpers/recording_adapter.dart';

/// A session ending on the server, end to end: a real request 401s, the real
/// interceptor and refresher try the refresh, the refresh is rejected, and
/// the router — told by the session notifier — takes the user to login and
/// back to the same screen afterwards.
///
/// Real: container, router, guard, AuthService, SecureStorageService (over
/// the plugin's in-memory keychain), AuthRepository, LoginCubit. Faked: the
/// HTTP transport, the remote auth calls, the map plugin and asset IO.

class _MockRemote extends Mock implements AuthRemoteDataSource {}

const _assetId = 'AST-0017';

UserModel _user() => UserModel(
  id: 'user-1',
  username: 'aya',
  email: 'aya@nasam.sa',
  nameEn: 'Aya',
  nameAr: null,
  account: AccountModel(
    id: 'account-1',
    type: 'COMPANY',
    nameEn: 'Nasam',
    nameAr: 'نسم',
    email: 'account@nasam.sa',
    phoneNumber1: '+966500000000',
    phoneNumber2: null,
    fax: null,
    currency: const CurrencyModel(
      id: 'currency-1',
      code: 'SAR',
      nameEn: 'Saudi Riyal',
      nameAr: 'ريال سعودي',
      symbol: '﷼',
    ),
  ),
  type: 'ADMIN',
  permissions: const [],
);

void main() {
  late RecordingAdapter api;
  late _MockRemote remote;

  setUp(() async {
    await getIt.reset();
    // A returning user with a live session, not a fresh install.
    SharedPreferences.setMockInitialValues({
      AppStrings.keyAuthStorageInitialised: true,
    });
    FlutterSecureStorage.setMockInitialValues({
      AppStrings.keyAccessToken: 'stale-access',
      AppStrings.keyRefreshToken: 'revoked-refresh',
      AppStrings.keyUserData: '{}',
    });
    await configureDependencies(
      const AppConfig(
        flavor: Flavor.dev,
        appName: 'Nasam',
        baseUrl: 'https://api.test/v1',
        wsUrl: 'wss://ws.test',
        tenant: 'test-tenant',
      ),
    );
    getIt.allowReassignment = true;

    remote = _MockRemote();
    getIt
      ..registerSingleton<AuthRemoteDataSource>(remote)
      ..registerSingleton<TrackingDataSource>(
        TrackingFixtureDataSource(
          bundle: DiskAssetBundle(),
          latency: Duration.zero,
        ),
      );
    GoogleMapsFlutterPlatform.instance = FakeMapPlatform();

    // The server has revoked the session: the API and the refresh endpoint
    // both say 401.
    api = RecordingAdapter((_) => (401, {'message': 'Unauthorized'}));
    getIt<Dio>().httpClientAdapter = api;
    getIt<Dio>(instanceName: bareDioName).httpClientAdapter = api;
  });

  tearDown(() async {
    getIt.allowReassignment = false;
    await getIt.reset();
  });

  testWidgets(
    'an expired session goes to login, says so once, and returns after sign-in',
    (tester) async {
      final router = await openApp(tester, AppRoutes.assetDetails(_assetId));
      expect(find.byType(TrackingAssetDetailsPage), findsOneWidget);
      final session = getIt<AuthSessionNotifier>();
      expect(session.value, AuthSessionStatus.signedIn);

      // Any authenticated call made from this screen.
      await tester.runAsync(() async {
        await expectLater(
          getIt<Dio>().get<dynamic>('/vehicles'),
          throwsA(isA<DioException>()),
        );
      });
      await tester.pumpAndSettle();

      // The refresh was tried, once, and rejected.
      expect(
        api.requests.where((r) => r.path == TokenRefresher.refreshPath),
        hasLength(1),
      );
      expect(
        await const FlutterSecureStorage().read(key: AppStrings.keyAccessToken),
        isNull,
      );

      // On login, holding the screen the user was on.
      final atLogin = Uri.parse(currentLocation(router));
      expect(atLogin.path, AppRoutes.login);
      expect(
        atLogin.queryParameters[AppRoutes.returnToParam],
        AppRoutes.assetDetails(_assetId),
      );
      expect(find.byType(LoginPage), findsOneWidget);
      expect(
        find.text('Your session has expired. Please sign in again.'),
        findsOneWidget,
      );
      // Shown, and marked shown: it will not appear on the next visit.
      expect(session.value, AuthSessionStatus.signedOut);
      expect(session.endedByUser, isFalse);

      when(
        () => remote.login(
          username: any(named: 'username'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async => AuthSessionModel(
          accessToken: 'new-access',
          refreshToken: 'new-refresh',
          user: _user(),
        ),
      );
      final fields = find.byType(EditableText);
      await tester.enterText(fields.at(0), 'aya');
      await tester.enterText(fields.at(1), 'correct horse');
      await tester.tap(find.text('Sign in').last);
      await tester.pumpAndSettle();

      expect(currentLocation(router), AppRoutes.assetDetails(_assetId));
      expect(find.byType(TrackingAssetDetailsPage), findsOneWidget);
      expect(session.value, AuthSessionStatus.signedIn);
    },
  );

  testWidgets(
    'signing out goes to a plain login, even when the server call fails',
    (tester) async {
      when(() => remote.logout(any())).thenThrow(StateError('unexpected'));
      final router = await openApp(tester, AppRoutes.assetDetails(_assetId));

      // What the drawer's LogoutCubit calls.
      await tester.runAsync(() => getIt<LogoutUseCase>()());
      await tester.pumpAndSettle();

      expect(currentLocation(router), AppRoutes.login, reason: 'no returnTo');
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.textContaining('session has expired'), findsNothing);
      expect(
        await const FlutterSecureStorage().read(
          key: AppStrings.keyRefreshToken,
        ),
        isNull,
      );
    },
  );
}
