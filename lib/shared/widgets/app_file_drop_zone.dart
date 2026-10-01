import 'package:flutter/material.dart';

import '../../core/extensions/context_extensions.dart';
import '../../core/theme/app_component_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'app_button.dart';
import 'app_dashed_box.dart';

/// The file picker's target (`561:5443`): a white card holding a dashed
/// zone with the instruction, the format hint and a browse button. The whole
/// zone opens the picker, not only the button.
class AppFileDropZone extends StatelessWidget {
  const AppFileDropZone({
    super.key,
    required this.title,
    required this.hint,
    required this.browseLabel,
    required this.onBrowse,
    this.loading = false,
  });

  final String title;
  final String hint;
  final String browseLabel;
  final VoidCallback? onBrowse;
  final bool loading;

  static const double radius = 14;
  static const EdgeInsets cardPadding = EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 16,
  );
  static const EdgeInsets zonePadding = EdgeInsets.symmetric(
    horizontal: 32,
    vertical: 26,
  );
  static const double contentPadding = 8;
  static const double titleTop = 8;
  static const double hintTop = 4;
  static const double gap = 12;
  static const double dash = 3.2;
  static const double dashGap = 1.6;
  static const Size button = Size(132, 40);

  @override
  Widget build(BuildContext context) {
    final s = context.semanticColors;
    final colors = AppComponentColors.of(context);
    final shape = BorderRadius.circular(radius);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: s.containerBackground,
        borderRadius: shape,
        border: Border.all(color: s.containerBorder),
        boxShadow: [
          BoxShadow(
            color: colors.elevationShadow,
            offset: const Offset(0, 1),
            blurRadius: 2,
            spreadRadius: -1,
          ),
          BoxShadow(
            color: colors.elevationShadow,
            offset: const Offset(0, 1),
            blurRadius: 3,
          ),
        ],
      ),
      child: Padding(
        padding: cardPadding,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onBrowse,
            borderRadius: shape,
            excludeFromSemantics: true,
            child: AppDashedBox(
              color: colors.dropZoneBorder,
              fill: colors.dropZoneFill,
              dash: dash,
              gap: dashGap,
              radius: radius,
              padding: zonePadding,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: contentPadding),
                child: Column(
                  children: [
                    const SizedBox(height: titleTop),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMM.copyWith(
                        color: colors.dropZoneTitle,
                      ),
                    ),
                    const SizedBox(height: hintTop),
                    Text(
                      hint,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySR.copyWith(
                        color: colors.dropZoneHint,
                      ),
                    ),
                    const SizedBox(height: gap),
                    AppButton(
                      label: browseLabel,
                      icon: Icons.add,
                      variant: AppButtonVariant.secondary,
                      width: button.width,
                      height: button.height,
                      isLoading: loading,
                      labelStyle: AppTextStyles.bodySR20,
                      onPressed: onBrowse,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
