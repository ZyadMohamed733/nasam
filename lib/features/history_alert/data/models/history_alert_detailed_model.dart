class HistoryAlertDetailsModel {
  const HistoryAlertDetailsModel({
    required this.id,
    required this.title,
    required this.basicInfo,
    this.speedDetails,
  });

  final String id;
  final String title;
  final AlertBasicInfoModel basicInfo;

  /// Only present for speed alerts.
  final AlertSpeedDetailsModel? speedDetails;

  factory HistoryAlertDetailsModel.fromJson(Map<String, dynamic> json) {
    final speed = json['speedDetails'] as Map<String, dynamic>?;
    return HistoryAlertDetailsModel(
      id: json['id'] as String,
      title: json['title'] as String,
      basicInfo: AlertBasicInfoModel.fromJson(
        json['basicInfo'] as Map<String, dynamic>,
      ),
      speedDetails:
      speed == null ? null : AlertSpeedDetailsModel.fromJson(speed),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'basicInfo': basicInfo.toJson(),
    'speedDetails': speedDetails?.toJson(),
  };
}

class AlertBasicInfoModel {
  const AlertBasicInfoModel({
    required this.alertName,
    required this.assetName,
    required this.alertType,
    required this.alertTypeLabel,
    required this.timestamp,
    required this.location,
  });

  final String alertName;
  final String assetName;
  final String alertType;
  final String alertTypeLabel;
  final DateTime timestamp;
  final String location;

  factory AlertBasicInfoModel.fromJson(Map<String, dynamic> json) {
    return AlertBasicInfoModel(
      alertName: json['alertName'] as String,
      assetName: json['assetName'] as String,
      alertType: json['alertType'] as String,
      alertTypeLabel: json['alertTypeLabel'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      location: json['location'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'alertName': alertName,
    'assetName': assetName,
    'alertType': alertType,
    'alertTypeLabel': alertTypeLabel,
    'timestamp': timestamp.toIso8601String(),
    'location': location,
  };
}

class AlertSpeedDetailsModel {
  const AlertSpeedDetailsModel({
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

  factory AlertSpeedDetailsModel.fromJson(Map<String, dynamic> json) {
    return AlertSpeedDetailsModel(
      recordedSpeed: json['recordedSpeed'] as num,
      speedLimit: json['speedLimit'] as num,
      unit: json['unit'] as String,
      unitLabel: json['unitLabel'] as String,
      isViolation: json['isViolation'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
    'recordedSpeed': recordedSpeed,
    'speedLimit': speedLimit,
    'unit': unit,
    'unitLabel': unitLabel,
    'isViolation': isViolation,
  };
}