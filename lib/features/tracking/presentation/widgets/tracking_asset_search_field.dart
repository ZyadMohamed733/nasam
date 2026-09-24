import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/localization/l10n/app_localizations.dart';

/// The fleet sheet's search box. Sized with ScreenUtil throughout, and not
/// given a fixed height: at a large text scale the text needs the room.
class TrackingAssetSearchField extends StatelessWidget {
  const TrackingAssetSearchField({
    super.key,
    this.controller,
    this.focusNode,
    this.onChanged,
  });

  /// Owned by the host, so clearing the filters can clear the text too.
  final TextEditingController? controller;

  /// Owned by the host, so the drawer's search button can focus the field.
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.r),
      borderSide: BorderSide(color: scheme.outlineVariant),
    );
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      // Start, not right: typed text begins where the reader's eye does, in
      // both directions.
      textAlign: TextAlign.start,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: l.trackingSearch,
        prefixIcon: Icon(Icons.search, size: AppIconSize.medium.value.r),
        filled: true,
        fillColor: scheme.surface,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        border: border,
        enabledBorder: border,
      ),
    );
  }
}
