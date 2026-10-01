import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/localization/l10n/app_localizations.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../cubit/poi_import_cubit.dart';

/// TEMPORARY: the pre-redesign Confirm body, kept
/// working on the new state until each step is rebuilt. Deleted once
/// Confirm is.
class PoiImportLegacySteps extends StatelessWidget {
  const PoiImportLegacySteps({super.key, required this.state});

  final PoiImportState state;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final summary = switch (state.step) {
      PoiImportConfirmStep(:final summary) => summary,
      _ => null,
    };
    if (summary != null) {
      return Column(
        children: [
          Text(l.poiImportComplete),
          Text('${l.poiTotal}: ${summary.total}'),
          Text('${l.poiImported}: ${summary.imported}'),
          AppButton(
            label: l.poiShowPoints,
            variant: AppButtonVariant.tertiary,
            onPressed: () => context.pop(true),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}
