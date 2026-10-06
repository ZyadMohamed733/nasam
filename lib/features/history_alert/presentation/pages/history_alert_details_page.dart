import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../shared/widgets/loading_indicator_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../domain/entities/history_alert.dart';
import '../../domain/entities/history_details.dart';
import '../cubit/histroy_alert_cubit.dart';
import '../cubit/hsitory_alert_state.dart';
import '../widget/history_details_appbar.dart';
import '../widget/history_details_card.dart';

class HistoryAlertDetailsPage extends StatelessWidget {
  const HistoryAlertDetailsPage({super.key, required this.alert});

  final HistoryAlertEntity alert;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Directionality(
      // Keep this feature's physical alignment tied to the selected app
      // language. Some navigation entry points can retain an LTR subtree.
      textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: BlocBuilder<HistoryAlertCubit, HistoryAlertState>(
        builder: (context, state) => switch (state) {
          HistoryAlertLoading() => _scaffold(
            context,
            title: alert.title,
            body: const Center(child: LoadingIndicatorWidget()),
          ),
          HistoryAlertFailure(:final failure) => _scaffold(
            context,
            title: alert.title,
            body: AppErrorWidget(
              message: l.errorGeneric,
              retryLabel: l.retry,
              onRetry: () => context
                  .read<HistoryAlertCubit>()
                  .getHistoryAlertDetails(alertId: alert.id),
              type: AppErrorWidget.typeForFailure(failure),
            ),
          ),
          HistoryAlertDetailLoaded(:final detailsEntity) => _loaded(
            context,
            detailsEntity,
          ),
          _ => _scaffold(
            context,
            title: alert.title,
            body: AppErrorWidget(
              message: l.errorGeneric,
              retryLabel: l.retry,
              onRetry: () => context
                  .read<HistoryAlertCubit>()
                  .getHistoryAlertDetails(alertId: alert.id),
            ),
          ),
        },
      ),
    );
  }

  Widget _scaffold(
    BuildContext context, {
    required String title,
    required Widget body,
  }) {
    return Scaffold(
      appBar: HistoryDetailsAppbar(title: title),
      body: body,
    );
  }

  Widget _loaded(BuildContext context, HistoryAlertDetailsEntity details) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final info = details.basicInfo;
    final saudiTime = info.timestamp.toUtc().add(const Duration(hours: 3));
    final formattedTime = DateFormat(
      'd MMMM yyyy — hh:mm a',
      Localizations.localeOf(context).toString(),
    ).format(saudiTime);
    final speed = details.speedDetails;

    return _scaffold(
      context,
      title: details.title,
      body: ListView(
        padding: EdgeInsetsDirectional.fromSTEB(12.w, 12.h, 12.w, 20.h),
        children: [
          HistoryDetailsCard(
            title: l.assetDetailsInformation,
            rows: [
              HistoryDetailsRow(
                label: l.assetDetailsAlertName,
                value: info.alertName,
              ),
              HistoryDetailsRow(label: l.alertAsset, value: info.assetName),
              HistoryDetailsRow(
                label: l.assetDetailsAlertType,
                value: info.alertTypeLabel,
              ),
              HistoryDetailsRow(label: l.alertTime, value: formattedTime),
              HistoryDetailsRow(label: l.alertLocation, value: info.location),
            ],
          ),
          if (info.alertType == AlertType.speed && speed != null) ...[
            SizedBox(height: 10.h),
            HistoryDetailsCard(
              title: l.alertDetailsSpeedInfo,
              rows: [
                HistoryDetailsRow(
                  label: l.alertDetailsRecordedSpeed,
                  value:
                      '${speed.recordedSpeed} ${l.assetPlaybackKilometersPerHour}',
                  valueColor: speed.isViolation
                      ? theme.colorScheme.error
                      : null,
                ),
                HistoryDetailsRow(
                  label: l.alertDetailsSpeedLimit,
                  value:
                      '${speed.speedLimit} ${l.assetPlaybackKilometersPerHour}',
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
