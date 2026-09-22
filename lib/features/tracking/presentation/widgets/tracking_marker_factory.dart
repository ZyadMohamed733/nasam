import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/constants/app_assets.dart';

/// Cache belongs to a map/theme/locale, and is discarded when those change.
class TrackingMarkerFactory {
  final _cache = <String, Future<BitmapDescriptor>>{};

  Future<BitmapDescriptor> cluster(
    int count,
    Color color,
  ) => _cache.putIfAbsent(
    'cluster:$count:${color.toARGB32()}',
    () => _draw(const Size(44, 44), (canvas) async {
      canvas.drawCircle(const Offset(22, 22), 20, Paint()..color = color);
      _text(canvas, '$count', const Offset(0, 11), 44, Colors.white, 16);
    }),
  );

  Future<BitmapDescriptor> vehicle({
    required String label,
    required Color color,
    required double heading,
    required TextDirection direction,
  }) => _cache.putIfAbsent(
    '$label:${color.toARGB32()}:$heading:$direction',
    () => _draw(const Size(112, 78), (canvas) async {
      final fill = Paint()..color = color.withValues(alpha: .18);
      final stroke = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawCircle(const Offset(56, 25), 20, fill);
      canvas.drawCircle(const Offset(56, 25), 20, stroke);
      final arrow = await vg.loadPicture(
        const SvgAssetLoader(AppAssets.mapArrow),
        null,
      );
      canvas.save();
      canvas.translate(56, 25);
      canvas.rotate(heading * math.pi / 180);
      canvas.translate(-12, -12);
      canvas.saveLayer(
        const Rect.fromLTWH(0, 0, 24, 24),
        Paint()..colorFilter = ColorFilter.mode(color, BlendMode.srcIn),
      );
      canvas.drawPicture(arrow.picture);
      canvas.restore();
      canvas.restore();
      arrow.picture.dispose();
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

  static Future<BitmapDescriptor> _draw(
    Size size,
    Future<void> Function(Canvas) paint,
  ) async {
    const ratio = 3.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)..scale(ratio);
    await paint(canvas);
    final picture = recorder.endRecording();
    final image = await picture.toImage(
      (size.width * ratio).round(),
      (size.height * ratio).round(),
    );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    picture.dispose();
    return BitmapDescriptor.bytes(
      bytes!.buffer.asUint8List(),
      width: size.width,
      height: size.height,
    );
  }
}
