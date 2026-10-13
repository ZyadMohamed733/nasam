import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/hit_target.dart';
import '../../../../shared/widgets/map_sheet_header.dart';
import '../../../play_back/presentation/widgets/playback_date_picker_sheet.dart';
import '../../domain/entities/alert_history_filter.dart';
import '../../domain/entities/history_alert.dart';

/// A custom range as wall-clock times on the alerts' calendar, or null when
/// the user backed out of picking.
typedef CustomRangePicker =
    Future<({DateTime from, DateTime to})?> Function(
      BuildContext context, {
      DateTime? from,
      DateTime? to,
    });

/// Opens the filter sheet ("Bottom Sheet Filter", `988-17176`).
///
/// Returns the filter to apply: the user's choice on Apply, or
/// [AlertHistoryFilter.none] on Reset, which clears every filter at once
/// (NASAM-621 scenario 22). Null when the sheet was dismissed, which changes
/// nothing.
Future<AlertHistoryFilter?> showAlertHistoryFilterSheet(
  BuildContext context, {
  required AlertHistoryFilter current,
  DateTime Function() clock = DateTime.now,
  CustomRangePicker pickCustomRange = pickAlertCustomRange,
}) => showModalBottomSheet<AlertHistoryFilter>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  backgroundColor: context.colorScheme.surface,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(
      top: Radius.circular(AlertHistoryFilterSheet.radius),
    ),
  ),
  builder: (context) => AlertHistoryFilterSheet(
    current: current,
    clock: clock,
    pickCustomRange: pickCustomRange,
    onApply: (filter) => Navigator.of(context).pop(filter),
    onReset: () => Navigator.of(context).pop(AlertHistoryFilter.none),
  ),
);

/// The sheet's content: title, the alert type and date choices, then Apply
/// and Reset.
///
/// Choices are a draft until Apply. Geofence is left out until its story
/// (next sprint); Downtime is added ahead of the design.
class AlertHistoryFilterSheet extends StatefulWidget {
  const AlertHistoryFilterSheet({
    super.key,
    required this.current,
    required this.onApply,
    required this.onReset,
    this.clock = DateTime.now,
    this.pickCustomRange = pickAlertCustomRange,
  });

  final AlertHistoryFilter current;
  final ValueChanged<AlertHistoryFilter> onApply;
  final VoidCallback onReset;
  final DateTime Function() clock;
  final CustomRangePicker pickCustomRange;

  static const double radius = AppSizes.r24;
  static const double gutter = AppSizes.p16;
  static const double sectionGap = AppSizes.p24;
  static const double labelGap = AppSizes.p12;
  static const double choiceGap = AppSizes.p8;
  static const double actionsGap = AppSizes.p32;

  // TODO(NASAM-621): add AlertType.geofence when geofence alerts ship.
  static const types = [AlertType.speed, AlertType.sensor, AlertType.downtime];

  static const presets = [
    AlertDatePreset.today,
    AlertDatePreset.yesterday,
    AlertDatePreset.last7Days,
    AlertDatePreset.last30Days,
    AlertDatePreset.custom,
  ];

  static const applyKey = ValueKey('alert-filter-apply');
  static const resetKey = ValueKey('alert-filter-reset');
  static const allTypesKey = ValueKey('alert-filter-type-all');

  static ValueKey<String> typeKey(AlertType type) =>
      ValueKey('alert-filter-type-${type.name}');

  static ValueKey<String> presetKey(AlertDatePreset preset) =>
      ValueKey('alert-filter-date-${preset.name}');

  @override
  State<AlertHistoryFilterSheet> createState() =>
      _AlertHistoryFilterSheetState();
}

class _AlertHistoryFilterSheetState extends State<AlertHistoryFilterSheet> {
  late AlertHistoryFilter _draft = widget.current;

  void _selectType(AlertType? type) =>
      setState(() => _draft = _draft.withType(type));

  Future<void> _selectPreset(AlertDatePreset preset) async {
    if (preset == AlertDatePreset.custom) return _pickCustom();
    if (_draft.datePreset == preset) {
      setState(() => _draft = _draft.withDates(null));
      return;
    }
    final range = AlertHistoryFilter.rangeFor(preset, widget.clock());
    setState(
      () => _draft = _draft.withDates(preset, from: range.from, to: range.to),
    );
  }

