import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';
class ResetPasswordUseCase {
  const ResetPasswordUseCase(this._repository);
  final AuthRepository _repository;

  Future<Either<Failure, Unit>> call({
    required String resetToken,
    required String newPassword,
  }) => _repository.resetPassword(
    resetToken: resetToken,
    newPassword: newPassword,
  );
}
