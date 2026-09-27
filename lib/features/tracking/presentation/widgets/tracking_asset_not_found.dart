import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/app_bar_widget.dart';

/// What a details or playback link shows when its id names no asset.
///
/// It goes home with `go`, not `pop`: a cold deep link to a bad id may have
/// nothing sensible to pop back to, and home is always a valid place to land.
/// It never redirects on its own, so there is no loop to fall into.
class TrackingAssetNotFound extends StatelessWidget {
  const TrackingAssetNotFound({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: NasamAppBar(
        showLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.screenPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 48,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: AppSizes.p16),
              Text(l.assetNotFound, textAlign: TextAlign.center),
              const SizedBox(height: AppSizes.p16),
              FilledButton(
                onPressed: () => context.go(AppRoutes.home),
                child: Text(l.backToHome),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
