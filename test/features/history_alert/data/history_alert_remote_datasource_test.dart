import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/core/errors/exceptions.dart';
import 'package:nasam/features/history_alert/data/datasources/history_alert_datasource.dart';
import 'package:nasam/features/history_alert/data/mappers/history_mapper.dart';
import 'package:nasam/features/history_alert/domain/entities/alert_history_filter.dart';
import 'package:nasam/features/history_alert/domain/entities/alert_history_page.dart';
import 'package:nasam/features/history_alert/domain/entities/history_alert.dart';
import 'package:nasam/features/history_alert/domain/entities/history_details.dart';

import '../../../helpers/recording_adapter.dart';
import '../alert_history_json.dart';

void main() {
  late RecordingAdapter adapter;
  late HistoryAlertRemoteDataSource dataSource;

  void answer(int status, Object? body) =>
      adapter.respond = (_) => (status, body);

  setUp(() {
    adapter = RecordingAdapter((_) => (200, pageJson([alertJson()])));
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test/api/v1'))
      ..httpClientAdapter = adapter;
    dataSource = HistoryAlertRemoteDataSource(dio);
  });

  group('GET /alerts/history', () {
    test('sends only the paging when nothing narrows the list', () async {
      await dataSource.getHistoryAlert(const AlertHistoryQuery());
      final request = adapter.requests.single;
      expect(request.method, 'GET');
      expect(request.uri.path, '/api/v1/alerts/history');
      expect(request.uri.queryParameters, {'page': '1', 'limit': '20'});
    });

    test(
      'sends the type code, the UTC bounds and the trimmed search',
      () async {
        final from = DateTime.utc(2026, 10, 12, 21);
        final to = DateTime.utc(2026, 10, 13, 20, 59, 59, 999);
        await dataSource.getHistoryAlert(
          AlertHistoryQuery(
            filter: AlertHistoryFilter(
              type: AlertType.downtime,
              datePreset: AlertDatePreset.today,
              from: from,
              to: to,
            ),
            search: '  Truck 101 ',
            page: 3,
            limit: 10,
          ),
        );
        expect(adapter.requests.single.uri.queryParameters, {
          'page': '3',
          'limit': '10',
          'alertType': 'DOWNTIME',
          'from': '2026-10-12T21:00:00.000Z',
          'to': '2026-10-13T20:59:59.999Z',
          'search': 'Truck 101',
        });
      },
    );

    test('reads the rows and the paging meta', () async {
      answer(
        200,
        pageJson(
          [alertJson(), alertJson(id: 'two', location: null)],
          page: 2,
          totalPages: 5,
          totalCount: 90,
        ),
      );
      final page = AlertMapper.page(
        await dataSource.getHistoryAlert(const AlertHistoryQuery()),
      );
      expect(page.page, 2);
      expect(page.totalPages, 5);
      expect(page.totalCount, 90);
      expect(page.hasMore, isTrue);

      final first = page.alerts.first;
      expect(first.occurredAt, DateTime.utc(2026, 10, 13, 11, 47));
      expect(first.occurredAt.isUtc, isTrue);
      expect(first.alertType, AlertType.speed);
      expect(first.asset.code, 'VH-001');
      expect(first.asset.name.of('ar'), 'شاحنة 101');
      expect(first.alertName.of('en'), 'Speeding over 100 km/h');
      expect(first.triggeredValue.of('ar'), '108 كم/س');
      expect(
        first.location,
        const AlertLocation(latitude: 24.7136, longitude: 46.6753),
      );
      expect(page.alerts.last.location, isNull);
    });

    test('an empty result is a page, not an error', () async {
      answer(200, pageJson(const [], totalPages: 0));
      final page = AlertMapper.page(
        await dataSource.getHistoryAlert(const AlertHistoryQuery()),
      );
      expect(page.alerts, isEmpty);
      expect(page.hasMore, isFalse);
    });

    test('a type the app does not know yet does not fail the list', () async {
      answer(200, pageJson([alertJson(alertType: 'GEOFENCE')]));
      final page = AlertMapper.page(
        await dataSource.getHistoryAlert(const AlertHistoryQuery()),
      );
      expect(page.alerts.single.alertType, AlertType.geofence);
      answer(200, pageJson([alertJson(alertType: 'SOMETHING_NEW')]));
      final next = AlertMapper.page(
        await dataSource.getHistoryAlert(const AlertHistoryQuery()),
      );
      expect(next.alerts.single.alertType, AlertType.unknown);
    });

    test('maps the API errors to app exceptions', () async {
      answer(400, {
        'statusCode': 400,
        'message': ['To Date must be on or after From Date.'],
      });
      await expectLater(
        dataSource.getHistoryAlert(const AlertHistoryQuery()),
        throwsA(isA<ValidationException>()),
      );
      answer(403, {'statusCode': 403, 'message': 'Forbidden'});
      await expectLater(
        dataSource.getHistoryAlert(const AlertHistoryQuery()),
        throwsA(isA<PermissionException>()),
      );
    });

    test('a body that breaks the contract is a server error', () async {
      answer(200, {
        'data': [
          {'id': 1},
        ],
      });
      await expectLater(
        dataSource.getHistoryAlert(const AlertHistoryQuery()),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('GET /alerts/history/:historyId', () {
    Future<HistoryAlertDetailsEntity> details(Map<String, dynamic> json) async {
      answer(200, json);
      return AlertMapper.details(
        await dataSource.getHistoryDetailed(alertId: 'a0000000-1'),
      );
    }

    test('asks for the alert by id', () async {
      await details(detailsJson(speedDetailsJson));
      expect(
        adapter.requests.single.uri.path,
        '/api/v1/alerts/history/a0000000-1',
      );
    });

    test('reads speed details', () async {
      final entity = await details(detailsJson(speedDetailsJson));
      final speed = entity.details! as SpeedAlertDetails;
      expect(speed.recordedSpeedKph, 108);
      expect(speed.speedLimitKph, 100);
      expect(speed.isViolation, isTrue);
    });

    test('reads sensor details', () async {
      final entity = await details(detailsJson(sensorDetailsJson));
      final sensor = entity.details! as SensorAlertDetails;
      expect(sensor.sensorName.of('en'), 'Truck 101 engine temperature');
      expect(sensor.sensorType, 'TEMPERATURE');
      expect(sensor.triggeredValue, 112);
      expect(sensor.unit, '°C');
      expect(sensor.conditionOperator, SensorConditionOperator.greaterThan);
      expect(sensor.conditionValue, 105);
    });

    test('reads downtime details', () async {
      final entity = await details(detailsJson(downtimeDetailsJson));
      expect((entity.details! as DowntimeAlertDetails).durationMinutes, 45);
    });

    test('an unknown details type has no details', () async {
      final entity = await details(detailsJson({'type': 'GEOFENCE'}));
      expect(entity.alert.alertType, AlertType.geofence);
      expect(entity.details, isNull);
    });

    test('another company\'s alert is a plain 404', () async {
      answer(404, {'statusCode': 404, 'message': 'Alert not found'});
      await expectLater(
        dataSource.getHistoryDetailed(alertId: 'x'),
        throwsA(
          isA<ServerException>()
              .having((e) => e.code, 'code', '404')
              .having((e) => e.message, 'message', 'Alert not found'),
        ),
      );
    });
  });
}
