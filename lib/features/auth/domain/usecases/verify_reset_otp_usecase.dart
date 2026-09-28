import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

/// Exchanges a password-reset code for the temporary reset token.
@lazySingleton
class VerifyResetOtpUseCase {
  const VerifyResetOtpUseCase(this._repository);
  final AuthRepository _repository;

  Future<Either<Failure, String>> call({
    required String email,
    required String code,
  }) => _repository.verifyResetOtp(email: email, code: code);
}
