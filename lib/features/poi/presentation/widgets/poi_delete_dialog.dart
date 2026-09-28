import 'package:flutter/material.dart';
import '../../../../core/localization/l10n/app_localizations.dart';

Future<bool> confirmPoiDelete(BuildContext context) async {
  final l = AppLocalizations.of(context)!;
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          icon: Icon(
            Icons.warning_amber_rounded,
            color: Theme.of(context).colorScheme.error,
          ),
          title: Text(l.poiDeleteTitle),
          content: Text(l.poiDeleteMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l.poiCancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text(l.poiDelete),
            ),
          ],
        ),
      ) ??
      false;
}
