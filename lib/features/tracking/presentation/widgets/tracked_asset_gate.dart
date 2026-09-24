import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/l10n/app_localizations.dart';
import '../../domain/entities/tracked_asset.dart';
import '../cubit/tracked_asset_cubit.dart';
import 'tracking_asset_not_found.dart';

/// Resolves the asset an id-only screen was opened for, then builds the
/// screen with it.
///
/// The details and playback screens are both reachable by a link that carries
/// only an id. This is the one place that decides what they show before the
/// asset is known: a spinner, the not-found screen for an id that names
/// nothing, or an error with retry when the lookup itself failed.
class TrackedAssetGate extends StatelessWidget {
  const TrackedAssetGate({
    super.key,
    required this.assetId,
    required this.builder,
  });

  final String assetId;
  final Widget Function(BuildContext context, TrackedAsset asset) builder;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrackedAssetCubit, TrackedAssetState>(
      builder: (context, state) => switch (state) {
        TrackedAssetLoaded(:final asset) => builder(context, asset),
        TrackedAssetNotFound() => const TrackingAssetNotFound(),
        TrackedAssetFailure() => Scaffold(
          appBar: AppBar(),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(AppLocalizations.of(context)!.errorGeneric),
                TextButton(
                  onPressed: () =>
                      context.read<TrackedAssetCubit>().load(assetId),
                  child: Text(AppLocalizations.of(context)!.retry),
                ),
              ],
            ),
          ),
        ),
        TrackedAssetLoading() => Scaffold(
          appBar: AppBar(),
          body: const Center(child: CircularProgressIndicator()),
        ),
      },
    );
  }
}
