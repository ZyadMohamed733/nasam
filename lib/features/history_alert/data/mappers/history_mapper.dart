import '../../domain/entities/alert_history_page.dart';
import '../../domain/entities/history_alert.dart';
import '../../domain/entities/history_details.dart';
import '../models/alert_history_models.dart';

/// Wire models to domain entities, and the alert type back to its wire code.
///
/// Enum wire values are converted here and nowhere else. An unknown alert type
/// maps to [AlertType.unknown] instead of throwing: the backend adds alert
/// types over time (geofence is next), and one new type should not fail the
/// whole history list. An unknown `details.type` gives no details for the
/// same reason.
abstract final class AlertMapper {
  static AlertHistoryPage page(AlertHistoryPageModel m) => AlertHistoryPage(
    alerts: m.items.map(alert).toList(growable: false),
    page: m.meta.currentPage,
    totalPages: m.meta.totalPages,
    totalCount: m.meta.totalCount,
  );

  static HistoryAlertEntity alert(AlertHistoryItemModel m) =>
      HistoryAlertEntity(
        id: m.id,
        occurredAt: DateTime.parse(m.occurredAt).toUtc(),
        asset: AlertAsset(
          id: m.asset.id,
          code: m.asset.code,
          name: LocalizedText(en: m.asset.nameEn, ar: m.asset.nameAr),
        ),
        alertType: alertType(m.alertType),
        alertName: LocalizedText(en: m.alertNameEn, ar: m.alertNameAr),
        triggeredValue: LocalizedText(
          en: m.triggeredValueEn,
          ar: m.triggeredValueAr,
        ),
        location: switch (m.location) {
          final location? => AlertLocation(
            latitude: location.latitude.toDouble(),
            longitude: location.longitude.toDouble(),
          ),
          null => null,
        },
      );

  static HistoryAlertDetailsEntity details(AlertHistoryDetailsModel m) =>
      HistoryAlertDetailsEntity(
        alert: alert(m.item),
        details: switch (m.details) {
          final json? => _typeDetails(json),
          null => null,
        },
      );

  static AlertTypeDetails? _typeDetails(Map<String, dynamic> json) =>
      switch (json['type']) {
        'SPEED' => SpeedAlertDetails(
          recordedSpeedKph: json['recordedSpeedKph'] as num,
          speedLimitKph: json['speedLimitKph'] as num,
        ),
        'SENSOR' => _sensorDetails(json),
        'DOWNTIME' => DowntimeAlertDetails(
          durationMinutes: (json['durationMinutes'] as num).toInt(),
        ),
        _ => null,
      };

  static SensorAlertDetails _sensorDetails(Map<String, dynamic> json) {
    final sensor = json['sensor'] as Map<String, dynamic>;
    final condition = json['condition'] as Map<String, dynamic>;
    return SensorAlertDetails(
      sensorName: LocalizedText(
        en: sensor['nameEn'] as String? ?? '',
        ar: sensor['nameAr'] as String? ?? '',
      ),
      sensorType: sensor['sensorType'] as String? ?? '',
      triggeredValue: json['triggeredValue'] as num,
      unit: json['unit'] as String? ?? sensor['unit'] as String? ?? '',
      conditionOperator: condition['operator'] == 'LESS_THAN'
          ? SensorConditionOperator.lessThan
          : SensorConditionOperator.greaterThan,
      conditionValue: condition['value'] as num,
    );
  }

  static AlertType alertType(String value) => switch (value) {
    'SPEED' => AlertType.speed,
    'SENSOR' => AlertType.sensor,
    'GEOFENCE' => AlertType.geofence,
    'DOWNTIME' => AlertType.downtime,
    _ => AlertType.unknown,
  };

  /// The `alertType` query value. Null for a type the API cannot filter on.
  static String? alertTypeCode(AlertType type) => switch (type) {
    AlertType.speed => 'SPEED',
    AlertType.sensor => 'SENSOR',
    AlertType.geofence => 'GEOFENCE',
    AlertType.downtime => 'DOWNTIME',
    AlertType.unknown => null,
  };
}
