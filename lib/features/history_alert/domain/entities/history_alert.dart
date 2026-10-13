enum AlertType {
  speed,
  sensor,
  geofence,
  downtime,
  unknown;

  static AlertType fromString(String value) {
    return AlertType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => AlertType.unknown,
    );
  }
}

class HistoryAlertEntity {
  const HistoryAlertEntity({
    required this.id,
    required this.title,
    required this.alertType,
    required this.alertTypeLabel,
    required this.assetName,
    required this.valueLabel,
    required this.timestamp,
    required this.location,
    this.value,
    this.unit,
    this.speedLimit,
  });

  final String id;
  final String title;
  final AlertType alertType;
  final String alertTypeLabel;
  final String assetName;

  /// Null for alerts that have no value (e.g. geofence).
  final num? value;
  final String? unit;
  final num? speedLimit;
  final String valueLabel;
  final DateTime timestamp;
  final String location;
}
