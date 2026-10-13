import 'package:dio/dio.dart';

import '../../../../core/errors/exception_mapper.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/alert_history_page.dart';
import '../mappers/history_mapper.dart';
import '../models/alert_history_models.dart';

abstract interface class HistoryAlertDataSource {
  Future<AlertHistoryPageModel> getHistoryAlert(AlertHistoryQuery query);
  Future<AlertHistoryDetailsModel> getHistoryDetailed({
    required String alertId,
  });
}

/// Alert History over the API (`/alerts/history`, NASAM-621). The user's
/// company comes from the session; a Level 2 user is never sent a company.
class HistoryAlertRemoteDataSource implements HistoryAlertDataSource {
  const HistoryAlertRemoteDataSource(this._dio);

  final Dio _dio;

  static const String path = '/alerts/history';

  /// The query string for [query]: only the filters that are set, dates as
  /// UTC instants so the day boundaries the app chose are the ones applied.
  static Map<String, dynamic> queryParameters(AlertHistoryQuery query) {
    final filter = query.filter;
    final type = filter.type;
    final typeCode = type == null ? null : AlertMapper.alertTypeCode(type);
    final search = query.search.trim();
    return {
      'page': query.page,
      'limit': query.limit,
      'alertType': ?typeCode,
      'from': ?filter.from?.toUtc().toIso8601String(),
      'to': ?filter.to?.toUtc().toIso8601String(),
      if (search.isNotEmpty) 'search': search,
    };
  }

  @override
  Future<AlertHistoryPageModel> getHistoryAlert(AlertHistoryQuery query) =>
      _guard(() async {
        final response = await _dio.get<Map<String, dynamic>>(
          path,
          queryParameters: queryParameters(query),
        );
        return AlertHistoryPageModel.fromJson(response.data ?? const {});
      });

  @override
  Future<AlertHistoryDetailsModel> getHistoryDetailed({
    required String alertId,
  }) => _guard(() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '$path/${Uri.encodeComponent(alertId)}',
    );
    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw const ServerException(
        message: 'Alert details response has no data.',
      );
    }
    return AlertHistoryDetailsModel.fromJson(data);
  });

  /// Keeps `DioException` inside the data source; a body that does not match
  /// the contract surfaces as a [ServerException] rather than a type error.
  static Future<T> _guard<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw ExceptionMapper.fromDioException(e);
    } on TypeError catch (e, stack) {
      throw ServerException(
        message: 'Alert history response did not match the contract: $e',
        stackTrace: stack,
      );
    }
  }
}
