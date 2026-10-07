import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../../core/auth/auth_session_notifier.dart';
import '../../../core/services/secure_storage_service.dart';
import '../data/datasources/remote/auth_remote_datasource.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/usecases/forget_password_usecase.dart';
import '../domain/usecases/get_current_user_usecase.dart';
import '../domain/usecases/login_usecase.dart';
import '../domain/usecases/logout_usecase.dart';
import '../domain/usecases/resend_otp_usecase.dart';
import '../domain/usecases/reset_password_usecase.dart';
import '../domain/usecases/verify_otp_usecase.dart';
import '../domain/usecases/verify_reset_otp_usecase.dart';
import '../presentation/cubit/current_user_cubit.dart';
import '../presentation/cubit/login_cubit.dart';
import '../presentation/cubit/logout_cubit.dart';
import '../presentation/cubit/new_password_cubit.dart';
import '../presentation/cubit/otp_cubit.dart';
import '../presentation/cubit/password_recovery_cubit.dart';

void registerAuthDependencies(GetIt getIt) {
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt<Dio>()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      getIt<AuthRemoteDataSource>(),
      getIt<SecureStorageService>(),
      getIt<AuthSessionNotifier>(),
    ),
  );
  getIt.registerLazySingleton<ForgetPasswordUseCase>(
    () => ForgetPasswordUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<GetCurrentUserUseCase>(
    () => GetCurrentUserUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<ResendOtpUseCase>(
    () => ResendOtpUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<ResetPasswordUseCase>(
    () => ResetPasswordUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<VerifyOtpUseCase>(
    () => VerifyOtpUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<VerifyResetOtpUseCase>(
    () => VerifyResetOtpUseCase(getIt<AuthRepository>()),
  );
  getIt.registerFactory<NewPasswordCubit>(
    () => NewPasswordCubit(getIt<ResetPasswordUseCase>()),
  );
  getIt.registerFactory<OtpCubit>(
    () => OtpCubit(getIt<VerifyOtpUseCase>(), getIt<ResendOtpUseCase>()),
  );
  getIt.registerFactory<LoginCubit>(() => LoginCubit(getIt<LoginUseCase>()));
  getIt.registerFactory<CurrentUserCubit>(
    () => CurrentUserCubit(getIt<GetCurrentUserUseCase>()),
  );
  getIt.registerFactory<PasswordRecoveryCubit>(
    () => PasswordRecoveryCubit(
      getIt<ForgetPasswordUseCase>(),
      getIt<VerifyResetOtpUseCase>(),
    ),
  );
  getIt.registerFactory<LogoutCubit>(() => LogoutCubit(getIt<LogoutUseCase>()));
}
