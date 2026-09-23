import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TrackingVehicleDetailsList extends StatelessWidget {
  const TrackingVehicleDetailsList({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: EdgeInsets.all(12.w),
    itemCount: children.length,
    separatorBuilder: (context, index) => SizedBox(height: 8.h),
    itemBuilder: (context, index) => children[index],
  );
}
