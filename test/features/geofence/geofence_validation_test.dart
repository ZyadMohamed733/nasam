import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/features/geofence/domain/entities/geofence.dart';
import 'package:nasam/features/geofence/domain/entities/geofence_draft.dart';
import 'package:nasam/features/geofence/domain/entities/geofence_validation.dart';

void main() {
  group('GeofenceValidator', () {
    test('requires a name, an asset, and a valid shape', () {
      expect(GeofenceValidator.validate(const GeofenceDraft()), [
        GeofenceIssue.nameRequired,
        GeofenceIssue.assetRequired,
        GeofenceIssue.shapeRequired,
      ]);
    });

    test('accepts a circle and an always active schedule', () {
      const draft = GeofenceDraft(
        name: 'Warehouse',
        assetIds: ['vehicle-1'],
        shape: CircleShape(GeoPoint(24.86, 46.40), 1000),
      );
      expect(GeofenceValidator.validate(draft), isEmpty);
    });

    test('requires three polygon vertices and a valid scheduled range', () {
      const draft = GeofenceDraft(
        name: 'Warehouse',
        assetIds: ['vehicle-1'],
        shape: PolygonShape([GeoPoint(24.8, 46.4), GeoPoint(24.9, 46.4)]),
        schedule: SpecificSchedule(
          {},
          TimeOfDayValue(17, 0),
          TimeOfDayValue(8, 0),
          true,
        ),
      );
      expect(GeofenceValidator.validate(draft), [
        GeofenceIssue.polygonNeedsThreePoints,
        GeofenceIssue.daysRequired,
        GeofenceIssue.invalidTimeRange,
      ]);
    });
  });
}
