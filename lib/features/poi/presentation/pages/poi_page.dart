import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/map_icon_button.dart';
import '../../domain/entities/point_of_interest.dart';
import '../cubit/poi_cubit.dart';
import '../widgets/poi_bottom_sheet.dart';
import '../widgets/poi_delete_dialog.dart';
import '../widgets/poi_map.dart';
import '../widgets/poi_sheet_layout.dart';
import '../widgets/poi_summary.dart';

/// Home POI destination with a searchable, draggable list.
/// A route-owned PoiCubit supplies the data, just as it does for tracking.
class PoiPage extends StatefulWidget {
  const PoiPage({super.key, required this.openDrawer});

  final VoidCallback openDrawer;

  @override
  State<PoiPage> createState() => _PoiPageState();
}

class _PoiPageState extends State<PoiPage> {
  final _map = PoiMapController();
  final _sheet = DraggableScrollableController();
  final _search = TextEditingController();
  double _header = 180;
  MapType _mapType = MapType.normal;
  bool _exporting = false;
  double? _extent;
  double _min = .24, _max = .8;

  bool get _expanded => (_extent ?? _min) > (_min + _max) / 2;

  @override
  void dispose() {
    _sheet.dispose();
    _search.dispose();
    super.dispose();
  }

  void _toggle() {
    if (!_sheet.isAttached) return;
    _sheet.animateTo(
      _expanded ? _min : _max,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : Durations.short4,
      curve: Curves.easeOutCubic,
    );
  }

  void _select(PointOfInterest point) {
    context.read<PoiCubit>().select(point.id);
    _map.focus(point);
  }

  Future<void> _open(String route) async {
    await context.push(route);
    if (mounted) await context.read<PoiCubit>().load();
  }

  void _details(PointOfInterest point) {
    _select(point);
    _open(AppRoutes.poiDetails(point.id));
  }

  Future<void> _actions(PointOfInterest point) async {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final action = await showPoiBottomSheet<String>(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            dense: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: scheme.outlineVariant),
            ),
            leading: SvgPicture.asset(AppAssets.poiEdit, width: 16, height: 16),
            title: Text(l.poiEdit),
            onTap: () => Navigator.pop(context, 'edit'),
          ),
          const SizedBox(height: 8),
          ListTile(
            dense: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            tileColor: scheme.error.withValues(alpha: .06),
            iconColor: scheme.error,
            textColor: scheme.error,
            leading: SvgPicture.asset(
              AppAssets.poiDelete,
              width: 16,
              height: 16,
            ),
            title: Text(l.poiDelete),
            onTap: () => Navigator.pop(context, 'delete'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (action == 'edit') {
      await _open(AppRoutes.poiEdit(point.id));
      return;
    }
    if (action == 'delete' && await confirmPoiDelete(context) && mounted) {
      final deleted = await context.read<PoiCubit>().delete(point.id);
      if (mounted && !deleted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.errorGeneric)));
      }
    }
  }

  Future<void> _export() async {
    if (_exporting) return;
    setState(() => _exporting = true);
    final l = AppLocalizations.of(context)!;
    try {
      final saved = await context.read<PoiCubit>().export();
      if (mounted && saved) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.poiFileSaved)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.poiFileError)));
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: BlocBuilder<PoiCubit, PoiState>(
        builder: (context, state) => LayoutBuilder(
          builder: (context, constraints) {
            final height = constraints.maxHeight;
            if (height <= 0) return const SizedBox.shrink();
            _min =
                ((_header +
                            PoiSheetLayout.sheetBottomPadding +
                            MediaQuery.paddingOf(context).bottom) /
                        height)
                    .clamp(.1, .85);
            _max = (_min + .1).clamp(.8, 1.0);
            final bottom = (_extent ?? _min).clamp(_min, _max) * height;
            return Stack(
              children: [
                Positioned.fill(
                  child: PoiMap(
                    points: state.visiblePoints,
                    mapType: _mapType,
                    controller: _map,
                    bottomInset: bottom,
                    selectedId: state.selectedId,
                    onSelect: _details,
                  ),
                ),
                Positioned.fill(
                  bottom: bottom,
                  child: SafeArea(
                    bottom: false,
                    child: Stack(
                      children: [
                        PositionedDirectional(
                          top: 8,
                          start: 12,
                          child: MapIconButton(
                            asset: AppAssets.trackingMenu,
                            label: l.trackingMenu,
                            menu: true,
                            onTap: widget.openDrawer,
                          ),
                        ),
                        PositionedDirectional(
                          top: 8,
                          end: 12,
                          child: MapIconButton(
                            asset: AppAssets.mapNotification,
                            label: l.trackingNotifications,
                            // Pushed over Home, so back returns to this map.
                            onTap: () => context.push(AppRoutes.alertsLog),
                          ),
                        ),
                        PositionedDirectional(
                          top: 64,
                          bottom: 0,
                          end: 8,
                          child: Center(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  MapIconButton(
                                    asset: AppAssets.mapLayers,
                                    label: l.trackingLayers,
                                    onTap: () => setState(
                                      () =>
                                          _mapType = _mapType == MapType.normal
                                          ? MapType.hybrid
                                          : MapType.normal,
                                    ),
                                  ),
                                  MapIconButton(
                                    asset: AppAssets.mapZoomIn,
                                    label: l.trackingZoomIn,
                                    onTap: _map.zoomIn,
                                  ),
                                  MapIconButton(
                                    asset: AppAssets.mapZoomOut,
                                    label: l.trackingZoomOut,
                                    onTap: _map.zoomOut,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child:
                        NotificationListener<DraggableScrollableNotification>(
                          onNotification: (event) {
                            if (_extent != event.extent) {
                              setState(() => _extent = event.extent);
                            }
                            return false;
                          },
                          child: DraggableScrollableSheet(
                            controller: _sheet,
                            initialChildSize: _min,
                            minChildSize: _min,
                            maxChildSize: _max,
                            snap: true,
                            snapSizes: [_min, _max],
                            builder: (context, scrollController) => PoiSummary(
                              state: state,
                              scrollController: scrollController,
                              searchController: _search,
                              expanded: _expanded,
                              onToggle: _toggle,
                              onHeaderSize: (size) {
                                if (!mounted || size.height == _header) return;
                                setState(() {
                                  if ((_extent ?? _min) <= _min + .01) {
                                    _extent = null;
                                  }
                                  _header = size.height;
                                });
                              },
                              onSearch: (query) {
                                context.read<PoiCubit>().search(query);
                                if (!_expanded) _toggle();
                              },
                              onSelect: _details,
                              onActions: _actions,
                              onAdd: () => _open(AppRoutes.poiCreate),
                              onUpload: () => _open(AppRoutes.poiImport),
                              onDownload:
                                  _exporting || state.status != PoiStatus.loaded
                                  ? null
                                  : _export,
                              onRetry: context.read<PoiCubit>().load,
                            ),
                          ),
                        ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