  Future<void> _pickCustom() async {
    final custom = _draft.datePreset == AlertDatePreset.custom;
    final picked = await widget.pickCustomRange(
      context,
      from: custom ? _wallClock(_draft.from!) : null,
      to: custom ? _wallClock(_draft.to!) : null,
    );
    if (picked == null || !mounted) return;
    setState(
      () => _draft = _draft.withDates(
        AlertDatePreset.custom,
        from: AlertHistoryFilter.instantOf(picked.from),
        // Inclusive of the picked minute.
        to: AlertHistoryFilter.instantOf(
          picked.to,
        ).add(const Duration(seconds: 59, milliseconds: 999)),
      ),
    );
  }

  static DateTime _wallClock(DateTime instant) =>
      instant.toUtc().add(AlertHistoryFilter.saudiUtcOffset);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final s = context.semanticColors;
    final valid = _draft.hasValidRange;
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        child: HitTargetScope(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AlertHistoryFilterSheet.gutter,
              0,
              AlertHistoryFilterSheet.gutter,
              AlertHistoryFilterSheet.gutter,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MapSheetHandle(color: s.divider),
                Semantics(
                  header: true,
                  child: Text(
                    l.alertFilterTitle,
                    style: AppTextStyles.bodyXLB.copyWith(color: s.textColor),
                  ),
                ),
                const SizedBox(height: AppSizes.p4),
                Text(
                  l.alertFilterSubtitle,
                  style: AppTextStyles.bodySR.copyWith(
                    color: s.textPlaceholder,
                  ),
                ),
                const SizedBox(height: AlertHistoryFilterSheet.sectionGap),
                _Section(
                  label: l.alertFilterType,
                  children: [
                    _Choice(
                      key: AlertHistoryFilterSheet.allTypesKey,
                      label: l.alertFilterTypeAll,
                      selected: _draft.type == null,
                      onTap: () => _selectType(null),
                    ),
                    for (final type in AlertHistoryFilterSheet.types)
                      _Choice(
                        key: AlertHistoryFilterSheet.typeKey(type),
                        label: _typeLabel(l, type),
                        selected: _draft.type == type,
                        onTap: () => _selectType(type),
                      ),
                  ],
                ),
                const SizedBox(height: AlertHistoryFilterSheet.sectionGap),
                _Section(
                  label: l.alertFilterDate,
                  children: [
                    for (final preset in AlertHistoryFilterSheet.presets)
                      _Choice(
                        key: AlertHistoryFilterSheet.presetKey(preset),
                        label: _presetLabel(l, preset),
                        selected: _draft.datePreset == preset,
                        onTap: () => _selectPreset(preset),
                      ),
                  ],
                ),
                if (_draft.datePreset == AlertDatePreset.custom) ...[
                  const SizedBox(height: AppSizes.p8),
                  _CustomRange(from: _draft.from!, to: _draft.to!),
                ],
                if (!valid) ...[
                  const SizedBox(height: AppSizes.p8),
                  Text(
                    l.alertFilterInvalidRange,
                    style: AppTextStyles.bodySR.copyWith(color: s.failText),
                  ),
                ],
                const SizedBox(height: AlertHistoryFilterSheet.actionsGap),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        key: AlertHistoryFilterSheet.applyKey,
                        label: l.alertFilterApply,
                        onPressed: valid ? () => widget.onApply(_draft) : null,
                      ),
                    ),
                    const SizedBox(width: AppSizes.p12),
                    IntrinsicWidth(
                      child: AppButton(
                        key: AlertHistoryFilterSheet.resetKey,
                        label: l.alertFilterReset,
                        variant: AppButtonVariant.secondary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.p16,
                        ),
                        onPressed: widget.onReset,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _typeLabel(AppLocalizations l, AlertType type) =>
      switch (type) {
        AlertType.speed => l.alertFilterTypeSpeed,
        AlertType.sensor => l.alertFilterTypeSensor,
        AlertType.downtime => l.alertFilterTypeDowntime,
        AlertType.geofence || AlertType.unknown => throw ArgumentError.value(
          type,
          'type',
          'Not offered as a filter.',
        ),
      };

  static String _presetLabel(AppLocalizations l, AlertDatePreset preset) =>
      switch (preset) {
        AlertDatePreset.today => l.alertFilterToday,
        AlertDatePreset.yesterday => l.alertFilterYesterday,
        AlertDatePreset.last7Days => l.alertFilterLast7Days,
        AlertDatePreset.last30Days => l.alertFilterLast30Days,
        AlertDatePreset.custom => l.alertFilterCustomDate,
      };
}

