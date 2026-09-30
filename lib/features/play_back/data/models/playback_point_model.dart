class PlaybackPointModel {
  const PlaybackPointModel({
    required this.latitude,
    required this.longitude,
    required this.recordedAt,
    required this.headingDegrees,
    required this.speedKph,
    required this.distanceOdometerKm,
    required this.isMoving,
    required this.engineOn,
    required this.locationEn,
    required this.locationAr,
    required this.fuelLevelPercent,
    required this.humidityPercent,
    required this.temperatureCelsius,
    required this.weightKg,
  });
  factory PlaybackPointModel.fromJson(Map<String, dynamic> json) =>
      PlaybackPointModel(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        recordedAt: DateTime.parse(json['recordedAt'] as String),
        headingDegrees: (json['headingDegrees'] as num? ?? 0).toDouble(),
        speedKph: (json['speedKph'] as num? ?? 0).toDouble(),
        distanceOdometerKm: (json['distanceOdometerKm'] as num? ?? 0)
            .toDouble(),
        isMoving: json['isMoving'] as bool? ?? false,
        engineOn: json['engineOn'] as bool? ?? false,
        locationEn:
            (json['location'] as Map<String, dynamic>?)?['en'] as String? ?? '',
        locationAr:
            (json['location'] as Map<String, dynamic>?)?['ar'] as String? ?? '',
        fuelLevelPercent: (json['fuelLevelPercent'] as num? ?? 0).toInt(),
        humidityPercent: (json['humidityPercent'] as num? ?? 0).toInt(),
        temperatureCelsius: (json['temperatureCelsius'] as num? ?? 0).toInt(),
        weightKg: (json['weightKg'] as num? ?? 0).toDouble(),
      );
  final double latitude, longitude;
  final DateTime recordedAt;
  final double headingDegrees, speedKph;
  final double distanceOdometerKm;
  final bool isMoving, engineOn;
  final String locationEn, locationAr;
  final int fuelLevelPercent, humidityPercent, temperatureCelsius;
  final double weightKg;
}
