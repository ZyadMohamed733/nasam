import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/app/app_config.dart';
import 'package:nasam/app/app_settings_controller.dart';
import 'package:nasam/core/di/injection_container.dart';
import 'package:nasam/core/router/app_router.dart';
import 'package:nasam/core/services/storage_service.dart';
import 'package:nasam/core/services/websocket_service.dart';
import 'package:nasam/features/auth/domain/repositories/auth_repository.dart';
import 'package:nasam/features/auth/domain/usecases/logout_usecase.dart';
import 'package:nasam/features/auth/presentation/cubit/forgot_password_cubit.dart';
import 'package:nasam/features/auth/presentation/cubit/login_cubit.dart';
import 'package:nasam/features/auth/presentation/cubit/new_password_cubit.dart';
import 'package:nasam/features/auth/presentation/cubit/otp_cubit.dart';
import 'package:nasam/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:nasam/features/tracking/domain/repositories/tracking_repository.dart';
import 'package:nasam/features/tracking/domain/usecases/get_asset_details_usecase.dart';
import 'package:nasam/features/tracking/domain/usecases/get_asset_notifications_usecase.dart';
import 'package:nasam/features/tracking/domain/usecases/get_playback_segments_usecase.dart';
import 'package:nasam/features/tracking/domain/usecases/get_tracked_asset_usecase.dart';
import 'package:nasam/features/tracking/domain/usecases/get_tracked_assets_usecase.dart';
import 'package:nasam/features/tracking/domain/usecases/get_tracking_vehicles_usecase.dart';
import 'package:nasam/features/tracking/presentation/cubit/asset_details_cubit.dart';
import 'package:nasam/features/tracking/presentation/cubit/asset_playback_cubit.dart';
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
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
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
        expect(getIt<OtpCubit>(), isA<OtpCubit>());
        expect(getIt<ForgotPasswordCubit>(), isA<ForgotPasswordCubit>());
        expect(getIt<NewPasswordCubit>(), isA<NewPasswordCubit>());
        expect(getIt<OnboardingCubit>(), isA<OnboardingCubit>());

        expect(getIt<TrackingRepository>(), isA<TrackingRepository>());
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

        // What the router resolves for the three tracking screens.
        expect(getIt<TrackingCubit>(), isA<TrackingCubit>());
        expect(getIt<TrackedAssetCubit>(), isA<TrackedAssetCubit>());
        expect(getIt<AssetDetailsCubit>(), isA<AssetDetailsCubit>());
        expect(getIt<AssetPlaybackCubit>(), isA<AssetPlaybackCubit>());
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
}