/// A section label, then its choices wrapping onto as many lines as they
/// need — under Arabic, from the right.
class _Section extends StatelessWidget {
  const _Section({required this.label, required this.children});

  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final s = context.semanticColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            label,
            style: AppTextStyles.bodyMB.copyWith(color: s.textColor),
          ),
        ),
        const SizedBox(height: AlertHistoryFilterSheet.labelGap),
        Wrap(
          spacing: AlertHistoryFilterSheet.choiceGap,
          runSpacing: AlertHistoryFilterSheet.choiceGap,
          children: children,
        ),
      ],
    );
  }
}

/// One choice: filled with the brand colour when selected, outlined when not.
/// Drawn 36 tall and answers touches across 48.
class _Choice extends StatelessWidget {
  const _Choice({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  static const double height = 36;
  static const double minWidth = 80;

  @override
  Widget build(BuildContext context) {
    final s = context.semanticColors;
    final radius = BorderRadius.circular(AppSizes.r8);
    return HitTargetExtender(
      child: Semantics(
        button: true,
        selected: selected,
        inMutuallyExclusiveGroup: true,
        child: Material(
          color: selected ? s.primaryButtonBackground : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: selected
                ? BorderSide.none
                : BorderSide(color: s.containerBorder),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: height,
                minWidth: minWidth,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
                child: Center(
                  widthFactor: 1,
                  child: Text(
                    label,
                    style: AppTextStyles.bodyMR.copyWith(
                      color: selected ? s.primaryButtonText : s.textColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The picked custom range, read on the alerts' calendar. The design shows
/// no summary; this stands in until its range picker is built.
class _CustomRange extends StatelessWidget {
  const _CustomRange({required this.from, required this.to});

  final DateTime from;
  final DateTime to;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final s = context.semanticColors;
    final format = DateFormat(
      'd MMM yyyy, hh:mm a',
      Localizations.localeOf(context).toString(),
    );
    String read(DateTime instant) =>
        format.format(instant.toUtc().add(AlertHistoryFilter.saudiUtcOffset));
    return Text(
      '${l.alertFilterFrom} ${read(from)}  ·  ${l.alertFilterTo} ${read(to)}',
      style: AppTextStyles.bodySR.copyWith(color: s.textPlaceholder),
    );
  }
}

/// Picks a custom range with the date and time picker, From then To, as
/// wall-clock times on the alerts' calendar.
Future<({DateTime from, DateTime to})?> pickAlertCustomRange(
  BuildContext context, {
  DateTime? from,
  DateTime? to,
}) async {
  final l = AppLocalizations.of(context)!;
  final now = DateTime.now().toUtc().add(AlertHistoryFilter.saudiUtcOffset);
  final lastDate = DateTime(now.year, now.month, now.day);
  // The story sets no limit on how far back; the picker needs a first page.
  final firstDate = DateTime(2000);

  Future<DateTime?> pick(String title, DateTime? initial) =>
      showModalBottomSheet<DateTime>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: context.colorScheme.surfaceContainerLow,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSizes.r12),
          ),
        ),
        builder: (_) => PlaybackDatePickerSheet(
          title: title,
          initialDate: initial ?? lastDate,
          firstDate: firstDate,
          lastDate: lastDate,
        ),
      );

  final pickedFrom = await pick(l.alertFilterFrom, from);
  if (pickedFrom == null || !context.mounted) return null;
  final pickedTo = await pick(l.alertFilterTo, to ?? pickedFrom);
  if (pickedTo == null) return null;
  return (from: pickedFrom, to: pickedTo);
}
