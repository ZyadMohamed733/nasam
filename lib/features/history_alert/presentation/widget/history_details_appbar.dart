import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../shared/widgets/app_bar_widget.dart';

class HistoryDetailsAppbar extends StatelessWidget
    implements PreferredSizeWidget {
  const HistoryDetailsAppbar({super.key, required this.title, this.onBack});

  final String title;
  final VoidCallback? onBack;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;

    return NasamAppBar(
      centerTitle: false,
      titleWidget: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            textAlign: TextAlign.start,
            style: theme.textTheme.titleLarge,
          ),
          Text(
            l.alertDetailsSubtitle,
            textAlign: TextAlign.start,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.neutral600,
            ),
          ),
        ],
      ),
      leading: IconButton(
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        onPressed: onBack ?? () => context.pop(),
        icon: SvgPicture.asset(
          AppAssets.arrowBackButton,
          matchTextDirection: true,
          width: 8.w,
          height: 16.h,
        ),
      ),
    );
  }
}
