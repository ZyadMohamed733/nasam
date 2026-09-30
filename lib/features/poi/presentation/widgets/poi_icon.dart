import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../domain/entities/poi_draft.dart';

abstract final class PoiIconStyle {
  static String asset(PoiIcon icon) => switch (icon) {
    PoiIcon.location => AppAssets.poiPin,
    PoiIcon.fuel => AppAssets.poiFuel,
    PoiIcon.hospital => AppAssets.poiHospital,
    PoiIcon.library => AppAssets.poiLibrary,
  };
  static String label(PoiIcon icon, AppLocalizations l) => switch (icon) {
    PoiIcon.location => l.poiIconLocation,
    PoiIcon.fuel => l.poiFuel,
    PoiIcon.hospital => l.poiHospital,
    PoiIcon.library => l.poiLibrary,
  };
}

class PoiIconImage extends StatelessWidget {
  const PoiIconImage({
    super.key,
    required this.icon,
    this.color,
    this.size = 24,
  });
  final PoiIcon icon;
  final Color? color;
  final double size;
  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    PoiIconStyle.asset(icon),
    width: size,
    height: size,
    colorFilter: ColorFilter.mode(
      color ?? Theme.of(context).colorScheme.onSurface,
      BlendMode.srcIn,
    ),
  );
}
