import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../shared/widgets/app_button.dart';
import 'poi_bottom_sheet.dart';

Future<bool> confirmPoiDelete(BuildContext context) async {
  final l = AppLocalizations.of(context)!;
  final theme = Theme.of(context);
  final error = theme.colorScheme.error;
  return await showPoiBottomSheet<bool>(
        context: context,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(AppAssets.poiDanger, width: 40, height: 40),
            const SizedBox(height: 8),
            Text(
              l.poiDeleteTitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: error,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Text(l.poiDeleteMessage, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: AppButton(
                    onPressed: () => Navigator.pop(context, true),
                    label: l.poiDelete,
                    primaryBackgroundColor: error,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppButton(
                    onPressed: () => Navigator.pop(context, false),
                    label: l.poiCancel,
                    variant: AppButtonVariant.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ) ??
      false;
}
