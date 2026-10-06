import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/errors/failures.dart';
import 'app_button.dart';

enum ErrorType {
  unknown,
  network,
  server,
  timeout,
  unauthorized,
  rateLimit,
  malformedPayload,
}

class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.retryLabel = 'Retry',
    this.type = ErrorType.unknown,
    this.imageAsset,
    this.imageHeight = 160,
  });

  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;
  final ErrorType type;

  /// Overrides the artwork selected by [type]. Supports bundled PNG and SVG.
  final String? imageAsset;
  final double imageHeight;

  static ErrorType typeForFailure(Failure failure) => switch (failure) {
    NetworkFailure() => ErrorType.network,
    ServerFailure() => ErrorType.server,
    TimeoutFailure() => ErrorType.timeout,
    AuthFailure() => ErrorType.unauthorized,
    RateLimitFailure() => ErrorType.rateLimit,
    UnknownFailure(:final message) when message.contains('FormatException') =>
      ErrorType.malformedPayload,
    _ => ErrorType.unknown,
  };

  String get _resolvedImage =>
      imageAsset ??
      switch (type) {
        ErrorType.unknown => AppAssets.errorUnknown,
        ErrorType.network => AppAssets.noInternet,
        ErrorType.server => AppAssets.errorServer,
        ErrorType.timeout => AppAssets.errorTimeout,
        ErrorType.unauthorized => AppAssets.errorUnauthorized,
        ErrorType.rateLimit => AppAssets.errorRateLimit,
        ErrorType.malformedPayload => AppAssets.errorMalformedPayload,
      };

  @override
  Widget build(BuildContext context) {
    final image = _resolvedImage;
    return Padding(
      padding: const EdgeInsets.all(AppSizes.p24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (image.toLowerCase().endsWith('.svg'))
              SvgPicture.asset(
                image,
                height: imageHeight,
                fit: BoxFit.contain,
                excludeFromSemantics: true,
              )
            else
              Image.asset(
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
            if (onRetry != null) ...[
              const SizedBox(height: AppSizes.p24),
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
