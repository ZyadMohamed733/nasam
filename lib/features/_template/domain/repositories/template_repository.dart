import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/template_entity.dart';

abstract class TemplateRepository {
  Future<Either<Failure, TemplateEntity>> getTemplate(String id);
}
