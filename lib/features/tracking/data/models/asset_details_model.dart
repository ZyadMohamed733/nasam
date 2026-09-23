/// Wire shape of `GET /tracking/assets/:id/details`.
///
/// Dates arrive as ISO-8601 strings and are parsed here, because a malformed
/// date is a malformed response — it should fail where the response is read,
/// not later in a widget that formats it.
class AssetDetailsModel {
  const AssetDetailsModel({
    required this.assetId,
    required this.name,
    required this.equipmentType,
    required this.companyName,
    required this.managerName,
    required this.address,
    required this.speedKph,
    required this.durationHours,
    required this.connectionMinutesAgo,
    required this.lastGpsAt,
    required this.distanceKm,
    required this.fuelPercent,
    required this.idleHours,
    required this.tankLevelPercent,
    required this.temperatureCelsius,
    required this.weightKg,
    required this.sensorCode,
    required this.sensorBatteryMillivolts,
    required this.sensorDistanceKm,
    required this.fuelUsagePercent,
    required this.doorOpen,
    required this.engineOn,
  });

  factory AssetDetailsModel.fromJson(Map<String, dynamic> json) =>
      AssetDetailsModel(
        assetId: json['assetId'] as String,
        name: json['name'] as String,
        equipmentType: json['equipmentType'] as String? ?? '',
        companyName: json['companyName'] as String? ?? '',
        managerName: json['managerName'] as String? ?? '',
        address: json['address'] as String? ?? '',
        speedKph: (json['speedKph'] as num).toInt(),
        durationHours: (json['durationHours'] as num).toInt(),
        connectionMinutesAgo: (json['connectionMinutesAgo'] as num).toInt(),
        lastGpsAt: DateTime.parse(json['lastGpsAt'] as String),
        distanceKm: (json['distanceKm'] as num).toDouble(),
        fuelPercent: (json['fuelPercent'] as num).toInt(),
        idleHours: (json['idleHours'] as num).toInt(),
        tankLevelPercent: (json['tankLevelPercent'] as num).toInt(),
        temperatureCelsius: (json['temperatureCelsius'] as num).toInt(),
        weightKg: (json['weightKg'] as num).toInt(),
        sensorCode: json['sensorCode'] as String? ?? '',
        sensorBatteryMillivolts: (json['sensorBatteryMillivolts'] as num)
            .toInt(),
        sensorDistanceKm: (json['sensorDistanceKm'] as num).toInt(),
        fuelUsagePercent: (json['fuelUsagePercent'] as num).toInt(),
        doorOpen: json['doorOpen'] as bool? ?? false,
        engineOn: json['engineOn'] as bool? ?? false,
      );

  final String assetId;
  final String name;
  final String equipmentType;
  final String companyName;
  final String managerName;
  final String address;
  final int speedKph;
  final int durationHours;
  final int connectionMinutesAgo;
  final DateTime lastGpsAt;
  final double distanceKm;
  final int fuelPercent;
  final int idleHours;
  final int tankLevelPercent;
  final int temperatureCelsius;
  final int weightKg;
  final String sensorCode;
  final int sensorBatteryMillivolts;
  final int sensorDistanceKm;
  final int fuelUsagePercent;
  final bool doorOpen;
  final bool engineOn;
}
