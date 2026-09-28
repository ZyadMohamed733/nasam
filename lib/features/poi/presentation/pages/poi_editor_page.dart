import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../shared/widgets/app_bottom_sheet.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../domain/entities/poi_draft.dart';
import '../../domain/entities/point_of_interest.dart';
import '../cubit/poi_editor_cubit.dart';
import '../widgets/poi_icon.dart';
import 'poi_location_page.dart';

class PoiEditorPage extends StatefulWidget {
  const PoiEditorPage({super.key, this.pointId});
  final String? pointId;
  @override
  State<PoiEditorPage> createState() => _PoiEditorPageState();
}

class _PoiEditorPageState extends State<PoiEditorPage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController(),
      _latitude = TextEditingController(),
      _longitude = TextEditingController(),
      _notes = TextEditingController();
  PoiIcon _icon = PoiIcon.fuel;
  bool _seeded = false, _dirty = false, _leaving = false;
  void _seed(PointOfInterest point) {
    if (_seeded) return;
    _seeded = true;
    _name.text = point.name;
    _latitude.text = '${point.latitude}';
    _longitude.text = '${point.longitude}';
    _notes.text = point.notes;
    _icon = point.icon;
  }

  @override
  void dispose() {
    _name.dispose();
    _latitude.dispose();
    _longitude.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _changed(String _) {
    if (!_dirty) setState(() => _dirty = true);
  }

  Future<void> _leave() async {
    if (_leaving || context.read<PoiEditorCubit>().state.busy) return;
    final l = AppLocalizations.of(context)!;
    final leave =
        !_dirty ||
        await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(l.poiDiscardTitle),
                content: Text(l.poiDiscardMessage),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(l.poiCancel),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(l.poiDiscard),
                  ),
                ],
              ),
            ) ==
            true;
    if (mounted && leave) {
      setState(() => _leaving = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.pop();
      });
    }
  }

  LatLng get _position {
    final lat = double.tryParse(_latitude.text),
        lon = double.tryParse(_longitude.text);
    return lat != null &&
            lon != null &&
            lat.isFinite &&
            lon.isFinite &&
            lat.abs() <= 90 &&
            lon.abs() <= 180
        ? LatLng(lat, lon)
        : const LatLng(24.86, 46.40);
  }

  Future<void> _location() async {
    final point = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(builder: (_) => PoiLocationPage(initial: _position)),
    );
    if (!mounted || point == null) return;
    setState(() {
      _latitude.text = point.latitude.toStringAsFixed(6);
      _longitude.text = point.longitude.toStringAsFixed(6);
      _dirty = true;
    });
  }

  Future<void> _chooseIcon() async {
    final l = AppLocalizations.of(context)!;
    final icon = await AppBottomSheet.show<PoiIcon>(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l.poiIcon, style: Theme.of(context).textTheme.titleMedium),
          for (final icon in PoiIcon.values)
            ListTile(
              leading: PoiIconImage(icon: icon),
              title: Text(PoiIconStyle.label(icon, l)),
              trailing: icon == _icon ? const Icon(Icons.check) : null,
              onTap: () => Navigator.of(context).pop(icon),
            ),
        ],
      ),
    );
    if (mounted && icon != null) {
      setState(() {
        _icon = icon;
        _dirty = true;
      });
    }
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    context.read<PoiEditorCubit>().save(
      PoiDraft(
        name: _name.text,
        latitude: double.parse(_latitude.text),
        longitude: double.parse(_longitude.text),
        icon: _icon,
        notes: _notes.text,
      ),
      id: widget.pointId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return BlocConsumer<PoiEditorCubit, PoiEditorState>(
      listener: (context, state) {
        if (state.status == PoiEditorStatus.saved) {
          setState(() {
            _dirty = false;
            _leaving = true;
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) context.pop(true);
          });
        }
      },
      builder: (context, state) {
        if (state.point != null) _seed(state.point!);
        final initialLoading = widget.pointId != null && state.point == null;
        return PopScope(
          canPop: _leaving || (!_dirty && !state.busy),
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _leave();
          },
          child: Scaffold(
            appBar: AppBar(
              centerTitle: false,
              leading: BackButton(onPressed: _leave),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.pointId == null ? l.poiCreateTitle : l.poiEdit,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    l.poiSubtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            body: initialLoading
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
                                    .load(widget.pointId!),
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
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(AppSizes.p16),
                        child: AppCard(
                          child: Form(
                            key: _form,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  l.poiBasicInfo,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                Text(
                                  l.poiSubtitle,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(height: AppSizes.p20),
                                if (state.status == PoiEditorStatus.failure)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: AppSizes.p12,
                                    ),
                                    child: Text(
                                      l.errorGeneric,
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.error,
                                      ),
                                    ),
                                  ),
                                AppTextField(
                                  label: l.poiName,
                                  isRequired: true,
                                  controller: _name,
                                  enabled: !state.busy,
                                  onChanged: _changed,
                                  validator: (v) =>
                                      v == null || v.trim().isEmpty
                                      ? l.poiRequired
                                      : v.trim().length > 200
                                      ? l.poiNameLimit
                                      : null,
                                ),
                                const SizedBox(height: AppSizes.p20),
                                Text(
                                  l.poiLocation,
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                                const SizedBox(height: AppSizes.p8),
                                PoiLocationPreview(
                                  point: _position,
                                  onExpand: state.busy ? null : _location,
                                ),
                                const SizedBox(height: AppSizes.p8),
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    Widget field(bool lat) => AppTextField(
                                      label: lat
                                          ? l.poiLatitude
                                          : l.poiLongitude,
                                      isRequired: true,
                                      controller: lat ? _latitude : _longitude,
                                      enabled: !state.busy,
                                      forceLtr: true,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                            signed: true,
                                          ),
                                      onChanged: (value) {
                                        _changed(value);
                                        setState(() {});
                                      },
                                      validator: (v) {
                                        final n = double.tryParse(v ?? '');
                                        return n == null ||
                                                !n.isFinite ||
                                                n.abs() > (lat ? 90 : 180)
                                            ? l.poiInvalidCoordinate
                                            : null;
                                      },
                                    );
                                    return constraints.maxWidth < 330 ||
                                            MediaQuery.textScalerOf(
                                                  context,
                                                ).scale(1) >
                                                1.2
                                        ? Column(
                                            children: [
                                              field(true),
                                              const SizedBox(
                                                height: AppSizes.p12,
                                              ),
                                              field(false),
                                            ],
                                          )
                                        : Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(child: field(true)),
                                              const SizedBox(
                                                width: AppSizes.p8,
                                              ),
                                              Expanded(child: field(false)),
                                            ],
                                          );
                                  },
                                ),
                                const SizedBox(height: AppSizes.p20),
                                Text(
                                  l.poiIcon,
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                                Material(
                                  color: Colors.transparent,
                                  child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: PoiIconImage(icon: _icon),
                                    title: Text(
                                      PoiIconStyle.label(_icon, l),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                    trailing: const Icon(
                                      Icons.keyboard_arrow_down,
                                    ),
                                    onTap: state.busy ? null : _chooseIcon,
                                  ),
                                ),
                                const SizedBox(height: AppSizes.p12),
                                AppTextField(
                                  label: l.poiNotes,
                                  controller: _notes,
                                  maxLines: 4,
                                  enabled: !state.busy,
                                  onChanged: _changed,
                                  validator: (v) => (v?.length ?? 0) > 2000
                                      ? l.poiNotesLimit
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
            bottomNavigationBar: initialLoading
                ? null
                : SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.p16),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: AppButton(
                              label: widget.pointId == null
                                  ? l.poiCreate
                                  : l.poiSave,
                              onPressed: state.busy ? null : _save,
                              isLoading: state.status == PoiEditorStatus.saving,
                            ),
                          ),
                          const SizedBox(width: AppSizes.p8),
                          Expanded(
                            child: AppButton(
                              label: l.poiCancel,
                              variant: AppButtonVariant.secondary,
                              onPressed: state.busy ? null : _leave,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }
}
