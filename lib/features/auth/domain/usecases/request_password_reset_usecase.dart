import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class RequestPasswordResetUseCase {
  const RequestPasswordResetUseCase(this._repository);
  final AuthRepository _repository;

  Future<Either<Failure, Unit>> call(String email) =>
      _repository.requestPasswordReset(email);
}
