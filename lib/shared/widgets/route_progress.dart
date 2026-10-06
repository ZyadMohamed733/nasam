import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_icons.dart';
import 'route_timeline_style.dart';

/// Renders a route timeline, with an optional interactive playback slider.
///
/// When [onProgressChanged] is provided, an invisible interactive slider is
/// layered over the same timeline used by tracking cards.
class RouteProgress extends StatelessWidget {
  const RouteProgress({
    super.key,
    required this.progress,
    this.markerAtEnd = false,
    this.color = RouteTimelineStyle.color,
    this.onProgressChanged,
  });

  final double progress;
  final bool markerAtEnd;
  final Color color;
  final ValueChanged<double>? onProgressChanged;

  @override
  Widget build(BuildContext context) {
    final textDirection = Directionality.of(context);
    final markerProgress = markerAtEnd ? 1.0 : progress.clamp(0.0, 1.0);
    final markerSize = RouteTimelineStyle.markerDiameter.r;
    final dotSize = RouteTimelineStyle.endDotDiameter.r;

    return SizedBox(
      height: markerSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PositionedDirectional(
            start: 0,
            end: 0,
            child: SizedBox(
              height: markerSize,
              child: CustomPaint(
                painter: _DashedLinePainter(
                  color: RouteTimelineStyle.color,
                  strokeWidth: 1.h,
                  dashWidth: 4.r,
                  dashSpace: 4.r,
                ),
              ),
            ),
          ),
          PositionedDirectional(
            start: 0,
            end: 0,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: FractionallySizedBox(
                widthFactor: markerProgress,
                alignment: AlignmentDirectional.centerStart,
                child: Container(
                  height: RouteTimelineStyle.lineThickness.h,
                  color: color,
                ),
              ),
            ),
          ),
          PositionedDirectional(
            start: 0,
            child: Container(
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
          PositionedDirectional(
            end: 0,
            child: Container(
              width: dotSize,
              height: dotSize,
              decoration: const BoxDecoration(
                color: RouteTimelineStyle.color,
                shape: BoxShape.circle,
              ),
            ),
          ),
          PositionedDirectional(
            start: dotSize,
            end: dotSize,
            top: 0,
            bottom: 0,
            child: Align(
              alignment: AlignmentDirectional(-1 + markerProgress * 2, 0),
              child: Container(
                width: markerSize,
                height: markerSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .12),
                  border: Border.all(
                    color: color.withValues(alpha: .4),
                    width: RouteTimelineStyle.markerBorderWidth.w,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Transform.flip(
                  flipX: textDirection == TextDirection.ltr,
                  child: SvgPicture.asset(
                    AppAssets.mapArrowLeft,
                    width: AppIconSize.medium.value.r,
                    height: AppIconSize.medium.value.r,
                    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                    excludeFromSemantics: true,
                  ),
                ),
              ),
            ),
          ),
          if (onProgressChanged case final onChanged?)
            Positioned.fill(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.transparent,
                  inactiveTrackColor: Colors.transparent,
                  disabledActiveTrackColor: Colors.transparent,
                  disabledInactiveTrackColor: Colors.transparent,
                  thumbColor: Colors.transparent,
                  overlayColor: Colors.transparent,
                  trackHeight: 0,
                  thumbShape: SliderComponentShape.noThumb,
                  overlayShape: SliderComponentShape.noOverlay,
                ),
                child: Slider(
                  value: markerProgress.toDouble(),
                  onChanged: onChanged,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
  });

  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final y = size.height / 2;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, y), Offset(x + dashWidth, y), paint);
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.dashWidth != dashWidth ||
      oldDelegate.dashSpace != dashSpace;
}
