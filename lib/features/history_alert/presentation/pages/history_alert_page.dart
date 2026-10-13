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
import '../cubit/alert_history_list_cubit.dart';
import '../cubit/alert_history_list_state.dart';
import '../widget/alert_history_filter_sheet.dart';
import '../widget/applied_filter_chips.dart';
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
        create: (_) => getIt<AlertHistoryListCubit>()..load(),
        child: BlocBuilder<AlertHistoryListCubit, AlertHistoryListState>(
          builder: (context, state) {
            final cubit = context.read<AlertHistoryListCubit>();
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                  child: SearchBarWidget(
                    controller: _searchController,
                    onSearchChanged: cubit.onSearchChanged,
                    onFilterPressed: () => _showFilter(context, state.filter),
                    filterCount: state.filter.activeCount,
                  ),
                ),
                if (state.filter.isActive)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                    child: AppliedFilterChips(
                      filter: state.filter,
                      onChanged: cubit.applyFilter,
                    ),
                  ),
                Expanded(child: _body(context, state)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _body(BuildContext context, AlertHistoryListState state) {
    final l = AppLocalizations.of(context)!;
    final cubit = context.read<AlertHistoryListCubit>();
    return switch (state.status) {
      AlertHistoryStatus.loading => const Center(
        child: LoadingIndicatorWidget(),
      ),
      AlertHistoryStatus.failure => AppErrorWidget(
        message: l.errorGeneric,
        retryLabel: l.retry,
        onRetry: cubit.load,
        type: AppErrorWidget.typeForFailure(state.failure!),
      ),
      AlertHistoryStatus.loaded when state.alerts.isEmpty && state.isNarrowed =>
        NoSearchResultWidget(
          historyList: state.alerts,
          onClearFilters: () => _clearFilters(cubit),
        ),
      AlertHistoryStatus.loaded when state.alerts.isEmpty => RefreshIndicator(
        onRefresh: cubit.refresh,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: constraints.maxHeight,
              child: EmptyResultWidget(
                message: l.alertsLogUnavailable,
                subtitle: l.deviceAlertsEmpty,
                type: EmptyResultType.alerts,
                imageHeight: 48,
                padding: const EdgeInsets.all(24),
              ),
            ),
          ),
        ),
      ),
      AlertHistoryStatus.loaded => _list(context, state),
    };
  }

  Widget _list(BuildContext context, AlertHistoryListState state) {
    final cubit = context.read<AlertHistoryListCubit>();
    final footer = state.hasMore || state.loadMoreFailed;
    return NotificationListener<ScrollNotification>(
      // Ask for the next page while a screenful is still left to read.
      onNotification: (notification) {
        if (notification.metrics.extentAfter < 400) cubit.loadMore();
        return false;
      },
      child: RefreshIndicator(
        onRefresh: cubit.refresh,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          itemCount: state.alerts.length + (footer ? 1 : 0),
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            if (index == state.alerts.length) {
              return _LoadMoreFooter(
                failed: state.loadMoreFailed,
                onRetry: cubit.loadMore,
              );
            }
            final alert = state.alerts[index];
            return HistoryAlertCard(
              alert: alert,
              onTap: () =>
                  context.push(AppRoutes.alertDetails(alert.id), extra: alert),
            );
          },
        ),
      ),
    );
  }

  void _clearFilters(AlertHistoryListCubit cubit) {
    _searchController.clear();
    cubit.clearAll();
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
    await blocContext.read<AlertHistoryListCubit>().applyFilter(filter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

/// The row after the last alert: a spinner while the next page loads, or
/// a retry when it failed.
class _LoadMoreFooter extends StatelessWidget {
  const _LoadMoreFooter({required this.failed, required this.onRetry});

  final bool failed;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: failed
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l.alertLoadMoreFailed,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  TextButton(onPressed: onRetry, child: Text(l.retry)),
                ],
              )
            : const LoadingIndicatorWidget(),
      ),
    );
  }
}
