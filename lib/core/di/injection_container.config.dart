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
import '../../features/_template/data/datasources/local/template_local_datasource.dart'
    as _i923;
import '../../features/_template/data/datasources/remote/template_remote_datasource.dart'
    as _i79;
import '../../features/_template/data/repositories/template_repository_impl.dart'
    as _i483;
import '../../features/_template/domain/repositories/template_repository.dart'
    as _i43;
import '../../features/_template/domain/usecases/get_template_usecase.dart'
    as _i932;
import '../../features/_template/presentation/bloc/template_bloc.dart' as _i884;
import '../../features/auth/data/datasources/remote/auth_remote_datasource.dart'
    as _i1022;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/domain/usecases/login_usecase.dart' as _i188;
import '../../features/auth/domain/usecases/request_password_reset_usecase.dart'
    as _i438;
import '../../features/auth/domain/usecases/reset_password_usecase.dart'
    as _i474;
import '../../features/auth/domain/usecases/verify_reset_code_usecase.dart'
    as _i694;
import '../../features/auth/presentation/cubit/forgot_password_cubit.dart'
    as _i104;
import '../../features/auth/presentation/cubit/login_cubit.dart' as _i69;
import '../../features/auth/presentation/cubit/new_password_cubit.dart'
    as _i236;
import '../../features/auth/presentation/cubit/otp_cubit.dart' as _i1033;
import '../../features/onboarding/presentation/cubit/onboarding_cubit.dart'
    as _i807;
import '../network/interceptors/auth_interceptor.dart' as _i745;
import '../network/interceptors/error_interceptor.dart' as _i511;
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
    gh.lazySingleton<_i1022.AuthRemoteDataSource>(
      () => const _i1022.AuthRemoteDataSourceMock(),
    );
    gh.lazySingleton<_i535.SecureStorageService>(
      () => _i535.SecureStorageService(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i787.AuthRepository>(
      () => _i153.AuthRepositoryImpl(
        gh<_i1022.AuthRemoteDataSource>(),
        gh<_i535.SecureStorageService>(),
      ),
    );
    gh.lazySingleton<_i306.StorageService>(
      () => _i306.StorageService(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i555.WebSocketService>(
      () => _i555.WebSocketService(gh<_i861.AppConfig>()),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i188.LoginUseCase>(
      () => _i188.LoginUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i438.RequestPasswordResetUseCase>(
      () => _i438.RequestPasswordResetUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i474.ResetPasswordUseCase>(
      () => _i474.ResetPasswordUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i694.VerifyResetCodeUseCase>(
      () => _i694.VerifyResetCodeUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i745.AuthService>(
      () => _i745.AuthServiceImpl(gh<_i535.SecureStorageService>()),
    );
    gh.factory<_i236.NewPasswordCubit>(
      () => _i236.NewPasswordCubit(gh<_i474.ResetPasswordUseCase>()),
    );
    gh.lazySingleton<_i923.TemplateLocalDataSource>(
      () => _i923.TemplateLocalDataSourceImpl(gh<_i460.SharedPreferences>()),
    );
    gh.factory<_i104.ForgotPasswordCubit>(
      () => _i104.ForgotPasswordCubit(gh<_i438.RequestPasswordResetUseCase>()),
    );
    gh.factory<_i69.LoginCubit>(
      () => _i69.LoginCubit(gh<_i188.LoginUseCase>()),
    );
    gh.lazySingleton<_i745.AuthInterceptor>(
      () => _i745.AuthInterceptor(gh<_i535.SecureStorageService>()),
    );
    gh.factory<_i807.OnboardingCubit>(
      () => _i807.OnboardingCubit(gh<_i306.StorageService>()),
    );
    gh.lazySingleton<_i461.AppSettingsController>(
      () => _i461.AppSettingsController(gh<_i306.StorageService>()),
    );
    gh.factory<_i715.RouteGuard>(
      () => _i715.RouteGuard(gh<_i745.AuthService>()),
    );
    gh.factory<_i1033.OtpCubit>(
      () => _i1033.OtpCubit(
        gh<_i694.VerifyResetCodeUseCase>(),
        gh<_i438.RequestPasswordResetUseCase>(),
      ),
    );
    gh.lazySingleton<_i361.Dio>(
      () => networkModule.dio(
        gh<_i861.AppConfig>(),
        gh<_i745.AuthInterceptor>(),
        gh<_i344.LoggingInterceptor>(),
        gh<_i511.ErrorInterceptor>(),
      ),
    );
    gh.lazySingleton<_i81.AppRouter>(
      () => _i81.AppRouter(gh<_i715.RouteGuard>()),
    );
    gh.lazySingleton<_i79.TemplateRemoteDataSource>(
      () => _i79.TemplateRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i43.TemplateRepository>(
      () => _i483.TemplateRepositoryImpl(
        gh<_i79.TemplateRemoteDataSource>(),
        gh<_i923.TemplateLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i932.GetTemplateUseCase>(
      () => _i932.GetTemplateUseCase(gh<_i43.TemplateRepository>()),
    );
    gh.factory<_i884.TemplateBloc>(
      () => _i884.TemplateBloc(gh<_i932.GetTemplateUseCase>()),
    );
    return this;
  }
}

class _$StorageModule extends _i148.StorageModule {}

class _$NetworkModule extends _i851.NetworkModule {}
