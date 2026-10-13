import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nasam/core/constants/app_colors.dart';
import 'package:nasam/core/router/app_routes.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../shared/widgets/action_icon.dart';
import '../../../../shared/widgets/app_bar_widget.dart';
import '../../../../shared/widgets/empty_result_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/loading_indicator_widget.dart';
import '../../domain/entities/alert_history_filter.dart';
import '../../domain/entities/history_alert.dart';
import '../cubit/histroy_alert_cubit.dart';
import '../cubit/hsitory_alert_state.dart';
import '../widget/alert_history_filter_sheet.dart';
import '../widget/history_alert_card.dart';
import '../widget/no_search_result_widget.dart';
import '../widget/search_bar_widget.dart';

class HistoryAlertPage extends StatefulWidget {
  const HistoryAlertPage({super.key, this.onBack, this.openDrawer});

  final VoidCallback? onBack;
  final VoidCallback? openDrawer;

  @override
  State<HistoryAlertPage> createState() => _HistoryAlertPageState();
}

class _HistoryAlertPageState extends State<HistoryAlertPage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: NasamAppBar(
        showLeading: false,
        centerTitle: false,
        leading: AppAssetsIconWidget(
          label: MaterialLocalizations.of(context).openAppDrawerTooltip,
          asset: AppAssets.sideMenu,
          size: 20,
          containerSize: 40,
          boxDecoration: BoxDecoration(
            color: AppColors.neutral100,
            borderRadius: BorderRadius.circular(8),
          ),
          onPressed: widget.openDrawer ?? widget.onBack ?? () => context.pop(),
        ),
        titleWidget: Text(
          l.assetDetailsNotifications,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        trailing: AppAssetsIconWidget(
          label: l.drawerAlertsLog,
          size: 20,
          containerSize: 40,
          asset: AppAssets.mapNotification,
          boxDecoration: BoxDecoration(
            color: AppColors.neutral100,
            borderRadius: BorderRadius.circular(8),
          ),
          onPressed: () {},
        ),
      ),
      body: BlocProvider(
        create: (_) => getIt<HistoryAlertCubit>()..getHistoryAlertData(),
        child: BlocBuilder<HistoryAlertCubit, HistoryAlertState>(
          builder: (context, state) => switch (state) {
            HistoryAlertLoading() => const Center(
              child: LoadingIndicatorWidget(),
            ),
            HistoryAlertLoaded(:final historyAlertDataList)
                when historyAlertDataList.isEmpty =>
              EmptyResultWidget(
                message: l.alertsLogUnavailable,
                subtitle: l.deviceAlertsEmpty,
                type: EmptyResultType.alerts,
                imageHeight: 48,
                padding: const EdgeInsets.all(24),
              ),
            HistoryAlertLoaded(:final historyAlertDataList, :final filter) =>
              _historyList(context, historyAlertDataList, filter),
            HistoryAlertFailure(:final failure) => AppErrorWidget(
              message: l.errorGeneric,
              retryLabel: l.retry,
              onRetry: context.read<HistoryAlertCubit>().getHistoryAlertData,
              type: AppErrorWidget.typeForFailure(failure),
            ),
            HistoryAlertDetailLoaded() => const SizedBox.shrink(),
          },
        ),
      ),
    );
  }

  Widget _historyList(
    BuildContext context,
    List<HistoryAlertEntity> alerts,
    AlertHistoryFilter filter,
  ) {
    final query = _query.trim().toLowerCase();
    final filtered = alerts
        .where((alert) {
          if (!filter.matches(alert)) return false;
          if (query.isEmpty) return true;
          return [
            alert.title,
            alert.assetName,
            alert.alertTypeLabel,
            alert.valueLabel,
            alert.value?.toString() ?? '',
            alert.unit ?? '',
            alert.timestamp.toIso8601String(),
            alert.location,
          ].any((value) => value.toString().toLowerCase().contains(query));
        })
        .toList(growable: false);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: SearchBarWidget(
            controller: _searchController,
            onSearchChanged: (value) => setState(() {
              debugPrint('[HistoryAlertPage] setState: search query changed');
              _query = value;
            }),
            onFilterPressed: () => _showFilter(context, filter),
            isFilterActive: filter.isActive,
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? NoSearchResultWidget(
                  historyList: filtered,
                  onClearFilters: () => _clearFilters(context),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) => HistoryAlertCard(
                    alert: filtered[index],
                    onTap: () => context.push(
                      AppRoutes.alertDetails(filtered[index].id),
                      extra: filtered[index],
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  void _clearFilters(BuildContext blocContext) {
    setState(() {
      debugPrint('[HistoryAlertPage] setState: clear search query');
      _query = '';
      _searchController.clear();
    });
    blocContext.read<HistoryAlertCubit>().applyFilter(AlertHistoryFilter.none);
  }

  Future<void> _showFilter(
    BuildContext blocContext,
    AlertHistoryFilter current,
  ) async {
    final filter = await showAlertHistoryFilterSheet(
      blocContext,
      current: current,
    );
    if (filter == null || !mounted || !blocContext.mounted) return;
    blocContext.read<HistoryAlertCubit>().applyFilter(filter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
