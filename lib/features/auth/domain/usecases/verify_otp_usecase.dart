import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/auth_session_entity.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class VerifyOtpUseCase {
  const VerifyOtpUseCase(this._repository);
  final AuthRepository _repository;

  Future<Either<Failure, AuthSessionEntity>> call({
    required String username,
    required String code,
  }) => _repository.verifyOtp(username: username, code: code);
}
