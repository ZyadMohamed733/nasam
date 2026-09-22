import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class ResendOtpUseCase {
  const ResendOtpUseCase(this._repository);
  final AuthRepository _repository;

  Future<Either<Failure, Unit>> call(String username) =>
      _repository.resendOtp(username);
}
