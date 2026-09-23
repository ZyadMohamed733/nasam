import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key, this.isFullScreen = false, this.size});

  final bool isFullScreen;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final loader = Center(
      child: SizedBox(
        width: size ?? AppSizes.iconLg,
        height: size ?? AppSizes.iconLg,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );

    if (isFullScreen) {
      return Scaffold(
        backgroundColor: Theme.of(
          context,
        ).colorScheme.surfaceContainerLowest.withValues(alpha: 0.8),
        body: loader,
      );
    }

    return loader;
  }
}
