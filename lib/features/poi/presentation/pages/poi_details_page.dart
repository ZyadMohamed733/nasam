import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../cubit/poi_editor_cubit.dart';
import '../widgets/poi_delete_dialog.dart';
import '../widgets/poi_icon.dart';
import 'poi_location_page.dart';

class PoiDetailsPage extends StatelessWidget {
  const PoiDetailsPage({super.key, required this.pointId});
  final String pointId;
  Future<void> _delete(BuildContext context) async {
    final confirmed = await confirmPoiDelete(context);
    if (context.mounted && confirmed == true) {
      await context.read<PoiEditorCubit>().delete(pointId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return BlocConsumer<PoiEditorCubit, PoiEditorState>(
      listener: (context, state) {
        if (state.status == PoiEditorStatus.deleted) context.pop(true);
      },
      builder: (context, state) {
        final point = state.point;
        return Scaffold(
          appBar: AppBar(
            title: Text(point?.name ?? l.poiDetails),
            actions: [
              if (point != null)
                IconButton(
                  tooltip: l.poiEdit,
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: state.busy
                      ? null
                      : () async {
                          await context.push(AppRoutes.poiEdit(pointId));
                          if (context.mounted) {
                            await context.read<PoiEditorCubit>().load(pointId);
                          }
                        },
                ),
            ],
          ),
          body: point == null
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
                              onPressed: () =>
                                  context.read<PoiEditorCubit>().load(pointId),
                              child: Text(l.retry),
                            ),
                          ],
                        )
                      : const CircularProgressIndicator(),
                )
              : Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: ListView(
                      padding: const EdgeInsets.all(AppSizes.p16),
                      children: [
                        Text(
                          l.poiDetails,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: AppSizes.p12),
                        PoiLocationPreview(
                          point: LatLng(point.latitude, point.longitude),
                          onExpand: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => PoiLocationPage(
                                initial: LatLng(
                                  point.latitude,
                                  point.longitude,
                                ),
                                readOnly: true,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSizes.p12),
                        if (state.status == PoiEditorStatus.failure)
                          Padding(
                            padding: const EdgeInsets.all(AppSizes.p8),
                            child: Text(l.errorGeneric),
                          ),
                        _InfoCard(
                          label: l.poiBasicInfo,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                l.poiName,
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                              Text(
                                point.name,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ],
                          ),
                        ),
                        _InfoCard(
                          label: l.poiLocation,
                          child: Wrap(
                            spacing: 32,
                            runSpacing: 12,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(l.poiLatitude),
                                  SelectableText(
                                    point.latitude.toStringAsFixed(6),
                                    textDirection: TextDirection.ltr,
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(l.poiLongitude),
                                  SelectableText(
                                    point.longitude.toStringAsFixed(6),
                                    textDirection: TextDirection.ltr,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        _InfoCard(
                          label: l.poiIcon,
                          child: Row(
                            children: [
                              PoiIconImage(icon: point.icon),
                              const SizedBox(width: AppSizes.p8),
                              Text(PoiIconStyle.label(point.icon, l)),
                            ],
                          ),
                        ),
                        _InfoCard(
                          label: l.poiNotes,
                          child: Text(point.notes.isEmpty ? '—' : point.notes),
                        ),
                        AppButton(
                          label: l.poiDelete,
                          variant: AppButtonVariant.secondary,
                          isLoading: state.status == PoiEditorStatus.deleting,
                          onPressed: state.busy ? null : () => _delete(context),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.label, required this.child});
  final String label;
  final Widget child;
  @override
  Widget build(BuildContext context) => AppCard(
    margin: const EdgeInsets.only(bottom: AppSizes.p12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: AppSizes.p8),
        DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppSizes.r8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.p12),
            child: child,
          ),
        ),
      ],
    ),
  );
}
