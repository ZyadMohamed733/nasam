import '../models/asset_details_model.dart';
import '../models/notification_model.dart';
import '../models/playback_segment_model.dart';
import '../models/tracked_asset_model.dart';
import '../models/vehicle_model.dart';

/// The contract the repository depends on, in wire models.
///
/// Its own file so the repository imports the interface and nothing else.
/// Swapping the fixture for the real API is one binding: the class that
/// carries `@LazySingleton(as: TrackingDataSource)`.
abstract interface class TrackingDataSource {
  Future<List<VehicleModel>> getVehicles();
  Future<List<TrackedAssetModel>> getTrackedAssets();
  Future<AssetDetailsModel> getAssetDetails(String assetId);
  Future<List<NotificationModel>> getAssetNotifications(String assetId);
  Future<List<PlaybackSegmentModel>> getPlaybackSegments({
    required String assetId,
    required DateTime from,
    required DateTime to,
  });
}
