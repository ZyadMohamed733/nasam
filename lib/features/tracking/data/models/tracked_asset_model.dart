/// Wire shape of one entry in `GET /tracking/assets`.
class TrackedAssetModel {
  const TrackedAssetModel({
    required this.id,
    required this.code,
    required this.name,
    required this.status,
    required this.assignedPerson,
    required this.routeProgress,
    this.statusDurationSeconds,
  });

  factory TrackedAssetModel.fromJson(Map<String, dynamic> json) =>
      TrackedAssetModel(
        id: json['id'] as String,
        code: json['code'] as String,
        name: json['name'] as String,
        status: json['status'] as String,
        assignedPerson: json['assignedPerson'] as String? ?? '',
        routeProgress: (json['routeProgress'] as num?)?.toDouble() ?? 0,
        statusDurationSeconds: (json['statusDurationSeconds'] as num?)?.toInt(),
      );

  final String id;
  final String code;
  final String name;
  final String status;
  final String assignedPerson;
  final double routeProgress;

  /// Seconds in the current status. Optional in the contract.
  final int? statusDurationSeconds;
}
