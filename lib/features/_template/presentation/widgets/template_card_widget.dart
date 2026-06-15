import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../domain/entities/template_entity.dart';

class TemplateCardWidget extends StatelessWidget {
  const TemplateCardWidget({
    super.key,
    required this.entity,
    this.onTap,
  });

  final TemplateEntity entity;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entity.title,
            style: AppTextStyles.h3.copyWith(
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: AppSizes.p8.h),
          Text(
            entity.description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
