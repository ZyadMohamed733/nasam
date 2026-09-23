import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/app_icons.dart';

class PlaybackStartButton extends StatelessWidget {
  const PlaybackStartButton({
    super.key,
    required this.playing,
    required this.label,
    required this.onPressed,
  });

  final bool playing;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 42.h,
    child: FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(playing ? Icons.pause : Icons.play_arrow, size: AppIconSize.medium.value.r),
      label: Text(label, style: TextStyle(fontSize: 13.sp)),
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    ),
  );
}
