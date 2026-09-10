import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/errors/exception_mapper.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../models/template_model.dart';

abstract class TemplateRemoteDataSource {
  Future<TemplateModel> getTemplate(String id);
}

@LazySingleton(as: TemplateRemoteDataSource)
class TemplateRemoteDataSourceImpl implements TemplateRemoteDataSource {
  const TemplateRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<TemplateModel> getTemplate(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/templates/$id');
      final data = response.data;
      if (data == null) {
        throw ServerException(
          message: 'Server returned an empty body.',
          code: response.statusCode?.toString(),
        );
      }
      return TemplateModel.fromJson(data);
    } on DioException catch (e) {
      throw ExceptionMapper.fromDioException(e);
    } on FormatException catch (e, stack) {
      throw ServerException(message: e.message, stackTrace: stack);
    } on TypeError catch (_, stack) {
      throw ServerException(
        message: 'Server returned a template in an unexpected shape.',
        stackTrace: stack,
      );
    }
  }
}
