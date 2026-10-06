import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/history_alert_detailed_model.dart';
import '../models/histroy_alert_model.dart';
import 'history_alert_datasource.dart';
import 'history_alert_fixture_scenarios.dart';

@LazySingleton(as: HistoryAlertDataSource)
class FakeHistoryDatasource implements HistoryAlertDataSource {
  /// Change this static value to test an alert history response on device.
  static const String deviceTestScenario =
      HistoryAlertFixtureScenarios.success;

  FakeHistoryDatasource({
    @ignoreParam AssetBundle? bundle,
    @ignoreParam Duration? latency,
    @ignoreParam bool? simulateFailure,
    @ignoreParam String? scenario,
  }) : _bundle = bundle ?? rootBundle,
       _latency = latency ?? const Duration(seconds: 4),
       _scenario =
           scenario ??
           (simulateFailure == true
               ? HistoryAlertFixtureScenarios.serverError
               : simulateFailure == false
               ? HistoryAlertFixtureScenarios.success
               : _configuredScenario);

  static const String _configuredScenario = kDebugMode
      ? deviceTestScenario
      : HistoryAlertFixtureScenarios.success;
  static const String _root = 'assets/fixtures/history_alert';

  final AssetBundle _bundle;
  final Duration _latency;
  final String _scenario;
  bool _hasFailedOnce = false;

  @override
  Future<List<HistoryAlertModel>> getHistoryAlert() async {
    await _simulateResponse(details: false);
    if (_scenario == HistoryAlertFixtureScenarios.empty) return const [];

    final source = await _bundle.loadString('$_root/alert_history.json');
    final json =
        jsonDecode(_response(source, details: false)) as Map<String, dynamic>;
    return (json['alerts'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>()
        .map(HistoryAlertModel.fromJson)
        .toList(growable: false);
  }

  @override
  Future<HistoryAlertDetailsModel> getHistoryDetailed({
    required String alertId,
  }) async {
    await _simulateResponse(details: true);
    final source = await _bundle.loadString('$_root/alert_history.json');
    final json =
        jsonDecode(_response(source, details: true)) as Map<String, dynamic>;
    final alerts = (json['alerts'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
    Map<String, dynamic>? selected;
    for (final item in alerts) {
      if (item['id'] == alertId) {
        selected = item;
        break;
      }
    }
    if (selected == null) {
      throw ServerException(
        message: 'Alert $alertId was not found.',
        code: '404',
      );
    }

    final alert = HistoryAlertModel.fromJson(selected);
    final speedDetails =
        alert.alertType == 'speed' &&
            alert.value != null &&
            alert.speedLimit != null
        ? AlertSpeedDetailsModel(
            recordedSpeed: alert.value!,
            speedLimit: alert.speedLimit!,
            unit: alert.unit ?? '',
            unitLabel: alert.valueLabel,
            isViolation: alert.value! > alert.speedLimit!,
          )
        : null;
    return HistoryAlertDetailsModel(
      id: alert.id,
      title: alert.title,
      basicInfo: AlertBasicInfoModel(
        alertName: alert.title,
        assetName: alert.assetName,
        alertType: alert.alertType,
        alertTypeLabel: alert.alertTypeLabel,
        timestamp: alert.timestamp,
        location: alert.location,
      ),
      speedDetails: speedDetails,
    );
  }

  String _response(String response, {required bool details}) {
    if (_scenario == HistoryAlertFixtureScenarios.malformedPayload ||
        (details &&
            _scenario ==
                HistoryAlertFixtureScenarios.detailsMalformedPayload)) {
      return '{ malformed history alert response';
    }
    return response;
  }

  Future<void> _simulateResponse({required bool details}) async {
    if (_latency > Duration.zero) await Future<void>.delayed(_latency);

    final detailOnly = _scenario.startsWith('details');
    if (detailOnly && !details) return;

    final failOnce =
        _scenario == HistoryAlertFixtureScenarios.serverErrorOnce ||
        _scenario == HistoryAlertFixtureScenarios.detailsServerErrorOnce;
    if (failOnce) {
      if (_hasFailedOnce) return;
      _hasFailedOnce = true;
      throw const ServerException(
        message: 'Simulated one-time history alert server error.',
        code: '503',
      );
    }

    final scenario = detailOnly
        ? '${_scenario['details'.length].toLowerCase()}${_scenario.substring('details'.length + 1)}'
        : _scenario;
    switch (scenario) {
      case HistoryAlertFixtureScenarios.success:
      case HistoryAlertFixtureScenarios.empty:
      case HistoryAlertFixtureScenarios.malformedPayload:
        return;
      case HistoryAlertFixtureScenarios.serverError:
        throw const ServerException(
          message: 'Simulated history alert server error.',
          code: '503',
        );
      case HistoryAlertFixtureScenarios.networkError:
        throw const NetworkException(
          message: 'Simulated history alert network failure.',
          code: 'offline',
        );
      case HistoryAlertFixtureScenarios.timeout:
        throw const TimeoutException(
          message: 'Simulated history alert request timeout.',
          code: 'timeout',
        );
      case HistoryAlertFixtureScenarios.unauthorized:
        throw const AuthException(
          message: 'Simulated expired session.',
          code: '401',
        );
      case HistoryAlertFixtureScenarios.rateLimit:
        throw const RateLimitException(
          message: 'Simulated history alert rate limit.',
          code: '429',
          retryAfterSeconds: 30,
        );
      case HistoryAlertFixtureScenarios.unknownError:
        throw StateError('Simulated unexpected history alert error.');
      default:
        throw ArgumentError.value(
          _scenario,
          'deviceTestScenario',
          'Unknown history alert fixture scenario.',
        );
    }
  }
}
