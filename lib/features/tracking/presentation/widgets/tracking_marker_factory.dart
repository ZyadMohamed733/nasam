import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_icons.dart';

/// A marker bitmap could not be produced. The map shows a default pin for
/// that vehicle instead, and the next refresh tries again.
class MarkerDrawException implements Exception {
  const MarkerDrawException(this.message);

  final String message;

  @override
  String toString() => 'MarkerDrawException: $message';
}

/// Draws the map's marker bitmaps and keeps the recent ones.
///
/// One factory belongs to one map style — locale, text direction, colours
/// and pixel ratio — and is replaced when any of those change, so nothing in
/// the cache key needs to say which style it was drawn in.
class TrackingMarkerFactory {
  TrackingMarkerFactory({
    required this.pixelRatio,
    this.capacity = defaultCapacity,
    Future<PictureInfo> Function()? loadArrow,
  }) : _loadArrow = loadArrow ?? _loadArrowAsset;

  /// Bitmaps are rasterised at this many pixels per logical pixel: the
  /// device's, so they are sharp without being oversized on a 2x screen.
  final double pixelRatio;

  /// Most bitmaps kept at once; the least recently used go first. A fleet
  /// times sixteen headings times a few labels would otherwise grow without
  /// bound over a long session.
  final int capacity;

  static const int defaultCapacity = 256;

  /// Headings are drawn in this many steps (22.5° each). A vehicle turning
  /// by a degree does not need a new bitmap, and the cache stays small.
  static const int headingSteps = 16;

  /// The vehicle bitmap, in logical pixels, and where its arrow sits: the
  /// marker is anchored there, not at the label below it.
  static const Size vehicleSize = Size(112, 78);
  static const Offset _arrowCentre = Offset(56, 25);
  static const Offset vehicleAnchor = Offset(.5, 25 / 78);

  static const Size clusterSize = Size(44, 44);
  static const Offset clusterAnchor = Offset(.5, .5);

  final Future<PictureInfo> Function() _loadArrow;

  /// Insertion-ordered, so the first key is the least recently used.
  final _cache = <String, Future<BitmapDescriptor>>{};
  Future<PictureInfo>? _arrow;
  bool _disposed = false;

  @visibleForTesting
  int get cacheSize => _cache.length;

  /// [heading] rounded to the nearest of [headingSteps] directions, in
  /// degrees within [0, 360). A missing heading (NaN or infinite from the feed) points north.
  static double quantizeHeading(double heading) {
    if (!heading.isFinite) return 0;
    const step = 360 / headingSteps;
    final normalised = heading % 360; // Dart's % is never negative here.
    return (normalised / step).round() % headingSteps * step;
  }

  Future<BitmapDescriptor> cluster(int count, Color color) => _cached(
    'cluster:$count:${color.toARGB32()}',
    () => _draw(clusterSize, (canvas) async {
      final centre = clusterSize.center(Offset.zero);
      canvas.drawCircle(centre, 20, Paint()..color = color);
      _text(
        canvas,
        '$count',
        const Offset(0, 11),
        clusterSize.width,
        Colors.white,
        AppIconSize.small.value,
      );
    }),
  );

