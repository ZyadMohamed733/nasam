import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

/// Renamed from `RequestPasswordResetUseCase` to match the endpoint's actual
/// name (`POST /auth/forget-password`).
@lazySingleton
class ForgetPasswordUseCase {
  const ForgetPasswordUseCase(this._repository);
  final AuthRepository _repository;

  Future<Either<Failure, Unit>> call(String email) =>
      _repository.forgetPassword(email);
}
