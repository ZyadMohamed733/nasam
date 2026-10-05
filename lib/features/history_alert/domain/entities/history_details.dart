import 'history_alert.dart';

class HistoryAlertDetailsEntity {
  const HistoryAlertDetailsEntity({
    required this.id,
    required this.title,
    required this.basicInfo,
    this.speedDetails,
  });

  final String id;
  final String title;
  final AlertBasicInfoEntity basicInfo;

  /// Only present for speed alerts.
  final AlertSpeedDetailsEntity? speedDetails;
}

class AlertBasicInfoEntity {
  const AlertBasicInfoEntity({
    required this.alertName,
    required this.assetName,
    required this.alertType,
    required this.alertTypeLabel,
    required this.timestamp,
    required this.location,
  });

  final String alertName;
  final String assetName;
  final AlertType alertType;
  final String alertTypeLabel;
  final DateTime timestamp;
  final String location;
}

class AlertSpeedDetailsEntity {
  const AlertSpeedDetailsEntity({
    required this.recordedSpeed,
    required this.speedLimit,
    required this.unit,
    required this.unitLabel,
    required this.isViolation,
  });

  final num recordedSpeed;
  final num speedLimit;
  final String unit;
  final String unitLabel;
  final bool isViolation;
}