import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/localization/l10n/app_localizations.dart';
import '../../../../../core/utils/bidi.dart';
import '../../../../../shared/widgets/app_bar_widget.dart';
import '../../../../tracking/domain/entities/tracked_asset.dart';

class PlaybackMapAppbar  extends StatelessWidget
    implements PreferredSizeWidget {
  const PlaybackMapAppbar({super.key, required this.asset, this.onBack});

  final  TrackedAsset asset;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final assetCode = joinIsolated([
    asset.code,
     asset.name,
    ], ' · ');
    final scheme = Theme.of(context).colorScheme;
    return NasamAppBar(
      showLeading: false,
      leading: IconButton(
        onPressed: () => context.pop(),
        tooltip: l.playbackBack,
        icon: SvgPicture.asset(
          AppAssets.arrowBackButton,
          matchTextDirection: true,
          width: 8,
          height: 16,
        ),
      ),
      titleWidget: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l.assetPlaybackTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            assetCode,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
