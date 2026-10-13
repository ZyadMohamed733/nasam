import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/loading_indicator_widget.dart';
import '../../domain/entities/history_alert.dart';
import '../../domain/entities/history_details.dart';
import '../cubit/histroy_alert_cubit.dart';
import '../cubit/hsitory_alert_state.dart';
import '../utils/alert_history_format.dart';
import '../widget/history_details_appbar.dart';
import '../widget/history_details_card.dart';

/// One alert's details (NASAM-621 scenarios 23–28): what every alert has,
/// then the part its type adds. [alert] is the list row it was opened from,
/// so the title shows while the details load.
class HistoryAlertDetailsPage extends StatelessWidget {
  const HistoryAlertDetailsPage({super.key, required this.alert});

  final HistoryAlertEntity alert;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final title = AlertHistoryFormat.text(context, alert.alertName);
    void retry() => context.read<HistoryAlertCubit>().getHistoryAlertDetails(
      alertId: alert.id,
    );

    return Directionality(
      // Keep this feature's physical alignment tied to the selected app
      // language. Some navigation entry points can retain an LTR subtree.
      textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: BlocBuilder<HistoryAlertCubit, HistoryAlertState>(
        builder: (context, state) => switch (state) {
          HistoryAlertLoading() => _scaffold(
            title: title,
            body: const Center(child: LoadingIndicatorWidget()),
          ),
          HistoryAlertFailure(:final failure) => _scaffold(
            title: title,
            body: AppErrorWidget(
              message: l.errorGeneric,
              retryLabel: l.retry,
              onRetry: retry,
              type: AppErrorWidget.typeForFailure(failure),
            ),
          ),
          HistoryAlertDetailLoaded(:final detailsEntity) => _loaded(
            context,
            detailsEntity,
          ),
        },
      ),
    );
  }

  Widget _scaffold({required String title, required Widget body}) => Scaffold(
    appBar: HistoryDetailsAppbar(title: title),
    body: body,
  );

  Widget _loaded(BuildContext context, HistoryAlertDetailsEntity entity) {
    final l = AppLocalizations.of(context)!;
    final alert = entity.alert;
    final typeDetails = entity.details;
    return _scaffold(
      title: AlertHistoryFormat.text(context, alert.alertName),
      body: ListView(
        padding: EdgeInsetsDirectional.fromSTEB(12.w, 12.h, 12.w, 20.h),
        children: [
          HistoryDetailsCard(
            title: l.assetDetailsInformation,
            rows: [
              HistoryDetailsRow(
                label: l.assetDetailsAlertName,
                value: AlertHistoryFormat.text(context, alert.alertName),
              ),
              HistoryDetailsRow(
                label: l.alertAsset,
                value: AlertHistoryFormat.asset(context, alert.asset),
              ),
              HistoryDetailsRow(
                label: l.assetDetailsAlertType,
                value: AlertHistoryFormat.typeLabel(l, alert.alertType),
              ),
              HistoryDetailsRow(
                label: l.alertTime,
                value: AlertHistoryFormat.time(context, alert.occurredAt),
              ),
              HistoryDetailsRow(
                label: l.alertLocation,
                value: AlertHistoryFormat.location(l, alert.location),
              ),
            ],
          ),
          if (typeDetails != null) ...[
            SizedBox(height: 10.h),
            _typeCard(context, typeDetails),
          ],
        ],
      ),
    );
  }

  Widget _typeCard(BuildContext context, AlertTypeDetails details) {
    final l = AppLocalizations.of(context)!;
    final kph = l.assetPlaybackKilometersPerHour;
    return switch (details) {
      SpeedAlertDetails() => HistoryDetailsCard(
        title: l.alertDetailsSpeedInfo,
        rows: [
          HistoryDetailsRow(
            label: l.alertDetailsRecordedSpeed,
            value: '${details.recordedSpeedKph} $kph',
            valueColor: details.isViolation
                ? Theme.of(context).colorScheme.error
                : null,
          ),
          HistoryDetailsRow(
            label: l.alertDetailsSpeedLimit,
            value: '${details.speedLimitKph} $kph',
          ),
        ],
      ),
      SensorAlertDetails() => HistoryDetailsCard(
        title: l.alertDetailsSensorInfo,
        rows: [
          HistoryDetailsRow(
            label: l.alertDetailsSensor,
            value: AlertHistoryFormat.text(context, details.sensorName),
          ),
          HistoryDetailsRow(
            label: l.alertDetailsSensorType,
            value: _sensorType(details.sensorType),
          ),
          HistoryDetailsRow(
            label: l.alertDetailsTriggeredValue,
            value: '${details.triggeredValue} ${details.unit}',
            valueColor: Theme.of(context).colorScheme.error,
          ),
          HistoryDetailsRow(
            label: l.alertDetailsCondition,
            // A comparison reads left to right in either language.
            value:
                '\u2066${switch (details.conditionOperator) {
                  SensorConditionOperator.greaterThan => '>',
                  SensorConditionOperator.lessThan => '<',
                }} ${details.conditionValue} ${details.unit}\u2069',
          ),
        ],
      ),
      DowntimeAlertDetails() => HistoryDetailsCard(
        title: l.alertDetailsDowntimeInfo,
        rows: [
          HistoryDetailsRow(
            label: l.alertDetailsDuration,
            value: l.alertDurationMinutes(details.durationMinutes),
          ),
        ],
      ),
    };
  }

  /// `ENGINE_TEMPERATURE` reads "Engine temperature". The API sends codes
  /// with no translations yet.
  static String _sensorType(String code) {
    final words = code.toLowerCase().replaceAll('_', ' ').trim();
    if (words.isEmpty) return code;
    return words[0].toUpperCase() + words.substring(1);
  }
}
