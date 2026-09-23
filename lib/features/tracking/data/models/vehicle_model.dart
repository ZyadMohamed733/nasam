/// Wire shape of one entry in `GET /tracking/vehicles`.
///
/// `status` stays the raw wire string, as in the auth models: turning it into
/// an enum is the mapper's job, so an unexpected value is caught at the one
/// boundary that knows what the domain accepts.
class VehicleModel {
  const VehicleModel({
    required this.id,
    required this.assetId,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.heading,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) => VehicleModel(
    id: json['id'] as String,
    assetId: json['assetId'] as String,
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    status: json['status'] as String,
    // Absent for a vehicle that has never reported a bearing.
    heading: (json['heading'] as num?)?.toDouble() ?? 0,
  );

  final String id;
  final String assetId;
  final double latitude;
  final double longitude;
  final String status;
  final double heading;
}
