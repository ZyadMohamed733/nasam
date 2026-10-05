import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../domain/entities/history_alert.dart';

class NoSearchResultWidget extends StatelessWidget {
  const NoSearchResultWidget({
    super.key,
    required this.historyList,
    required this.onClearFilters,
  });

  final List<HistoryAlertEntity> historyList;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    if (historyList.isNotEmpty) return const SizedBox.shrink();

    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search, size: 52.r, color: AppColors.neutral300),
            SizedBox(height: 12.h),
            Text(
              l.alertsNoSearchResults,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.neutral700,
              ),
            ),
            SizedBox(height: 16.h),
            OutlinedButton(
              onPressed: onClearFilters,
              child: Text(l.trackingClearFilters),
            ),
          ],
        ),
      ),
    );
  }
}
