import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/auth_session_entity.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class RefreshAccessTokenUseCase {
  const RefreshAccessTokenUseCase(this._repository);
  final AuthRepository _repository;

  Future<Either<Failure, AuthSessionEntity>> call() =>
      _repository.refreshAccessToken();
}
