// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../app/app_config.dart' as _i861;
import '../../app/app_settings_controller.dart' as _i461;
import '../../features/auth/data/datasources/remote/auth_remote_datasource.dart'
    as _i1022;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/domain/usecases/forget_password_usecase.dart'
    as _i948;
import '../../features/auth/domain/usecases/get_current_user_usecase.dart'
    as _i17;
import '../../features/auth/domain/usecases/login_usecase.dart' as _i188;
import '../../features/auth/domain/usecases/logout_usecase.dart' as _i48;
import '../../features/auth/domain/usecases/resend_otp_usecase.dart' as _i613;
import '../../features/auth/domain/usecases/reset_password_usecase.dart'
    as _i474;
import '../../features/auth/domain/usecases/verify_otp_usecase.dart' as _i503;
import '../../features/auth/domain/usecases/verify_reset_otp_usecase.dart'
    as _i752;
import '../../features/auth/presentation/cubit/current_user_cubit.dart' as _i18;
import '../../features/auth/presentation/cubit/login_cubit.dart' as _i69;
import '../../features/auth/presentation/cubit/logout_cubit.dart' as _i159;
import '../../features/auth/presentation/cubit/new_password_cubit.dart'
    as _i236;
import '../../features/auth/presentation/cubit/otp_cubit.dart' as _i1033;
import '../../features/auth/presentation/cubit/password_recovery_cubit.dart'
    as _i648;
import '../../features/onboarding/presentation/cubit/onboarding_cubit.dart'
    as _i807;
import '../../features/play_back/data/datasources/playback_datasource.dart'
    as _i550;
import '../../features/play_back/data/datasources/playback_fixture_datasource.dart'
    as _i1044;
import '../../features/play_back/data/repositories/playback_repository_impl.dart'
    as _i604;
import '../../features/play_back/domain/repositories/playback_repository.dart'
    as _i832;
import '../../features/play_back/domain/usecases/get_playback_segments_usecase.dart'
    as _i948;
import '../../features/play_back/presentation/cubit/playback_cubit.dart'
    as _i943;
import '../../features/poi/data/datasources/poi_datasource.dart' as _i535;
import '../../features/poi/data/datasources/poi_fixture_datasource.dart'
    as _i519;
import '../../features/poi/data/repositories/poi_repository_impl.dart' as _i486;
import '../../features/poi/data/services/poi_file_service.dart' as _i215;
import '../../features/poi/domain/repositories/poi_files.dart' as _i81;
import '../../features/poi/domain/repositories/poi_repository.dart' as _i828;
import '../../features/poi/domain/usecases/get_points_of_interest_usecase.dart'
    as _i116;
import '../../features/poi/domain/usecases/poi_operations.dart' as _i628;
import '../../features/poi/presentation/cubit/poi_cubit.dart' as _i98;
import '../../features/poi/presentation/cubit/poi_editor_cubit.dart' as _i61;
import '../../features/poi/presentation/cubit/poi_import_cubit.dart' as _i507;
import '../../features/tracking/data/datasources/tracking_datasource.dart'
    as _i765;
import '../../features/tracking/data/datasources/tracking_fixture_datasource.dart'
    as _i439;
import '../../features/tracking/data/repositories/tracking_repository_impl.dart'
    as _i279;
import '../../features/tracking/domain/repositories/tracking_repository.dart'
    as _i76;
import '../../features/tracking/domain/usecases/get_asset_details_usecase.dart'
    as _i439;
import '../../features/tracking/domain/usecases/get_asset_notifications_usecase.dart'
    as _i201;
import '../../features/tracking/domain/usecases/get_tracked_asset_usecase.dart'
    as _i127;
import '../../features/tracking/domain/usecases/get_tracked_assets_usecase.dart'
    as _i143;
import '../../features/tracking/domain/usecases/get_tracking_vehicles_usecase.dart'
    as _i886;
