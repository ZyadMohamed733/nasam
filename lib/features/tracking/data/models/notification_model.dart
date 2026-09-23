/// Wire shape of one entry in `GET /tracking/assets/:id/notifications`.
class NotificationModel {
  const NotificationModel({
    required this.type,
    required this.date,
    required this.speedKph,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        type: json['type'] as String,
        date: DateTime.parse(json['date'] as String),
        speedKph: (json['speedKph'] as num?)?.toInt() ?? 0,
      );

  /// Raw wire value; see the mapper.
  final String type;
  final DateTime date;
  final int speedKph;
}
