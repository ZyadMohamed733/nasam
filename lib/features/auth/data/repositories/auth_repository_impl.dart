import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure_mapper.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../domain/entities/auth_session_entity.dart';
import '../../domain/entities/login_result.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/auth_remote_datasource.dart';
import '../mappers/auth_mapper.dart';
import '../models/auth_session_model.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote, this._secureStorage);

  final AuthRemoteDataSource _remote;
  final SecureStorageService _secureStorage;

  @override
  Future<Either<Failure, LoginResult>> login({
    required String username,
    required String password,
  }) => _guard(() async {
    final session = await _remote.login(username: username, password: password);
    if (session == null) return LoginRequiresOtp(username);
    return LoginSucceeded(await _persistSession(session));
  });

  @override
  Future<Either<Failure, AuthSessionEntity>> verifyOtp({
    required String username,
    required String code,
  }) => _guard(() async {
    final session = await _remote.verifyOtp(username: username, code: code);
    return _persistSession(session);
  });

  @override
  Future<Either<Failure, Unit>> resendOtp(String username) =>
      _guard(() async {
        await _remote.resendOtp(username);
        return unit;
      });

  @override
  Future<Either<Failure, AuthSessionEntity>> refreshAccessToken() =>
      _guard(() async {
        final storedRefreshToken = await _secureStorage.getRefreshToken();
        if (storedRefreshToken == null || storedRefreshToken.isEmpty) {
          throw const AuthException(
            message: 'No session to refresh.',
            code: '401',
          );
        }

        final result = await _remote.refreshAccessToken(storedRefreshToken);

        await _secureStorage.saveAccessToken(result.accessToken);
        await _secureStorage.saveUser(jsonEncode(result.user.toJson()));

        // Not rotated by this endpoint -- the caller keeps using the token
        // it already had.
        return AuthMapper.sessionToEntity(
          accessToken: result.accessToken,
          refreshToken: storedRefreshToken,
          user: result.user,
        );
      });

  @override
  Future<Either<Failure, Unit>> logout() => _guard(() async {
    final refreshToken = await _secureStorage.getRefreshToken();
    try {
      await _remote.logout(refreshToken);
    } on AppException {
      // Signing out is a local fact -- the server call is best-effort
      // cleanup, not a precondition for it. Storage below is cleared
      // whether or not this succeeded.
    }
    await _secureStorage.clearAll();
    return unit;
  });

  @override
  Future<Either<Failure, Unit>> forgetPassword(String email) =>
      _guard(() async {
        await _remote.forgetPassword(email);
        return unit;
      });

  @override
  Future<Either<Failure, Unit>> resetPassword({
    required String resetToken,
    required String newPassword,
  }) => _guard(() async {
    await _remote.resetPassword(
      resetToken: resetToken,
      newPassword: newPassword,
    );
    return unit;
  });

  /// Persisting here rather than in the cubit is what makes the session real
  /// to the rest of the app: AuthService reads these same keys, and
  /// RouteGuard reads AuthService. A screen that navigated home without this
  /// would be redirected straight back to login.
  ///
  /// [model]'s `refreshToken` is expected to be present -- this app always
  /// sends `X-Client: mobile`, which is what makes the API return one in the
  /// body at all -- but falls back to whatever is already stored rather than
  /// trusting that unconditionally, and fails loudly if there is neither.
  Future<AuthSessionEntity> _persistSession(AuthSessionModel model) async {
    final refreshToken =
        model.refreshToken ?? await _secureStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      throw const AuthException(
        message: 'Sign-in succeeded but no refresh token was issued.',
        code: 'missing_refresh_token',
      );
    }

    await _secureStorage.saveAccessToken(model.accessToken);
    await _secureStorage.saveRefreshToken(refreshToken);
    await _secureStorage.saveUser(jsonEncode(model.user.toJson()));

    return AuthMapper.sessionToEntity(
      accessToken: model.accessToken,
      refreshToken: refreshToken,
      user: model.user,
    );
  }

  /// There is no caching or offline fallback anywhere in this repository, and
  /// there should not be: every operation here is a credential exchange, and a
  /// stale answer to "are these credentials good" is worse than an error.
  Future<Either<Failure, T>> _guard<T>(Future<T> Function() operation) async {
    try {
      return Right(await operation());
    } on AppException catch (e) {
      return Left(FailureMapper.fromException(e));
    } catch (e, stack) {
      return Left(UnknownFailure(message: e.toString(), stackTrace: stack));
    }
  }
}
