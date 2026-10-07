import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// The signed-in user's stored profile; null when nobody is signed in.
class GetCurrentUserUseCase {
  const GetCurrentUserUseCase(this._repository);
  final AuthRepository _repository;

  Future<Either<Failure, UserEntity?>> call() => _repository.currentUser();
}
