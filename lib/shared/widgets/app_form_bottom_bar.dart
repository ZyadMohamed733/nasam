import 'package:flutter/material.dart';

import '../../core/extensions/context_extensions.dart';
import '../../core/theme/app_text_styles.dart';
import 'app_button.dart';
import 'hit_target.dart';

/// A form's action bar (`647:7895`): 60 tall, 16 in from the sides and 8
/// from the top and bottom, the primary action filling the start and a
/// 99-wide cancel at the end, 8 apart. Above the bottom safe area.
///
/// A null [onPrimary] disables the primary action in the design's disabled
/// colour.
class AppFormBottomBar extends StatelessWidget {
  const AppFormBottomBar({
    super.key,
    required this.primaryLabel,
    required this.onPrimary,
    required this.cancelLabel,
    required this.onCancel,
    this.loading = false,
    this.cancelVariant = AppButtonVariant.secondary,
  });

  final String primaryLabel;
  final VoidCallback? onPrimary;
  final String cancelLabel;
  final VoidCallback? onCancel;
  final bool loading;

  /// The end action's look: an outline cancel (Upload, Create, Edit) or a
  /// text "previous" (`14:368`, Validation and Preview).
  final AppButtonVariant cancelVariant;

  static const double height = 60;
  static const double paddingH = 16;
  static const double paddingV = 8;
  static const double gap = 8;
  static const double buttonHeight = 44;
  static const double cancelWidth = 99;

  static const primaryKey = ValueKey('app-form-bottom-bar-primary');
  static const cancelKey = ValueKey('app-form-bottom-bar-cancel');

  @override
  Widget build(BuildContext context) {
    final label = AppTextStyles.bodyMR;
    return ColoredBox(
      color: context.semanticColors.pageBackground,
      child: SafeArea(
        top: false,
        child: HitTargetScope(
          child: SizedBox(
            height: height,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: paddingH,
                vertical: paddingV,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: HitTargetExtender(
                      child: AppButton(
                        key: primaryKey,
                        label: primaryLabel,
                        onPressed: onPrimary,
                        isLoading: loading,
                        height: buttonHeight,
                        labelStyle: label,
                      ),
                    ),
                  ),
                  const SizedBox(width: gap),
                  HitTargetExtender(
                    child: AppButton(
                      key: cancelKey,
                      label: cancelLabel,
                      onPressed: onCancel,
                      variant: cancelVariant,
                      width: cancelWidth,
                      height: buttonHeight,
                      labelStyle: label,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
