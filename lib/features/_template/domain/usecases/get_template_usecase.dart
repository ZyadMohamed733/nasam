import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/template_entity.dart';
import '../repositories/template_repository.dart';

@lazySingleton
class GetTemplateUseCase {
  const GetTemplateUseCase(this._repository);
  final TemplateRepository _repository;

  Future<Either<Failure, TemplateEntity>> call(String id) {
    return _repository.getTemplate(id);
  }
}
