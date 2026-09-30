import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../core/theme/poi_sheet_colors.dart';
import '../../../../shared/widgets/app_dashed_box.dart';
import '../../../../shared/widgets/app_form_bottom_bar.dart';
import '../../../../shared/widgets/app_form_card.dart';
import '../../../../shared/widgets/app_form_field.dart';
import '../../../../shared/widgets/app_map_preview.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../domain/entities/poi_draft.dart';
import '../../domain/entities/point_of_interest.dart';
import '../cubit/poi_editor_cubit.dart';
import '../widgets/poi_icon.dart';
import '../widgets/poi_icon_picker.dart';
import '../widgets/poi_location_map.dart';
import 'poi_location_page.dart';

/// Create POI (`647:7879`) and Edit POI (`647:7930`): one form, driven by
/// whether there is a [pointId].
///
/// Create's primary action is always enabled and validates on submit. Edit's
/// is enabled only while the form differs from the saved point, so undoing a
/// change disables it again.
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
  PoiIcon? _icon;
  PointOfInterest? _saved;
  bool _submitted = false, _leaving = false;

  bool get _creating => widget.pointId == null;

  void _seed(PointOfInterest point) {
    if (_saved != null) return;
    _saved = point;
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

  /// Whether the form differs from where it started: empty for Create, the
  /// saved point for Edit.
  bool get _changed {
    final saved = _saved;
    if (saved == null) {
      return _name.text.isNotEmpty ||
          _latitude.text.isNotEmpty ||
          _longitude.text.isNotEmpty ||
          _notes.text.isNotEmpty ||
          _icon != null;
    }
    bool same(String text, double value) => double.tryParse(text) == value;
    return _name.text != saved.name ||
        !same(_latitude.text, saved.latitude) ||
        !same(_longitude.text, saved.longitude) ||
        _notes.text != saved.notes ||
        _icon != saved.icon;
  }

  void _edited([String _ = '']) => setState(() {});

  Future<void> _leave() async {
    if (_leaving || context.read<PoiEditorCubit>().state.busy) return;
    final l = AppLocalizations.of(context)!;
    final leave =
        !_changed ||
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

  /// The typed location, or null until both coordinates are valid.
  LatLng? get _position {
    final lat = double.tryParse(_latitude.text),
        lon = double.tryParse(_longitude.text);
    return lat != null &&
            lon != null &&
            lat.isFinite &&
            lon.isFinite &&
            lat.abs() <= 90 &&
            lon.abs() <= 180
        ? LatLng(lat, lon)
        : null;
  }

  /// Where the map looks before a location is picked: Riyadh.
  static const _defaultCenter = LatLng(24.86, 46.40);

  Future<void> _location() async {
    final point = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (_) => PoiLocationPage(initial: _position ?? _defaultCenter),
      ),
    );
    if (!mounted || point == null) return;
    setState(() {
      _latitude.text = point.latitude.toStringAsFixed(6);
      _longitude.text = point.longitude.toStringAsFixed(6);
    });
  }

  Future<void> _chooseIcon() async {
    final icon = await showPoiIconPicker(context, selected: _icon);
    if (mounted && icon != null) setState(() => _icon = icon);
  }

  void _save() {
    setState(() => _submitted = true);
    final valid = _form.currentState!.validate();
    if (!valid || _icon == null) return;
    context.read<PoiEditorCubit>().save(
      PoiDraft(
        name: _name.text.trim(),
        latitude: double.parse(_latitude.text),
        longitude: double.parse(_longitude.text),
        icon: _icon!,
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
          setState(() => _leaving = true);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) context.pop(true);
          });
        }
      },
      builder: (context, state) {
        final point = state.point;
        if (point != null && !_creating) _seed(point);
        final loading = !_creating && _saved == null;
        final busy = state.busy;
        return PopScope(
          canPop: _leaving || (!_changed && !busy),
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _leave();
          },
          child: Scaffold(
            backgroundColor: context.semanticColors.pageBackground,
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  AppPageHeader(
                    title: _creating ? l.poiCreateTitle : _saved?.name ?? '',
                    subtitle: _creating ? l.poiSubtitle : l.poiDetails,
                    onBack: _leave,
                  ),
                  Expanded(
                    child: loading
                        ? _Loading(
                            state: state,
                            onRetry: () => context.read<PoiEditorCubit>().load(
                              widget.pointId!,
                            ),
                          )
                        : _body(context, state),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: loading
                ? null
                : AppFormBottomBar(
                    primaryLabel: _creating ? l.poiCreate : l.poiSave,
                    onPrimary: busy || (!_creating && !_changed) ? null : _save,
                    loading: state.status == PoiEditorStatus.saving,
                    cancelLabel: l.poiCancel,
                    onCancel: busy ? null : _leave,
                  ),
          ),
        );
      },
    );
  }

  Widget _body(BuildContext context, PoiEditorState state) {
    final l = AppLocalizations.of(context)!;
    final s = context.semanticColors;
    final text = context.textTheme;
    final enabled = !state.busy;
    final bold = text.bodySmall?.copyWith(
      fontWeight: FontWeight.w700,
      color: s.textColor,
    );
    final icon = _icon;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: PoiFormLayout.maxWidth),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            PoiFormLayout.gutter,
            0,
            PoiFormLayout.gutter,
            PoiFormLayout.gutter,
          ),
          child: Form(
            key: _form,
            autovalidateMode: _submitted
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            child: AppFormCard(
              title: l.poiBasicInfo,
              subtitle: l.poiSubtitle,
              children: [
                if (state.status == PoiEditorStatus.failure)
                  Text(
                    l.errorGeneric,
                    style: text.bodySmall?.copyWith(color: s.failText),
                  ),
                AppFormField(
                  inputKey: PoiFormLayout.nameKey,
                  label: l.poiName,
                  isRequired: true,
                  controller: _name,
                  hint: l.poiNameHint,
                  valueStyle: bold,
                  enabled: enabled,
                  onChanged: _edited,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? l.poiRequired
                      : v.trim().length > 200
                      ? l.poiNameLimit
                      : null,
                ),
                _LocationField(
                  latitude: _latitude,
                  longitude: _longitude,
                  position: _position,
                  center: _position ?? _defaultCenter,
                  enabled: enabled,
                  onChanged: _edited,
                  onFullscreen: _location,
                ),
                AppSelectField(
                  boxKey: PoiFormLayout.iconKey,
                  label: l.poiIcon,
                  isRequired: true,
                  placeholder: l.poiIconHint,
                  value: icon == null ? null : PoiIconStyle.label(icon, l),
                  leading: icon == null
                      ? null
                      : PoiIconImage(
                          icon: icon,
                          size: AppSizes.iconMd,
                          color: s.textColor,
                        ),
                  errorText: _submitted && icon == null ? l.poiRequired : null,
                  onTap: enabled ? _chooseIcon : null,
                ),
                AppFormField(
                  inputKey: PoiFormLayout.notesKey,
                  label: l.poiNotes,
                  controller: _notes,
                  minLines: PoiFormLayout.notesMinLines,
                  maxLines: PoiFormLayout.notesMaxLines,
                  valueStyle: bold,
                  enabled: enabled,
                  onChanged: _edited,
                  validator: (v) =>
                      (v?.length ?? 0) > 2000 ? l.poiNotesLimit : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The form's measurements beyond the shared components' (`539:13749`).
abstract final class PoiFormLayout {
  static const double gutter = 16;
  static const double maxWidth = 600;

  // The location block (539:13754).
  static const double mapHeight = 171;
  static const double captionRow = 20;
  static const double captionIcon = 12;
  static const double captionGap = 4;
  static const double captionSize = 10;
  static const double captionToMap = 8;
  static const double mapToCoordinates = 4;
  static const double coordinateGap = 4;

  /// The dashed box is a fixed 289 tall, 6 more than its content and 4/4
  /// padding: 10 under the coordinates in all.
  static const double coordinatesToEdge = 6;

  /// Below this screen width, or above [stackAboveTextScale], latitude and
  /// longitude stack instead of sharing a row.
  static const double stackBelowWidth = 340;
  static const double stackAboveTextScale = 1.2;
  static const double stackedGap = 8;

  static const int notesMinLines = 3;
  static const int notesMaxLines = 6;

  static const nameKey = ValueKey('poi-form-name');
  static const latitudeKey = ValueKey('poi-form-latitude');
  static const longitudeKey = ValueKey('poi-form-longitude');
  static const iconKey = ValueKey('poi-form-icon');
  static const notesKey = ValueKey('poi-form-notes');
  static const locationBoxKey = ValueKey('poi-form-location');
}

/// The location field (`539:13754`): its label, then a dashed box holding
/// the caption, the map and the two coordinates.
class _LocationField extends StatelessWidget {
  const _LocationField({
    required this.latitude,
    required this.longitude,
    required this.position,
    required this.center,
    required this.enabled,
    required this.onChanged,
    required this.onFullscreen,
  });

  final TextEditingController latitude, longitude;
  final LatLng? position;
  final LatLng center;
  final bool enabled;
  final ValueChanged<String> onChanged;
  final VoidCallback onFullscreen;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final s = context.semanticColors;
    final text = context.textTheme;
    final caption = PoiSheetColors.of(context).locationCaption;
    final media = MediaQuery.of(context);
    final stacked =
        media.size.width < PoiFormLayout.stackBelowWidth ||
        media.textScaler.scale(1) > PoiFormLayout.stackAboveTextScale;

    Widget coordinate({required bool isLatitude}) => AppFormField(
      inputKey: isLatitude
          ? PoiFormLayout.latitudeKey
          : PoiFormLayout.longitudeKey,
      label: isLatitude ? l.poiLatitudeField : l.poiLongitudeField,
      isRequired: true,
      controller: isLatitude ? latitude : longitude,
      valueStyle: text.labelMedium?.copyWith(color: s.textColor),
      forceLtr: true,
      enabled: enabled,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: true,
      ),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[-.0-9]'))],
      onChanged: onChanged,
      validator: (v) {
        final n = double.tryParse(v ?? '');
        return n == null || !n.isFinite || n.abs() > (isLatitude ? 90 : 180)
            ? l.poiInvalidCoordinate
            : null;
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppFormLabel(l.poiLocation, isRequired: true),
        const SizedBox(height: AppFormField.labelGap),
        AppDashedBox(
          key: PoiFormLayout.locationBoxKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: PoiFormLayout.captionRow,
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      AppAssets.poiPin,
                      width: PoiFormLayout.captionIcon,
                      height: PoiFormLayout.captionIcon,
                      colorFilter: ColorFilter.mode(
                        s.textPlaceholder,
                        BlendMode.srcIn,
                      ),
                      excludeFromSemantics: true,
                    ),
                    const SizedBox(width: PoiFormLayout.captionGap),
                    Flexible(
                      child: Text(
                        l.poiSelectedCoordinates,
                        style: text.labelSmall?.copyWith(
                          fontSize: PoiFormLayout.captionSize.sp,
                          color: caption,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: PoiFormLayout.captionToMap),
              AppMapPreview(
                height: PoiFormLayout.mapHeight,
                showPin: position != null,
                fullscreenTooltip: l.poiSelectLocation,
                onFullscreen: enabled ? onFullscreen : null,
                map: PoiLocationMap(
                  point: center,
                  preview: true,
                  showMarker: false,
                ),
              ),
              const SizedBox(height: PoiFormLayout.mapToCoordinates),
              if (stacked) ...[
                coordinate(isLatitude: true),
                const SizedBox(height: PoiFormLayout.stackedGap),
                coordinate(isLatitude: false),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: coordinate(isLatitude: true)),
                    const SizedBox(width: PoiFormLayout.coordinateGap),
                    Expanded(child: coordinate(isLatitude: false)),
                  ],
                ),
              const SizedBox(height: PoiFormLayout.coordinatesToEdge),
            ],
          ),
        ),
      ],
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading({required this.state, required this.onRetry});

  final PoiEditorState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Center(
      child: state.status == PoiEditorStatus.failure
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.failure?.code == '404' ? l.poiNotFound : l.errorGeneric,
                ),
                TextButton(onPressed: onRetry, child: Text(l.retry)),
              ],
            )
          : const CircularProgressIndicator(),
    );
  }
}
