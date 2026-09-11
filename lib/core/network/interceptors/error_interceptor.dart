import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../errors/exception_mapper.dart';

/// Normalises the human-readable message on a failed request.
///
/// It deliberately does not put an `AppException` or a `Failure` into
/// [DioException.error]: datasources translate transport errors themselves via
/// [ExceptionMapper], so the error contract does not depend on this
/// interceptor being present in the chain.
@injectable
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = ExceptionMapper.fromDioException(err);
    handler.next(err.copyWith(message: exception.message));
  }
}
