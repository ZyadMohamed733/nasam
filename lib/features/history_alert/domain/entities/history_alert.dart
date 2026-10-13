/// The kinds of fired alert Alert History lists. [geofence] is not in this
/// release of the API; [unknown] is any type the app does not know yet, so a
/// new backend type cannot fail the whole list.
enum AlertType { speed, sensor, geofence, downtime, unknown }

/// A display name the API sends in both languages.
class LocalizedText {
  const LocalizedText({required this.en, required this.ar});

  final String en;
  final String ar;

  /// The text for [languageCode]; anything but Arabic reads English.
  String of(String languageCode) => languageCode == 'ar' ? ar : en;

  @override
  bool operator ==(Object other) =>
      other is LocalizedText && other.en == en && other.ar == ar;

  @override
  int get hashCode => Object.hash(en, ar);
}

/// The vehicle an alert fired for.
class AlertAsset {
  const AlertAsset({required this.id, required this.code, required this.name});

  final String id;
  final String code;
  final LocalizedText name;

  @override
  bool operator ==(Object other) =>
      other is AlertAsset &&
      other.id == id &&
      other.code == code &&
      other.name == name;

  @override
  int get hashCode => Object.hash(id, code, name);
}

/// Where the vehicle was when the alert fired — not where it is now.
class AlertLocation {
  const AlertLocation({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  @override
  bool operator ==(Object other) =>
      other is AlertLocation &&
      other.latitude == latitude &&
      other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);
}

/// One alert that fired: a row of Alert History.
class HistoryAlertEntity {
  const HistoryAlertEntity({
    required this.id,
    required this.occurredAt,
    required this.asset,
    required this.alertType,
    required this.alertName,
    required this.triggeredValue,
    this.location,
  });

  final String id;

  /// UTC.
  final DateTime occurredAt;
  final AlertAsset asset;
  final AlertType alertType;
  final LocalizedText alertName;

  /// Display text for what triggered it, such as "108 km/h".
  final LocalizedText triggeredValue;

  /// Null when the position is not known.
  final AlertLocation? location;

  @override
  bool operator ==(Object other) =>
      other is HistoryAlertEntity &&
      other.id == id &&
      other.occurredAt == occurredAt &&
      other.asset == asset &&
      other.alertType == alertType &&
      other.alertName == alertName &&
      other.triggeredValue == triggeredValue &&
      other.location == location;

  @override
  int get hashCode => Object.hash(
    id,
    occurredAt,
    asset,
    alertType,
    alertName,
    triggeredValue,
    location,
  );
}