import '../../features/tracking/presentation/cubit/asset_details_cubit.dart'
    as _i784;
import '../../features/tracking/presentation/cubit/tracked_asset_cubit.dart'
    as _i1062;
import '../../features/tracking/presentation/cubit/tracking_cubit.dart'
    as _i546;
import '../auth/auth_session_notifier.dart' as _i745;
import '../auth/token_refresher.dart' as _i599;
import '../errors/error_reporter.dart' as _i720;
import '../network/interceptors/auth_interceptor.dart' as _i745;
import '../network/interceptors/error_interceptor.dart' as _i511;
import '../network/interceptors/language_interceptor.dart' as _i465;
import '../network/interceptors/logging_interceptor.dart' as _i344;
import '../router/app_router.dart' as _i81;
import '../router/route_guard.dart' as _i715;
import '../services/auth_service.dart' as _i745;
import '../services/secure_storage_service.dart' as _i535;
import '../services/storage_service.dart' as _i306;
import '../services/websocket_service.dart' as _i555;
import 'modules/network_module.dart' as _i851;
import 'modules/storage_module.dart' as _i148;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final storageModule = _$StorageModule();
    final networkModule = _$NetworkModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => storageModule.prefs,
      preResolve: true,
    );
    gh.factory<_i511.ErrorInterceptor>(() => _i511.ErrorInterceptor());
    gh.factory<_i344.LoggingInterceptor>(() => _i344.LoggingInterceptor());
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => storageModule.secureStorage,
    );
    gh.lazySingleton<_i720.ErrorReporter>(() => _i720.ErrorReporter());
    gh.lazySingleton<_i535.PoiDataSource>(() => _i519.PoiFixtureDataSource());
    await gh.singletonAsync<_i535.SecureStorageService>(
      () => storageModule.secureStorageService(
        gh<_i558.FlutterSecureStorage>(),
        gh<_i460.SharedPreferences>(),
      ),
      preResolve: true,
    );
    gh.lazySingleton<_i765.TrackingDataSource>(
      () => _i439.TrackingFixtureDataSource(),
    );
    gh.lazySingleton<_i81.PoiFiles>(() => _i215.PoiFileService());
    gh.lazySingleton<_i550.PlaybackDataSource>(
      () => _i1044.PlaybackFixtureDataSource(),
    );
    gh.lazySingleton<_i361.Dio>(
      () => networkModule.bareDio(
        gh<_i861.AppConfig>(),
        gh<_i344.LoggingInterceptor>(),
      ),
      instanceName: 'bareDio',
    );
    gh.lazySingleton<_i306.StorageService>(
      () => _i306.StorageService(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i555.WebSocketService>(
      () => _i555.WebSocketService(gh<_i861.AppConfig>()),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i745.AuthService>(
      () => _i745.AuthServiceImpl(gh<_i535.SecureStorageService>()),
    );
    gh.lazySingleton<_i745.AuthSessionNotifier>(
      () => _i745.AuthSessionNotifier(gh<_i535.SecureStorageService>()),
    );
    gh.lazySingleton<_i599.TokenRefresher>(
      () => _i599.TokenRefresher(
        gh<_i535.SecureStorageService>(),
        gh<_i745.AuthSessionNotifier>(),
        gh<_i361.Dio>(instanceName: 'bareDio'),
        gh<_i720.ErrorReporter>(),
      ),
    );
    gh.lazySingleton<_i832.PlaybackRepository>(
      () => _i604.PlaybackRepositoryImpl(gh<_i550.PlaybackDataSource>()),
    );
    gh.lazySingleton<_i828.PoiRepository>(
      () => _i486.PoiRepositoryImpl(gh<_i535.PoiDataSource>()),
      dispose: (i) => i.dispose(),
    );
    gh.factory<_i807.OnboardingCubit>(
      () => _i807.OnboardingCubit(gh<_i306.StorageService>()),
    );
    gh.lazySingleton<_i461.AppSettingsController>(
      () => _i461.AppSettingsController(gh<_i306.StorageService>()),
    );
    gh.lazySingleton<_i76.TrackingRepository>(
      () => _i279.TrackingRepositoryImpl(gh<_i765.TrackingDataSource>()),
    );
    gh.factory<_i715.RouteGuard>(
      () => _i715.RouteGuard(
        gh<_i745.AuthService>(),
        gh<_i745.AuthSessionNotifier>(),
      ),
    );
    gh.lazySingleton<_i948.GetPlaybackSegmentsUseCase>(
      () => _i948.GetPlaybackSegmentsUseCase(gh<_i832.PlaybackRepository>()),
    );
    gh.factory<_i943.PlaybackCubit>(
      () => _i943.PlaybackCubit(gh<_i948.GetPlaybackSegmentsUseCase>()),
    );
    gh.lazySingleton<_i81.AppRouter>(
      () => _i81.AppRouter(
        gh<_i715.RouteGuard>(),
        gh<_i745.AuthSessionNotifier>(),
      ),
    );
    gh.lazySingleton<_i745.AuthInterceptor>(
      () => _i745.AuthInterceptor(
        gh<_i535.SecureStorageService>(),
        gh<_i599.TokenRefresher>(),
        gh<_i361.Dio>(instanceName: 'bareDio'),
      ),
    );
    gh.lazySingleton<_i116.GetPointsOfInterestUseCase>(
      () => _i116.GetPointsOfInterestUseCase(gh<_i828.PoiRepository>()),
    );
    gh.lazySingleton<_i628.GetPointOfInterestUseCase>(
      () => _i628.GetPointOfInterestUseCase(gh<_i828.PoiRepository>()),
    );
    gh.lazySingleton<_i628.SavePointOfInterestUseCase>(
      () => _i628.SavePointOfInterestUseCase(gh<_i828.PoiRepository>()),
    );
    gh.lazySingleton<_i628.DeletePointOfInterestUseCase>(
      () => _i628.DeletePointOfInterestUseCase(gh<_i828.PoiRepository>()),
    );
    gh.lazySingleton<_i628.ImportPointsOfInterestUseCase>(
      () => _i628.ImportPointsOfInterestUseCase(gh<_i828.PoiRepository>()),
    );
    gh.lazySingleton<_i628.WatchPoiChangesUseCase>(
      () => _i628.WatchPoiChangesUseCase(gh<_i828.PoiRepository>()),
    );
    gh.lazySingleton<_i465.LanguageInterceptor>(
      () => _i465.LanguageInterceptor(gh<_i461.AppSettingsController>()),
    );
    gh.lazySingleton<_i439.GetAssetDetailsUseCase>(
      () => _i439.GetAssetDetailsUseCase(gh<_i76.TrackingRepository>()),
    );
    gh.lazySingleton<_i201.GetAssetNotificationsUseCase>(
      () => _i201.GetAssetNotificationsUseCase(gh<_i76.TrackingRepository>()),
    );
    gh.lazySingleton<_i127.GetTrackedAssetUseCase>(
      () => _i127.GetTrackedAssetUseCase(gh<_i76.TrackingRepository>()),
    );
    gh.lazySingleton<_i143.GetTrackedAssetsUseCase>(
      () => _i143.GetTrackedAssetsUseCase(gh<_i76.TrackingRepository>()),
    );
    gh.lazySingleton<_i886.GetTrackingVehiclesUseCase>(
      () => _i886.GetTrackingVehiclesUseCase(gh<_i76.TrackingRepository>()),
    );
    gh.factory<_i546.TrackingCubit>(
      () => _i546.TrackingCubit(
        gh<_i886.GetTrackingVehiclesUseCase>(),
        gh<_i143.GetTrackedAssetsUseCase>(),
      ),
    );
    gh.factory<_i1062.TrackedAssetCubit>(
      () => _i1062.TrackedAssetCubit(gh<_i127.GetTrackedAssetUseCase>()),
    );
    gh.factory<_i507.PoiImportCubit>(
      () => _i507.PoiImportCubit(
        gh<_i81.PoiFiles>(),
        gh<_i116.GetPointsOfInterestUseCase>(),
        gh<_i628.ImportPointsOfInterestUseCase>(),
      ),
    );
    gh.factory<_i61.PoiEditorCubit>(
      () => _i61.PoiEditorCubit(
        gh<_i628.GetPointOfInterestUseCase>(),
        gh<_i628.SavePointOfInterestUseCase>(),
        gh<_i628.DeletePointOfInterestUseCase>(),
      ),
    );
    gh.factory<_i98.PoiCubit>(
      () => _i98.PoiCubit(
        gh<_i116.GetPointsOfInterestUseCase>(),
        gh<_i81.PoiFiles>(),
        gh<_i628.DeletePointOfInterestUseCase>(),
        gh<_i628.WatchPoiChangesUseCase>(),
      ),
    );
    gh.lazySingleton<_i361.Dio>(
      () => networkModule.dio(
        gh<_i861.AppConfig>(),
        gh<_i745.AuthInterceptor>(),
        gh<_i465.LanguageInterceptor>(),
        gh<_i344.LoggingInterceptor>(),
        gh<_i511.ErrorInterceptor>(),
      ),
    );
    gh.factory<_i784.AssetDetailsCubit>(
      () => _i784.AssetDetailsCubit(
        gh<_i439.GetAssetDetailsUseCase>(),
        gh<_i201.GetAssetNotificationsUseCase>(),
      ),
    );
    gh.lazySingleton<_i1022.AuthRemoteDataSource>(
      () => _i1022.AuthRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i787.AuthRepository>(
      () => _i153.AuthRepositoryImpl(
        gh<_i1022.AuthRemoteDataSource>(),
        gh<_i535.SecureStorageService>(),
        gh<_i745.AuthSessionNotifier>(),
      ),
    );
    gh.lazySingleton<_i948.ForgetPasswordUseCase>(
      () => _i948.ForgetPasswordUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i17.GetCurrentUserUseCase>(
      () => _i17.GetCurrentUserUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i188.LoginUseCase>(
      () => _i188.LoginUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i48.LogoutUseCase>(
      () => _i48.LogoutUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i613.ResendOtpUseCase>(
      () => _i613.ResendOtpUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i474.ResetPasswordUseCase>(
      () => _i474.ResetPasswordUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i503.VerifyOtpUseCase>(
      () => _i503.VerifyOtpUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i752.VerifyResetOtpUseCase>(
      () => _i752.VerifyResetOtpUseCase(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i236.NewPasswordCubit>(
      () => _i236.NewPasswordCubit(gh<_i474.ResetPasswordUseCase>()),
    );
    gh.factory<_i1033.OtpCubit>(
      () => _i1033.OtpCubit(
        gh<_i503.VerifyOtpUseCase>(),
        gh<_i613.ResendOtpUseCase>(),
      ),
    );
    gh.factory<_i69.LoginCubit>(
      () => _i69.LoginCubit(gh<_i188.LoginUseCase>()),
    );
    gh.factory<_i18.CurrentUserCubit>(
      () => _i18.CurrentUserCubit(gh<_i17.GetCurrentUserUseCase>()),
    );
    gh.factory<_i648.PasswordRecoveryCubit>(
      () => _i648.PasswordRecoveryCubit(
        gh<_i948.ForgetPasswordUseCase>(),
        gh<_i752.VerifyResetOtpUseCase>(),
      ),
    );
    gh.factory<_i159.LogoutCubit>(
      () => _i159.LogoutCubit(gh<_i48.LogoutUseCase>()),
    );
    return this;
  }
}

class _$StorageModule extends _i148.StorageModule {}

class _$NetworkModule extends _i851.NetworkModule {}
