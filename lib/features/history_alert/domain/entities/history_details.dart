import 'history_alert.dart';

/// One alert with the part that depends on its type.
class HistoryAlertDetailsEntity {
  const HistoryAlertDetailsEntity({required this.alert, this.details});

  final HistoryAlertEntity alert;

  /// Null for a type the app does not know yet.
  final AlertTypeDetails? details;
}

/// The type-specific part of an alert's details.
sealed class AlertTypeDetails {
  const AlertTypeDetails();
}

final class SpeedAlertDetails extends AlertTypeDetails {
  const SpeedAlertDetails({
    required this.recordedSpeedKph,
    required this.speedLimitKph,
  });

  final num recordedSpeedKph;
  final num speedLimitKph;

  bool get isViolation => recordedSpeedKph > speedLimitKph;
}

enum SensorConditionOperator { greaterThan, lessThan }

final class SensorAlertDetails extends AlertTypeDetails {
  const SensorAlertDetails({
    required this.sensorName,
    required this.sensorType,
    required this.triggeredValue,
    required this.unit,
    required this.conditionOperator,
    required this.conditionValue,
  });

  final LocalizedText sensorName;

  /// The API's code, such as `TEMPERATURE`.
  final String sensorType;
  final num triggeredValue;
  final String unit;
  final SensorConditionOperator conditionOperator;
  final num conditionValue;
}

final class DowntimeAlertDetails extends AlertTypeDetails {
  const DowntimeAlertDetails({required this.durationMinutes});

  final int durationMinutes;
}
