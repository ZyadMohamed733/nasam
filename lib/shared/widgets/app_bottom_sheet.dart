import 'package:flutter/material.dart';
import '../../core/constants/app_sizes.dart';

class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    super.key,
    required this.child,
    this.showDragHandle = true,
  });

  final Widget child;
  final bool showDragHandle;

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    bool showDragHandle = true,
    bool isDismissible = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.r24)),
      ),
      builder: (context) =>
          AppBottomSheet(showDragHandle: showDragHandle, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDragHandle) ...[
            const SizedBox(height: AppSizes.p12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(AppSizes.r4),
              ),
            ),
          ],
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.p24),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
