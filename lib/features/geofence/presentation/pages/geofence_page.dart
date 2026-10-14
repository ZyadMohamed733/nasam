import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../core/router/app_routes.dart';
import '../../domain/entities/geofence.dart';
import '../cubit/geofence_cubit.dart';
import '../map/geofence_map.dart';

class GeofencePage extends StatefulWidget {
  const GeofencePage({super.key, required this.openDrawer});

  final VoidCallback openDrawer;

  @override
  State<GeofencePage> createState() => _GeofencePageState();
}

class _GeofencePageState extends State<GeofencePage> {
  final _map = GeoFenceMapController(), _search = TextEditingController();
  final _sheet = DraggableScrollableController();
  double _extent = .28;
  MapType _mapType = MapType.normal;

  @override
  void initState() {
    super.initState();
    _sheet.addListener(_sheetChanged);
  }

  void _sheetChanged() {
    if (_sheet.isAttached && mounted) setState(() => _extent = _sheet.size);
  }

  @override
  void dispose() {
    _sheet.removeListener(_sheetChanged);
    _sheet.dispose();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      body: BlocBuilder<GeofenceCubit, GeofenceState>(
        builder: (context, state) => LayoutBuilder(
          builder: (context, c) {
            final height = c.maxHeight;
            final bottom = height * _extent;
            return Stack(
              children: [
                Positioned.fill(
                  child: GeofenceMap(
                    controller: _map,
                    geofences: state.geofences,
                    mapType: _mapType,
                    selectedId: state.selectedId,
                    bottomInset: bottom,
                    onSelect: (g) {
                      context.read<GeofenceCubit>().select(g.id);
                      context.push(AppRoutes.geofenceDetails(g.id));
                    },
                  ),
                ),
                PositionedDirectional(
                  top: MediaQuery.paddingOf(context).top + 8,
                  start: 12,
                  child: Column(
                    children: [
                      _MapButton(
                        icon: Icons.menu,
                        label: l.trackingMenu,
                        onTap: widget.openDrawer,
                      ),
                      const SizedBox(height: 8),
                      _MapButton(
                        icon: Icons.layers_outlined,
                        label: l.geofenceTitle,
                        onTap: () => setState(
                          () => _mapType = switch (_mapType) {
                            MapType.normal => MapType.hybrid,
                            MapType.hybrid => MapType.terrain,
                            _ => MapType.normal,
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      _MapButton(
                        icon: Icons.add,
                        label: l.geofenceNext,
                        onTap: () => _map.zoomIn(),
                      ),
                      const SizedBox(height: 8),
                      _MapButton(
                        icon: Icons.remove,
                        label: l.geofencePrevious,
                        onTap: () => _map.zoomOut(),
                      ),
                    ],
                  ),
                ),
                DraggableScrollableSheet(
                  controller: _sheet,
                  initialChildSize: .28,
                  minChildSize: .2,
                  maxChildSize: .8,
                  builder: (context, sc) => Material(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    elevation: 8,
                    child: ListView(
                      controller: sc,
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        16,
                        8,
                        16,
                        20,
                      ),
                      children: [
                        Center(
                          child: Container(
                            width: 42,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.outlineVariant,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                l.geofenceTitle,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            TextButton(
                              onPressed: () => setState(
                                () => _extent = _extent == .28 ? .8 : .28,
                              ),
                              child: Text(l.geofenceShowOnMap),
                            ),
                          ],
                        ),
                        TextField(
                          controller: _search,
                          onChanged: context.read<GeofenceCubit>().search,
                          decoration: InputDecoration(
                            hintText: l.geofenceSearch,
                            prefixIcon: const Icon(Icons.search),
                            isDense: true,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        FilledButton.icon(
                          onPressed: () =>
                              context.push(AppRoutes.geofenceCreate),
                          icon: const Icon(Icons.add),
                          label: Text(l.geofenceCreate),
                        ),
                        const SizedBox(height: 8),
                        if (state.status == GeofenceStatus.loading)
                          const LinearProgressIndicator()
                        else if (state.status == GeofenceStatus.failure)
                          Center(
                            child: TextButton(
                              onPressed: context.read<GeofenceCubit>().load,
                              child: Text(l.retry),
                            ),
                          )
                        else if (state.visibleGeofences.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                state.query.isEmpty
                                    ? l.geofenceEmpty
                                    : l.geofenceNoResults,
                              ),
                            ),
                          )
                        else
                          ...state.visibleGeofences.map(
                            (g) => _GeofenceRow(
                              geofence: g,
                              selected: g.id == state.selectedId,
                              onTap: () {
                                context.read<GeofenceCubit>().select(g.id);
                                _map.focus(g);
                              },
                              onDetails: () =>
                                  context.push(AppRoutes.geofenceDetails(g.id)),
                              onDelete: () => _delete(context, g, l),
                            ),
                          ),
                      ],
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

  Future<void> _delete(
    BuildContext context,
    Geofence g,
    AppLocalizations l,
  ) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l.geofenceDelete),
        content: Text(g.name),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(l.geofenceCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(l.geofenceDelete),
          ),
        ],
      ),
    );
    if (yes == true && mounted)
      await context.read<GeofenceCubit>().delete(g.id);
  }
}

class _MapButton extends StatelessWidget {
  const _MapButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surface,
    borderRadius: BorderRadius.circular(8),
    child: IconButton(
      tooltip: label,
      onPressed: onTap,
      icon: Icon(icon),
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
    ),
  );
}

class _GeofenceRow extends StatelessWidget {
  const _GeofenceRow({
    required this.geofence,
    required this.selected,
    required this.onTap,
    required this.onDetails,
    required this.onDelete,
  });

  final Geofence geofence;
  final bool selected;
  final VoidCallback onTap, onDetails, onDelete;

  @override
  Widget build(BuildContext context) => Card(
    color: selected ? Theme.of(context).colorScheme.secondaryContainer : null,
    child: ListTile(
      onTap: onTap,
      leading: Icon(Icons.gps_fixed, color: geofenceColor(geofence.colorValue)),
      title: Text(geofence.name),
      trailing: Wrap(
        spacing: 0,
        children: [
          IconButton(
            tooltip: AppLocalizations.of(context)!.geofenceView,
            onPressed: onDetails,
            icon: const Icon(Icons.open_in_new),
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'delete') onDelete();
              if (v == 'edit')
                context.push(AppRoutes.geofenceEdit(geofence.id));
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Text(AppLocalizations.of(context)!.poiEdit),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text(AppLocalizations.of(context)!.geofenceDelete),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
