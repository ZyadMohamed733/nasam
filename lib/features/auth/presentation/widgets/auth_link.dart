import 'package:flutter/material.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';

/// The inline text actions the auth cards carry — "forgot your password",
/// "back to sign in", "resend the code".
///
/// Not an `AppButton` tertiary: those are 44 tall with button padding, because
/// they are buttons. These sit inline in a sentence's worth of space and the
/// design draws them as coloured text, so a button variant here would push the
/// card 44pt taller for a link.
class AuthLink extends StatelessWidget {
  const AuthLink({
    super.key,
    required this.onPressed,
    required this.label,
    this.trailingIcon,
  });

  final VoidCallback? onPressed;
  final String label;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final colour = onPressed == null
        ? context.semanticColors.textPlaceholder
        : context.semanticColors.secondary;

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: colour,
        padding: const EdgeInsets.symmetric(vertical: AppSizes.p4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: context.textTheme.labelLarge?.copyWith(color: colour),
          ),
          if (trailingIcon != null) ...[
            const SizedBox(width: AppSizes.p4),
            Icon(trailingIcon, size: AppIconSize.small.value),
          ],
        ],
      ),
    );
  }
}
