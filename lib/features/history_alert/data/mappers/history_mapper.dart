import '../../domain/entities/history_alert.dart';
import '../../domain/entities/history_details.dart';
import '../models/history_alert_detailed_model.dart';
import '../models/histroy_alert_model.dart';

/// Wire models to domain entities.
///
/// Enum wire values are converted here and nowhere else. An unknown alert type
/// maps to [AlertType.unknown] instead of throwing: the backend adds alert
/// types over time, and one new type should not fail the whole history list.
abstract final class AlertMapper {
  static HistoryAlertEntity alert(HistoryAlertModel m) => HistoryAlertEntity(
    id: m.id,
    title: m.title,
    alertType: _alertType(m.alertType),
    alertTypeLabel: m.alertTypeLabel,
    assetName: m.assetName,
    value: m.value,
    unit: m.unit,
    speedLimit: m.speedLimit,
    valueLabel: m.valueLabel,
    timestamp: m.timestamp,
    location: m.location,
  );

  static HistoryAlertDetailsEntity details(HistoryAlertDetailsModel m) =>
      HistoryAlertDetailsEntity(
        id: m.id,
        title: m.title,
        basicInfo: _basicInfo(m.basicInfo),
        speedDetails: switch (m.speedDetails) {
          final speed? => _speedDetails(speed),
          _ => null,
        },
      );

  static AlertBasicInfoEntity _basicInfo(AlertBasicInfoModel m) =>
      AlertBasicInfoEntity(
        alertName: m.alertName,
        assetName: m.assetName,
        alertType: _alertType(m.alertType),
        alertTypeLabel: m.alertTypeLabel,
        timestamp: m.timestamp,
        location: m.location,
      );

  static AlertSpeedDetailsEntity _speedDetails(AlertSpeedDetailsModel m) =>
      AlertSpeedDetailsEntity(
        recordedSpeed: m.recordedSpeed,
        speedLimit: m.speedLimit,
        unit: m.unit,
        unitLabel: m.unitLabel,
        isViolation: m.isViolation,
      );

  static AlertType _alertType(String value) => switch (value) {
    'speed' => AlertType.speed,
    'sensor' => AlertType.sensor,
    'geofence' => AlertType.geofence,
    'downtime' => AlertType.downtime,
    _ => AlertType.unknown,
  };
}
