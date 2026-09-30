class PlaybackPoint {
  const PlaybackPoint({
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
  final double latitude;
  final double longitude;
  final DateTime recordedAt;
  final double headingDegrees;
  final double speedKph;
  final double distanceOdometerKm;
  final bool isMoving;
  final bool engineOn;
  final String locationEn;
  final String locationAr;
  final int fuelLevelPercent;
  final int humidityPercent;
  final int temperatureCelsius;
  final double weightKg;
}
