import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/app/app_config.dart';
import 'package:nasam/app/app_settings_controller.dart';
import 'package:nasam/core/auth/auth_session_notifier.dart';
import 'package:nasam/core/auth/token_refresher.dart';
import 'package:nasam/core/di/injection_container.dart';
import 'package:nasam/core/di/network_dependencies.dart';
import 'package:nasam/core/errors/error_reporter.dart';
import 'package:nasam/core/network/interceptors/auth_interceptor.dart';
import 'package:nasam/core/network/interceptors/error_interceptor.dart';
import 'package:nasam/core/network/interceptors/language_interceptor.dart';
import 'package:nasam/core/network/interceptors/logging_interceptor.dart';
import 'package:nasam/core/router/app_router.dart';
import 'package:nasam/core/router/route_guard.dart';
import 'package:nasam/core/services/auth_service.dart';
import 'package:nasam/core/services/secure_storage_service.dart';
import 'package:nasam/core/services/storage_service.dart';
import 'package:nasam/core/services/websocket_service.dart';
import 'package:nasam/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:nasam/features/auth/domain/repositories/auth_repository.dart';
import 'package:nasam/features/auth/domain/usecases/forget_password_usecase.dart';
import 'package:nasam/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:nasam/features/auth/domain/usecases/login_usecase.dart';
import 'package:nasam/features/auth/domain/usecases/logout_usecase.dart';
import 'package:nasam/features/auth/domain/usecases/resend_otp_usecase.dart';
import 'package:nasam/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:nasam/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:nasam/features/auth/domain/usecases/verify_reset_otp_usecase.dart';
import 'package:nasam/features/auth/presentation/cubit/current_user_cubit.dart';
import 'package:nasam/features/auth/presentation/cubit/login_cubit.dart';
import 'package:nasam/features/auth/presentation/cubit/logout_cubit.dart';
import 'package:nasam/features/auth/presentation/cubit/new_password_cubit.dart';
import 'package:nasam/features/auth/presentation/cubit/otp_cubit.dart';
import 'package:nasam/features/auth/presentation/cubit/password_recovery_cubit.dart';
import 'package:nasam/features/history_alert/data/datasources/history_alert_datasource.dart';
import 'package:nasam/features/history_alert/domain/repositories/history_alert_repository.dart';
import 'package:nasam/features/history_alert/domain/usecase/get_history_details_usecase.dart';
import 'package:nasam/features/history_alert/domain/usecase/get_history_usecase.dart';
import 'package:nasam/features/history_alert/presentation/cubit/histroy_alert_cubit.dart';
import 'package:nasam/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:nasam/features/play_back/data/datasources/playback_datasource.dart';
import 'package:nasam/features/play_back/domain/repositories/playback_repository.dart';
import 'package:nasam/features/play_back/domain/usecases/get_playback_route_usecase.dart';
import 'package:nasam/features/play_back/domain/usecases/get_playback_segments_usecase.dart';
import 'package:nasam/features/play_back/presentation/cubit/playback_cubit.dart';
import 'package:nasam/features/play_back/presentation/cubit/playback_map_cubit.dart';
import 'package:nasam/features/poi/data/datasources/poi_datasource.dart';
import 'package:nasam/features/poi/domain/repositories/poi_files.dart';
import 'package:nasam/features/poi/domain/repositories/poi_repository.dart';
import 'package:nasam/features/poi/domain/usecases/get_points_of_interest_usecase.dart';
import 'package:nasam/features/poi/domain/usecases/poi_operations.dart';
import 'package:nasam/features/poi/presentation/cubit/poi_cubit.dart';
import 'package:nasam/features/poi/presentation/cubit/poi_editor_cubit.dart';
import 'package:nasam/features/poi/presentation/cubit/poi_import_cubit.dart';
import 'package:nasam/features/tracking/data/datasources/tracking_datasource.dart';
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  tearDown(() async {
    await getIt.reset();
  });

  test('every dependency registration resolves', () async {
    final config = AppConfig(
      flavor: Flavor.dev,
      appName: 'Nasam',
      baseUrl: 'https://api-dev.nasam.app/v1',
      wsUrl: 'wss://ws-dev.nasam.app',
      tenant: 'tenant-dev',
    );
    await configureDependencies(config);

    final resolved = <Object>[
      getIt<AppConfig>(),
      getIt<SharedPreferences>(),
      getIt<FlutterSecureStorage>(),
      getIt<SecureStorageService>(),
      getIt<StorageService>(),
      getIt<ErrorInterceptor>(),
      getIt<LoggingInterceptor>(),
      getIt<LanguageInterceptor>(),
      getIt<AuthInterceptor>(),
      getIt<Dio>(instanceName: authlessDioName),
      getIt<Dio>(),
      getIt<ErrorReporter>(),
      getIt<AppSettingsController>(),
      getIt<AuthSessionNotifier>(),
      getIt<TokenRefresher>(),
      getIt<AuthService>(),
      getIt<WebSocketService>(),
      getIt<RouteGuard>(),
      getIt<AppRouter>(),
      getIt<AuthRemoteDataSource>(),
      getIt<AuthRepository>(),
      getIt<ForgetPasswordUseCase>(),
      getIt<GetCurrentUserUseCase>(),
      getIt<LoginUseCase>(),
      getIt<LogoutUseCase>(),
      getIt<ResendOtpUseCase>(),
      getIt<ResetPasswordUseCase>(),
      getIt<VerifyOtpUseCase>(),
      getIt<VerifyResetOtpUseCase>(),
      getIt<NewPasswordCubit>(),
      getIt<OtpCubit>(),
      getIt<LoginCubit>(),
      getIt<CurrentUserCubit>(),
      getIt<PasswordRecoveryCubit>(),
      getIt<LogoutCubit>(),
      getIt<HistoryAlertDataSource>(),
      getIt<HistoryAlertRepository>(),
      getIt<GetHistoryDetailsUseCase>(),
      getIt<GetHistoryUseCase>(),
      getIt<HistoryAlertCubit>(),
      getIt<OnboardingCubit>(),
      getIt<PlaybackDataSource>(),
      getIt<PlaybackRepository>(),
      getIt<GetPlaybackRouteUseCase>(),
      getIt<GetPlaybackSegmentsUseCase>(),
      getIt<PlaybackCubit>(),
      getIt<PlaybackMapCubit>(),
      getIt<PoiDataSource>(),
      getIt<PoiFiles>(),
      getIt<PoiRepository>(),
      getIt<GetPointsOfInterestUseCase>(),
      getIt<GetPointOfInterestUseCase>(),
      getIt<SavePointOfInterestUseCase>(),
      getIt<DeletePointOfInterestUseCase>(),
      getIt<ImportPointsOfInterestUseCase>(),
      getIt<WatchPoiChangesUseCase>(),
      getIt<PoiImportCubit>(),
      getIt<PoiEditorCubit>(),
      getIt<PoiCubit>(),
      getIt<TrackingDataSource>(),
      getIt<TrackingRepository>(),
      getIt<GetAssetDetailsUseCase>(),
      getIt<GetAssetNotificationsUseCase>(),
      getIt<GetTrackedAssetUseCase>(),
      getIt<GetTrackedAssetsUseCase>(),
      getIt<GetTrackingVehiclesUseCase>(),
      getIt<TrackingCubit>(),
      getIt<TrackedAssetCubit>(),
      getIt<AssetDetailsCubit>(),
    ];

    expect(resolved, isNotEmpty);
  });
}
