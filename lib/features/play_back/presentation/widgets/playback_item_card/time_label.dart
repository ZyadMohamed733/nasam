import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/app_icons.dart';

//// Displays one segment timestamp, with its clock icon on the outer edge.
class TimeLabel extends StatelessWidget {
  const TimeLabel({
    required this.time,
    required this.date,
    required this.leading,
  });

  final String time;
  final String date;
  final bool leading;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      textDirection: leading ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (!leading)
          Icon(
            Icons.access_time,
            size: AppIconSize.extraSmall.value.r,
            color: scheme.onSurfaceVariant,
          ),
        if (!leading) SizedBox(width: 3.w),
        Flexible(
          child: Text(
            '$time · $date',
            textAlign: leading ? TextAlign.right : TextAlign.left,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(fontSize: 9.sp),
          ),
        ),
        if (leading) SizedBox(width: 3.w),
        if (leading)
          Icon(
            Icons.access_time,
            size: AppIconSize.extraSmall.value.r,
            color: scheme.onSurfaceVariant,
          ),
      ],
    );
  }
}