import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/app_info_section.dart';
import '../../../../shared/widgets/app_map_preview.dart';
import '../../../../shared/widgets/app_outline_icon_button.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../../../shared/widgets/hit_target.dart';
import '../../domain/entities/point_of_interest.dart';
import '../cubit/poi_editor_cubit.dart';
import '../widgets/poi_icon.dart';
import '../widgets/poi_location_map.dart';
import 'poi_location_page.dart';

/// View POI (`647:7898`): the header with the point's name and an edit
/// button, a 112-tall map, then its information in four sections
/// (`553:4064`): basic, location, icon and notes, 8 apart.
///
/// Deleting is on the list's actions sheet; the design has no delete here.
class PoiDetailsPage extends StatelessWidget {
  const PoiDetailsPage({super.key, required this.pointId});
  final String pointId;

  static const editKey = ValueKey('poi-details-edit');

  Future<void> _edit(BuildContext context) async {
    await context.push(AppRoutes.poiEdit(pointId));
    if (context.mounted) await context.read<PoiEditorCubit>().load(pointId);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final s = context.semanticColors;
    return BlocBuilder<PoiEditorCubit, PoiEditorState>(
      builder: (context, state) {
        final point = state.point;
        return Scaffold(
          backgroundColor: s.pageBackground,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                AppPageHeader(
                  title: point?.name ?? l.poiDetails,
                  subtitle: l.poiDetails,
                  trailing: point == null
                      ? null
                      : HitTargetExtender(
                          child: AppOutlineIconButton(
                            key: editKey,
                            tooltip: l.poiEdit,
                            onPressed: state.busy ? null : () => _edit(context),
                            icon: SvgPicture.asset(
                              AppAssets.poiEdit,
                              width: AppSizes.iconMd,
                              height: AppSizes.iconMd,
                              colorFilter: ColorFilter.mode(
                                s.actionIcon,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                ),
                Expanded(
                  child: point == null
                      ? Center(
                          child: state.status == PoiEditorStatus.failure
                              ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      state.failure?.code == '404'
                                          ? l.poiNotFound
                                          : l.errorGeneric,
                                    ),
                                    TextButton(
                                      onPressed: () => context
                                          .read<PoiEditorCubit>()
                                          .load(pointId),
                                      child: Text(l.retry),
                                    ),
                                  ],
                                )
                              : const CircularProgressIndicator(),
                        )
                      : _Details(point: point),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// The view's measurements beyond the shared components' (`553:4064`).
abstract final class PoiViewLayout {
  static const double gutter = 16;
  static const double maxWidth = 600;
  static const double mapHeight = 112;
  static const double sectionGap = 8;
  static const double valueGap = 10;
  static const double iconInset = 8;
  static const double iconGap = 12;

  /// Below this screen width, longitude and latitude stack.
  static const double stackBelowWidth = 340;

  static const mapKey = ValueKey('poi-view-map');
  static const nameKey = ValueKey('poi-view-name');
  static const longitudeKey = ValueKey('poi-view-longitude');
  static const latitudeKey = ValueKey('poi-view-latitude');
  static const iconKey = ValueKey('poi-view-icon');
  static const notesKey = ValueKey('poi-view-notes');
}

class _Details extends StatelessWidget {
  const _Details({required this.point});

  final PointOfInterest point;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final s = context.semanticColors;
    final location = LatLng(point.latitude, point.longitude);
    final stacked =
        MediaQuery.sizeOf(context).width < PoiViewLayout.stackBelowWidth;
    final longitude = AppInfoValue(
      key: PoiViewLayout.longitudeKey,
      label: l.poiLongitude,
      value: point.longitude.toStringAsFixed(6),
      valueDirection: TextDirection.ltr,
    );
    final latitude = AppInfoValue(
      key: PoiViewLayout.latitudeKey,
      label: l.poiLatitude,
      value: point.latitude.toStringAsFixed(6),
      valueDirection: TextDirection.ltr,
    );
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: PoiViewLayout.maxWidth),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            PoiViewLayout.gutter,
            0,
            PoiViewLayout.gutter,
            PoiViewLayout.gutter,
          ),
          children: [
            AppMapPreview(
              key: PoiViewLayout.mapKey,
              height: PoiViewLayout.mapHeight,
              fullscreenTooltip: l.poiShowOnMap,
              onFullscreen: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      PoiLocationPage(initial: location, readOnly: true),
                ),
              ),
              map: PoiLocationMap(
                point: location,
                preview: true,
                showMarker: false,
              ),
            ),
            const SizedBox(height: PoiViewLayout.sectionGap),
            AppInfoSection(
              title: l.poiBasicInfo,
              child: AppInfoValue(
                key: PoiViewLayout.nameKey,
                label: l.poiName,
                value: point.name,
              ),
            ),
            const SizedBox(height: PoiViewLayout.sectionGap),
            AppInfoSection(
              title: l.poiLocation,
              child: stacked
                  ? Column(
                      children: [
                        longitude,
                        const SizedBox(height: PoiViewLayout.valueGap),
                        latitude,
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(child: longitude),
                        const SizedBox(width: PoiViewLayout.valueGap),
                        Expanded(child: latitude),
                      ],
                    ),
            ),
            const SizedBox(height: PoiViewLayout.sectionGap),
            AppInfoSection(
              title: l.poiIcon,
              child: AppInfoValue(
                key: PoiViewLayout.iconKey,
                label: l.poiIcon,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: PoiViewLayout.iconInset,
                  ),
                  child: Row(
                    children: [
                      PoiIconImage(
                        icon: point.icon,
                        size: AppSizes.iconMd,
                        color: s.textColor,
                      ),
                      const SizedBox(width: PoiViewLayout.iconGap),
                      Flexible(
                        child: Text(
                          PoiIconStyle.label(point.icon, l),
                          style: context.textTheme.bodySmall?.copyWith(
                            color: s.textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: PoiViewLayout.sectionGap),
            AppInfoSection(
              title: l.poiNotes,
              child: AppInfoValue(
                key: PoiViewLayout.notesKey,
                minHeight: AppInfoValue.notesHeight,
                value: point.notes.isEmpty ? '—' : point.notes,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
