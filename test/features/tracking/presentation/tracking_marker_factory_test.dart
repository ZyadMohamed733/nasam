import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nasam/features/tracking/presentation/widgets/tracking_marker_factory.dart';

/// Stands in for the decoded SVG: the real one comes from the asset bundle.
class _Arrow implements PictureInfo {
  _Arrow() : picture = _blank();

  static ui.Picture _blank() {
    final recorder = ui.PictureRecorder();
    Canvas(recorder);
    return recorder.endRecording();
  }

  @override
  final ui.Picture picture;

  @override
  Size get size => const Size(20, 20);
}

/// Drawing is real here — plain tests run on real async, which
/// `Picture.toImage` needs — so these cover the bitmaps, not a stand-in.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const red = Color(0xFFE53935);

  var arrowLoads = 0;
  Future<PictureInfo> arrow() async {
    arrowLoads++;
    return _Arrow();
  }

  setUp(() => arrowLoads = 0);

  TrackingMarkerFactory factory({
    double pixelRatio = 1,
    int capacity = TrackingMarkerFactory.defaultCapacity,
    Future<PictureInfo> Function()? loadArrow,
  }) => TrackingMarkerFactory(
    pixelRatio: pixelRatio,
    capacity: capacity,
    loadArrow: loadArrow ?? arrow,
  );

  Future<BitmapDescriptor> vehicle(
    TrackingMarkerFactory f, {
    double heading = 0,
    String label = 'Asset 1',
  }) => f.vehicle(
    label: label,
    color: red,
    heading: heading,
    direction: TextDirection.ltr,
  );

  group('heading', () {
    test('rounds to the nearest of 16 directions', () {
      final q = TrackingMarkerFactory.quantizeHeading;
      expect(q(0), 0);
      expect(q(11), 0);
      expect(q(12), 22.5);
      expect(q(190), 180);
      expect(q(359), 0);
      expect(q(-10), 0);
      expect(q(-12), 337.5);
      expect(q(720 + 45), 45);
      expect(q(double.nan), 0);
    });

    test('headings in the same step share one bitmap', () async {
      final f = factory();
      expect(identical(vehicle(f, heading: 3), vehicle(f, heading: 8)), isTrue);
      expect(f.cacheSize, 1);
    });

    test('1000 distinct headings stay within the cap', () async {
      final f = factory();
      for (var i = 0; i < 1000; i++) {
        await vehicle(f, heading: i * 0.37);
        expect(f.cacheSize, lessThanOrEqualTo(f.capacity));
      }
      expect(f.cacheSize, TrackingMarkerFactory.headingSteps);
    });
  });

  group('cache', () {
    test('never holds more than its capacity', () async {
      final f = factory();
      for (var i = 0; i < 1000; i++) {
        await f.cluster(i, red);
        expect(f.cacheSize, lessThanOrEqualTo(f.capacity));
      }
      expect(f.cacheSize, f.capacity);
    });

    test('evicts the least recently used first', () async {
      final f = factory(capacity: 3);
      final first = f.cluster(1, red);
      await f.cluster(2, red);
      await f.cluster(3, red);
      await f.cluster(1, red); // touch: 2 is now the oldest
      await f.cluster(4, red);

      expect(identical(f.cluster(1, red), first), isTrue, reason: 'kept');
      expect(f.cacheSize, 3);
    });

    test('a failed draw is dropped, and the next request retries', () async {
      var attempt = 0;
      final f = factory(
        loadArrow: () async {
          if (attempt++ == 0) throw StateError('asset not ready');
          return _Arrow();
        },
      );

      await expectLater(vehicle(f), throwsA(isA<MarkerDrawException>()));
      expect(f.cacheSize, 0, reason: 'the failure is not cached');

      await expectLater(vehicle(f), completion(isA<BitmapDescriptor>()));
      expect(attempt, 2);
    });

    test('the arrow is decoded once for every bitmap', () async {
      final f = factory();
      for (var i = 0; i < 16; i++) {
        await vehicle(f, heading: i * 22.5, label: 'Asset $i');
      }
      expect(arrowLoads, 1);
    });

    test(
      'after dispose, draws fail cleanly rather than use a freed arrow',
      () async {
        final f = factory();
        await vehicle(f);
        f.dispose();
        await expectLater(
          vehicle(f, label: 'new'),
          throwsA(isA<MarkerDrawException>()),
        );
      },
    );
  });

  test('bitmaps are rasterised at the device pixel ratio', () async {
    Future<ui.Image> decode(BitmapDescriptor d) async {
      final bytes = (d as BytesMapBitmap).byteData;
      final codec = await ui.instantiateImageCodec(bytes);
      return (await codec.getNextFrame()).image;
    }

    final at2x = await decode(await vehicle(factory(pixelRatio: 2)));
    final at3x = await decode(await vehicle(factory(pixelRatio: 3)));

    expect(at2x.width, TrackingMarkerFactory.vehicleSize.width * 2);
    expect(at3x.height, TrackingMarkerFactory.vehicleSize.height * 3);
  });
}
