import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
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
    final response = await _dio.get<Map<String, dynamic>>('/templates/$id');
    if (response.data != null) {
      return TemplateModel.fromJson(response.data!);
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    }
  }
}
