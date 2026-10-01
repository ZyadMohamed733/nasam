class HistoryAlertModel {
  const HistoryAlertModel({
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
  final String alertType;
  final String alertTypeLabel;
  final String assetName;

  /// Null for alerts that have no value (e.g. geofence).
  final num? value;
  final String? unit;
  final num? speedLimit;
  final String valueLabel;
  final DateTime timestamp;
  final String location;

  factory HistoryAlertModel.fromJson(Map<String, dynamic> json) {
    return HistoryAlertModel(
      id: json['id'] as String,
      title: json['title'] as String,
      alertType: json['alertType'] as String,
      alertTypeLabel: json['alertTypeLabel'] as String,
      assetName: json['assetName'] as String,
      value: json['value'] as num?,
      unit: json['unit'] as String?,
      speedLimit: json['speedLimit'] as num?,
      valueLabel: json['valueLabel'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      location: json['location'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'alertType': alertType,
    'alertTypeLabel': alertTypeLabel,
    'assetName': assetName,
    'value': value,
    'unit': unit,
    'speedLimit': speedLimit,
    'valueLabel': valueLabel,
    'timestamp': timestamp.toIso8601String(),
    'location': location,
  };
}
