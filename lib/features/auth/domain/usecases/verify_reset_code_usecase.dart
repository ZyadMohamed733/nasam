import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class VerifyResetCodeUseCase {
  const VerifyResetCodeUseCase(this._repository);
  final AuthRepository _repository;

  Future<Either<Failure, String>> call({
    required String email,
    required String code,
  }) => _repository.verifyResetCode(email: email, code: code);
}
