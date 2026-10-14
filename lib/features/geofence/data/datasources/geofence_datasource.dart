import '../models/geofence_model.dart';
abstract interface class GeofenceDataSource {
  Future<List<GeofenceModel>> getGeofences();
  Future<GeofenceModel> getGeofence(String id);
  Future<GeofenceModel> save(GeofenceModel model, {required bool create});
  Future<void> delete(String id);
  Future<List<Map<String, dynamic>>> getAssetOptions();
}
