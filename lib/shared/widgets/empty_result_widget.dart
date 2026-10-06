import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_sizes.dart';
import 'app_button.dart';

enum EmptyResultType { playbackSegments, playbackRoute, alerts }

/// Shared presentation for a successful request that returned no results.
class EmptyResultWidget extends StatelessWidget {
  const EmptyResultWidget({
    super.key,
    required this.message,
    required this.type,
    this.subtitle,
    this.onRetry,
    this.retryLabel = 'Retry',
    this.imageHeight = 160,
    this.padding = const EdgeInsets.all(AppSizes.p24),
  });

  final String message;
  final EmptyResultType type;
  final String? subtitle;
  final VoidCallback? onRetry;
  final String retryLabel;
  final double imageHeight;
  final EdgeInsetsGeometry padding;

  String get _image => switch (type) {
    EmptyResultType.playbackSegments => AppAssets.emptyPlaybackSegments,
    EmptyResultType.playbackRoute => AppAssets.emptyPlaybackRoute,
    EmptyResultType.alerts => AppAssets.alertNotification,
  };

  @override
  Widget build(BuildContext context) {
    final image = _image;
    return Padding(
      padding: padding,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              image,
              height: imageHeight,
              fit: BoxFit.contain,
              excludeFromSemantics: true,
            ),
            const SizedBox(height: AppSizes.p16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSizes.p4),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: AppSizes.p16),
              AppButton(
                width: 270,
                onPressed: onRetry,
                label: retryLabel,
                variant: AppButtonVariant.primary,
                primaryBackgroundColor: const Color(0xFFE24E6F),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
