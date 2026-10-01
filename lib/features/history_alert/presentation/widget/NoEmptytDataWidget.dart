import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nasam/core/constants/app_assets.dart';
import 'package:nasam/core/constants/app_colors.dart';
import 'package:nasam/core/constants/app_sizes.dart';


import '../../../../core/localization/l10n/app_localizations.dart';

class NoEmptyDataWidget extends StatelessWidget {
  const NoEmptyDataWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          SvgPicture.asset(
            AppAssets.alertNotification,
            width: AppSizes.iconXXl.w,
            height: AppSizes.iconXXl.h,

            excludeFromSemantics: true,
          ),
          SizedBox(height: AppSizes.p8),
          _buildTitle(l.alertsLogUnavailable, AppColors.neutralBlack, 18.sp),
          SizedBox(height: AppSizes.p4),
          _buildTitle(l.deviceAlertsEmpty, AppColors.neutral600, 13.sp),
        ],
      ),
    );
  }

  Widget _buildTitle(String title, Color textColor, double fontSize) {
    return Text(
      title,

      style: TextStyle(color: textColor, fontSize: fontSize,fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    );
  }
}