  Future<BitmapDescriptor> vehicle({
    required String label,
    required Color color,
    required double heading,
    required TextDirection direction,
  }) {
    final drawn = quantizeHeading(heading);
    return _cached(
      'vehicle:$label:${color.toARGB32()}:$drawn:${direction.name}',
      () => _draw(vehicleSize, (canvas) async {
        final arrow = await _arrowPicture();
        final fill = Paint()..color = color.withValues(alpha: .18);
        final stroke = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;
        canvas.drawCircle(_arrowCentre, 20, fill);
        canvas.drawCircle(_arrowCentre, 20, stroke);
        final icon = AppIconSize.medium.value;
        canvas
          ..save()
          ..translate(_arrowCentre.dx, _arrowCentre.dy)
          ..rotate(drawn * math.pi / 180)
          ..translate(-icon / 2, -icon / 2)
          ..saveLayer(
            Rect.fromLTWH(0, 0, icon, icon),
            Paint()..colorFilter = ColorFilter.mode(color, BlendMode.srcIn),
          )
          ..drawPicture(arrow.picture)
          ..restore()
          ..restore();
        canvas.drawCircle(const Offset(72, 10), 4.5, Paint()..color = color);
        canvas.drawCircle(const Offset(72, 10), 4.5, stroke);
        final rect = RRect.fromRectAndRadius(
          const Rect.fromLTWH(2, 49, 108, 22),
          const Radius.circular(4),
        );
        canvas.drawRRect(rect, fill);
        canvas.drawRRect(rect, stroke);
        _text(canvas, label, const Offset(5, 53), 102, color, 10, direction);
      }),
    );
  }

  /// Releases the decoded arrow. Draws still waiting on it fail with a
  /// [MarkerDrawException] rather than drawing a disposed picture.
  void dispose() {
    _disposed = true;
    final arrow = _arrow;
    _arrow = null;
    arrow?.then((info) => info.picture.dispose(), onError: (_) {});
    _cache.clear();
  }

  /// Serves [key] from the cache, most recently used last, drawing it on a
  /// miss. A failed draw is removed rather than kept: the next request tries
  /// again instead of getting the same failure for the life of the map.
  Future<BitmapDescriptor> _cached(
    String key,
    Future<BitmapDescriptor> Function() draw,
  ) {
    final hit = _cache.remove(key);
    if (hit != null) {
      _cache[key] = hit;
      return hit;
    }
    late final Future<BitmapDescriptor> future;
    future = draw().catchError((Object error, StackTrace stack) {
      if (identical(_cache[key], future)) _cache.remove(key);
      Error.throwWithStackTrace(
        error is MarkerDrawException
            ? error
            : MarkerDrawException('$key: $error'),
        stack,
      );
    });
    _cache[key] = future;
    while (_cache.length > capacity) {
      _cache.remove(_cache.keys.first);
    }
    return future;
  }

  /// The arrow artwork, decoded once for every bitmap this factory draws. A
  /// failed decode is not kept, so a later draw tries again.
  Future<PictureInfo> _arrowPicture() async {
    if (_disposed) throw const MarkerDrawException('factory disposed');
    final pending = _arrow ??= _loadArrow();
    try {
      final info = await pending;
      if (_disposed) throw const MarkerDrawException('factory disposed');
      return info;
    } catch (_) {
      if (identical(_arrow, pending)) _arrow = null;
      rethrow;
    }
  }

  static Future<PictureInfo> _loadArrowAsset() =>
      vg.loadPicture(const SvgAssetLoader(AppAssets.mapArrow), null);

  static void _text(
    Canvas canvas,
    String text,
    Offset offset,
    double width,
    Color color,
    double fontSize, [
    TextDirection direction = TextDirection.ltr,
  ]) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: 'Almarai',
          fontSize: fontSize,
          color: color,
        ),
      ),
      textDirection: direction,
      textAlign: TextAlign.center,
      maxLines: 1,
      ellipsis: '…',
    )..layout(minWidth: width, maxWidth: width);
    painter.paint(canvas, offset);
    painter.dispose();
  }

  Future<BitmapDescriptor> _draw(
    Size size,
    Future<void> Function(Canvas) paint,
  ) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)..scale(pixelRatio);
    await paint(canvas);
    final picture = recorder.endRecording();
    final image = await picture.toImage(
      (size.width * pixelRatio).round(),
      (size.height * pixelRatio).round(),
    );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    picture.dispose();
    if (bytes == null) {
      throw const MarkerDrawException('the image could not be encoded');
    }
    return BitmapDescriptor.bytes(
      bytes.buffer.asUint8List(),
      width: size.width,
      height: size.height,
    );
  }
}
