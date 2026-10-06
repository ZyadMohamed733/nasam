import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../core/utils/bidi.dart';
import '../../../../shared/widgets/app_bar_widget.dart';
import '../../../tracking/domain/entities/tracked_asset.dart';

class PlaybackAppbar extends StatelessWidget implements PreferredSizeWidget {
  final TrackedAsset asset;
  const PlaybackAppbar({super.key, required this.asset});

  @override
  Size get preferredSize => Size.fromHeight(64.h);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return NasamAppBar(
      showLeading: false,
      toolbarHeight: 64.h,
      centerTitle: false,
      leading: IconButton(
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        onPressed: () => context.pop(),
        icon: SvgPicture.asset(
          AppAssets.arrowBackButton,
          matchTextDirection: true,
          width: 8.r,
          height: 16.r,
        ),
      ),
      titleWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l.assetPlaybackTitle,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          Text(
            joinIsolated([asset.name, asset.code], ' · '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 10.sp,
            ),
          ),
        ],
      ),
    );
  }
}
