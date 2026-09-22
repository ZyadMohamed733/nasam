import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/login_result.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class LoginUseCase {
  const LoginUseCase(this._repository);
  final AuthRepository _repository;

  Future<Either<Failure, LoginResult>> call({
    required String username,
    required String password,
  }) => _repository.login(username: username, password: password);
}
