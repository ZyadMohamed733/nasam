import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';

class HistoryDetailsRow {
  const HistoryDetailsRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;
}

class HistoryDetailsCard extends StatelessWidget {
  const HistoryDetailsCard({
    super.key,
    required this.title,
    required this.rows,
  });

  final String title;
  final List<HistoryDetailsRow> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textDirection = Localizations.localeOf(context).languageCode == 'ar'
        ? ui.TextDirection.rtl
        : ui.TextDirection.ltr;
    final textAlignment = textDirection == ui.TextDirection.rtl
        ? TextAlign.right
        : TextAlign.left;

    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.neutral100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.only(bottom: 8.h, end: 2.w),
            child: Text(
              title,
              textDirection: textDirection,
              textAlign: textAlignment,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          for (var index = 0; index < rows.length; index++) ...[
            if (index > 0) SizedBox(height: 5.h),
            _HistoryDetailsRowTile(
              row: rows[index],
              textDirection: textDirection,
              textAlignment: textAlignment,
            ),
          ],
        ],
      ),
    );
  }
}

class _HistoryDetailsRowTile extends StatelessWidget {
  const _HistoryDetailsRowTile({
    required this.row,
    required this.textDirection,
    required this.textAlignment,
  });

  final HistoryDetailsRow row;
  final ui.TextDirection textDirection;
  final TextAlign textAlignment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(10.w, 8.h, 10.w, 8.h),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(9.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 10.h),
          Text(
            row.label,
            textDirection: textDirection,
            textAlign: textAlignment,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.neutral600,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            row.value,
            textDirection: textDirection,
            textAlign: textAlignment,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: row.valueColor ?? AppColors.neutralBlack,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }
}
