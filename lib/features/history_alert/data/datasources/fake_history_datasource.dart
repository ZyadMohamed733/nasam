import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:nasam/features/history_alert/data/models/history_alert_detailed_model.dart';
import 'package:nasam/features/history_alert/data/models/histroy_alert_model.dart';

import '../../../../core/errors/exceptions.dart';
import 'history_alert_datasource.dart';

@LazySingleton(as: HistoryAlertDataSource)
class FakeHistoryDatasource  implements HistoryAlertDataSource {
  FakeHistoryDatasource({
    @ignoreParam AssetBundle? bundle,
    @ignoreParam Duration? latency,
    @ignoreParam bool? simulateFailure,
  }) : _bundle = bundle ?? rootBundle,
        _latency = latency ?? const Duration(milliseconds: 300),
        _simulateFailure = simulateFailure ?? _failureFlag,
        _simulateEmpty = _emptyFlag;

  static const bool _failureFlag =
      kDebugMode &&
          bool.fromEnvironment(
            'HISTORY_FIXTURE_FAIL',
            defaultValue: bool.fromEnvironment('TRACKING_FIXTURE_FAIL'),
          );
  static const bool _emptyFlag =
      kDebugMode && bool.fromEnvironment('PLAYBACK_FIXTURE_EMPTY');
  static const _root = 'assets/fixtures/history_alert';
  static final _recordedDay = DateTime(2025, 10, 17);
  final AssetBundle _bundle;
  final Duration _latency;
  final bool _simulateFailure;
  final bool _simulateEmpty;
  @override
  Future<List<HistoryAlertModel>> getHistoryAlert() async{
    await _simulateNetwork();
    if (_simulateEmpty) return const [];

    final json =
    jsonDecode(await _bundle.loadString('$_root/alert_history.json')) as Map<String, dynamic>;

    final recorded = (json['alerts'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>()
        .map(HistoryAlertModel.fromJson)
        .toList(growable: false);

    return recorded;

  }

  @override
  Future<HistoryAlertDetailsModel> getHistoryDetailed() async{
    await _simulateNetwork();
    // if (_simulateEmpty) {
    //   return const  HistoryAlertDetailsModel(id: "id", title: "",
    //     basicInfo: AlertBasicInfoModel(alertName: "alertName", assetName: "assetName", alertType: "alertType", alertTypeLabel: "alertTypeLabel", timestamp: DateTime.now(), location: "location"));
    // }

    final json =
    jsonDecode(await _bundle.loadString('$_root/alert_history.json')) as Map<String, dynamic>;

    final recorded = HistoryAlertDetailsModel.fromJson(
      json['alertDetails'] as Map<String, dynamic>,
    );


    return recorded;
  }

  Future<void> _simulateNetwork() async {
    if (_latency > Duration.zero) await Future<void>.delayed(_latency);
    if (_simulateFailure) {
      throw const ServerException(
        message: 'Simulated history alert failure.',
        code: '503',
      );
    }
  }
}
