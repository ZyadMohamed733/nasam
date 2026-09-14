import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure_mapper.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../domain/entities/auth_tokens_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/auth_remote_datasource.dart';
import '../mappers/auth_mapper.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote, this._secureStorage);

  final AuthRemoteDataSource _remote;
  final SecureStorageService _secureStorage;

  @override
  Future<Either<Failure, AuthTokensEntity>> login({
    required String email,
    required String password,
  }) => _guard(() async {
    final model = await _remote.login(email: email, password: password);

    // Persisting here rather than in the cubit is what makes the session real
    // to the rest of the app: AuthService reads these same keys, and
    // RouteGuard reads AuthService. A screen that navigated home without this
    // would be redirected straight back to login.
    await _secureStorage.saveAccessToken(model.accessToken);
    await _secureStorage.saveRefreshToken(model.refreshToken);

    return AuthMapper.toEntity(model);
  });

  @override
  Future<Either<Failure, Unit>> requestPasswordReset(String email) =>
      _guard(() async {
        await _remote.requestPasswordReset(email);
        return unit;
      });

  @override
  Future<Either<Failure, String>> verifyResetCode({
    required String email,
    required String code,
  }) => _guard(() => _remote.verifyResetCode(email: email, code: code));

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
