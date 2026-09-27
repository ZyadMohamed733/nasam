import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/app/app_config.dart';
import 'package:nasam/app/app_settings_controller.dart';
import 'package:nasam/core/auth/auth_session_notifier.dart';
import 'package:nasam/core/auth/token_refresher.dart';
import 'package:nasam/core/constants/app_strings.dart';
import 'package:nasam/core/di/injection_container.dart';
import 'package:nasam/core/network/dio_client.dart';
import 'package:nasam/core/network/interceptors/auth_interceptor.dart';
import 'package:nasam/core/router/app_router.dart';
import 'package:nasam/core/services/auth_service.dart';
import 'package:nasam/core/services/storage_service.dart';
import 'package:nasam/core/services/websocket_service.dart';
import 'package:nasam/features/auth/domain/repositories/auth_repository.dart';
import 'package:nasam/features/auth/domain/usecases/logout_usecase.dart';
import 'package:nasam/features/auth/presentation/cubit/forgot_password_cubit.dart';
import 'package:nasam/features/auth/presentation/cubit/login_cubit.dart';
import 'package:nasam/features/auth/presentation/cubit/logout_cubit.dart';
import 'package:nasam/features/auth/presentation/cubit/new_password_cubit.dart';
import 'package:nasam/features/auth/presentation/cubit/otp_cubit.dart';
import 'package:nasam/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:nasam/features/play_back/domain/repositories/playback_repository.dart';
import 'package:nasam/features/play_back/domain/usecases/get_playback_segments_usecase.dart';
import 'package:nasam/features/play_back/presentation/cubit/playback_cubit.dart';
import 'package:nasam/features/tracking/domain/repositories/tracking_repository.dart';
import 'package:nasam/features/tracking/domain/usecases/get_asset_details_usecase.dart';
import 'package:nasam/features/tracking/domain/usecases/get_asset_notifications_usecase.dart';
import 'package:nasam/features/tracking/domain/usecases/get_tracked_asset_usecase.dart';
import 'package:nasam/features/tracking/domain/usecases/get_tracked_assets_usecase.dart';
import 'package:nasam/features/tracking/domain/usecases/get_tracking_vehicles_usecase.dart';
import 'package:nasam/features/tracking/presentation/cubit/asset_details_cubit.dart';
import 'package:nasam/features/tracking/presentation/cubit/tracked_asset_cubit.dart';
import 'package:nasam/features/tracking/presentation/cubit/tracking_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The container has to be resolvable in every flavor, not just the one the
/// developer happens to run.
///
/// An `@Environment`-scoped binding whose dependents are not scoped the same
/// way resolves fine in dev and throws in staging and prod — at the moment a
/// screen asks for it, which is the worst place to find out. These tests are
/// the cheapest way to find out instead.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  AppConfig configFor(Flavor flavor) => AppConfig(
    flavor: flavor,
    appName: 'Nasam',
    baseUrl: 'https://api-${flavor.name}.nasam.app/v1',
    wsUrl: 'wss://ws-${flavor.name}.nasam.app',
    tenant: 'tenant-${flavor.name}',
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  tearDown(() async {
    await getIt.reset();
  });

  for (final flavor in Flavor.values) {
    group('${flavor.name} flavor', () {
      Future<void> configure() => configureDependencies(configFor(flavor));

      test('resolves every type the UI reaches for', () async {
        await configure();

        // Anything a widget or a route calls getIt<T>() for. If one of these
        // throws, that screen crashes on open in this flavor.
        expect(getIt<AppConfig>(), isA<AppConfig>());
        expect(getIt<AppRouter>(), isA<AppRouter>());
        expect(getIt<AppSettingsController>(), isA<AppSettingsController>());
        expect(getIt<StorageService>(), isA<StorageService>());
        expect(getIt<WebSocketService>(), isA<WebSocketService>());

        expect(getIt<AuthRepository>(), isA<AuthRepository>());
        expect(getIt<LogoutUseCase>(), isA<LogoutUseCase>());
        expect(getIt<LoginCubit>(), isA<LoginCubit>());
        expect(getIt<LogoutCubit>(), isA<LogoutCubit>());
        expect(getIt<AuthSessionNotifier>(), isA<AuthSessionNotifier>());
        expect(getIt<TokenRefresher>(), isA<TokenRefresher>());
        expect(getIt<AuthInterceptor>(), isA<AuthInterceptor>());
        expect(getIt<OtpCubit>(), isA<OtpCubit>());
        expect(getIt<ForgotPasswordCubit>(), isA<ForgotPasswordCubit>());
        expect(getIt<NewPasswordCubit>(), isA<NewPasswordCubit>());
        expect(getIt<OnboardingCubit>(), isA<OnboardingCubit>());

        expect(getIt<TrackingRepository>(), isA<TrackingRepository>());
        expect(getIt<PlaybackRepository>(), isA<PlaybackRepository>());
        expect(
          getIt<GetTrackedAssetsUseCase>(),
          isA<GetTrackedAssetsUseCase>(),
        );
        expect(
          getIt<GetTrackingVehiclesUseCase>(),
          isA<GetTrackingVehiclesUseCase>(),
        );
        expect(getIt<GetTrackedAssetUseCase>(), isA<GetTrackedAssetUseCase>());
        expect(getIt<GetAssetDetailsUseCase>(), isA<GetAssetDetailsUseCase>());
        expect(
          getIt<GetAssetNotificationsUseCase>(),
          isA<GetAssetNotificationsUseCase>(),
        );
        expect(
          getIt<GetPlaybackSegmentsUseCase>(),
          isA<GetPlaybackSegmentsUseCase>(),
        );

        // What the router resolves for the tracking and playback screens.
        expect(getIt<TrackingCubit>(), isA<TrackingCubit>());
        expect(getIt<TrackedAssetCubit>(), isA<TrackedAssetCubit>());
        expect(getIt<AssetDetailsCubit>(), isA<AssetDetailsCubit>());
        expect(getIt<PlaybackCubit>(), isA<PlaybackCubit>());
      });

      // One refresh client for the life of the app, carrying this flavor's
      // headers -- not a new Dio per refresh.
      test('the refresh client is built once, from AppConfig', () async {
        await configure();

        final bare = getIt<Dio>(instanceName: bareDioName);
        expect(getIt<Dio>(instanceName: bareDioName), same(bare));
        expect(bare, isNot(same(getIt<Dio>())));
        expect(bare.options.headers['X-Client'], 'mobile');
        expect(bare.options.headers['x-tenant'], 'tenant-${flavor.name}');
        expect(
          getIt<Dio>().options.headers['x-tenant'],
          'tenant-${flavor.name}',
        );
      });

      // No tracking API exists yet, so every flavor is bound to the fixture.
      // What matters is that the screens get data rather than a container
      // error; when the real source lands this becomes a check that each
      // flavor reaches the right one.
      test('tracking data is served in this flavor', () async {
        await configure();

        final result = await getIt<TrackingRepository>().getTrackedAssets();

        expect(result.isRight(), isTrue, reason: result.toString());
        expect(result.getOrElse(() => const []), isNotEmpty);
      });
    });
  }

  // iOS keeps the keychain across an uninstall. The container is where the
  // wipe has to happen: before it returns, nothing can have read a token.
  group('reinstall', () {
    const leftover = {
      AppStrings.keyAccessToken: 'previous-owner',
      AppStrings.keyRefreshToken: 'previous-refresh',
      AppStrings.keyUserData: '{}',
    };

    test(
      'a first launch starts signed out, whatever the keychain held',
      () async {
        FlutterSecureStorage.setMockInitialValues(Map.of(leftover));
        await configureDependencies(configFor(Flavor.prod));

        expect(await getIt<AuthService>().isAuthenticated, isFalse);
        expect(getIt<AuthSessionNotifier>().value, AuthSessionStatus.signedOut);
        const keychain = FlutterSecureStorage();
        for (final key in leftover.keys) {
          expect(await keychain.read(key: key), isNull, reason: key);
        }
      },
    );

    test('a later launch keeps the session', () async {
      SharedPreferences.setMockInitialValues({
        AppStrings.keyAuthStorageInitialised: true,
      });
      FlutterSecureStorage.setMockInitialValues(Map.of(leftover));
      await configureDependencies(configFor(Flavor.prod));

      expect(await getIt<AuthService>().isAuthenticated, isTrue);
      expect(getIt<AuthSessionNotifier>().value, AuthSessionStatus.signedIn);
    });
  });
}
