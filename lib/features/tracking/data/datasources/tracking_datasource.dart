import '../models/asset_details_model.dart';
import '../models/notification_model.dart';
import '../models/tracked_asset_model.dart';
import '../models/vehicle_model.dart';

/// The contract the repository depends on, in wire models.
///
/// Its own file so the repository imports the interface and nothing else.
/// Swapping the fixture for the real API is one binding: the class that
/// is registered in tracking_dependencies.dart.
abstract interface class TrackingDataSource {
  Future<List<VehicleModel>> getVehicles();
  Future<List<TrackedAssetModel>> getTrackedAssets();

  /// One asset. A missing id is a `ServerException` with code '404', which is
  /// what the Dio exception mapper produces for a real 404.
  Future<TrackedAssetModel> getTrackedAsset(String assetId);
  Future<AssetDetailsModel> getAssetDetails(String assetId);
  Future<List<NotificationModel>> getAssetNotifications(String assetId);
}
