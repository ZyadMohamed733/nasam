class GeofenceModel {
  const GeofenceModel(this.json);
  final Map<String, dynamic> json;
  String get id => json['id'] as String;
  factory GeofenceModel.fromJson(Map<String, dynamic> json) => GeofenceModel(Map.unmodifiable(json));
  Map<String, dynamic> toJson() => Map.of(json);
}
