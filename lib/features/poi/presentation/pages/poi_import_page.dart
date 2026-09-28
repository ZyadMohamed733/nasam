import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../domain/entities/poi_import_row.dart';
import '../cubit/poi_import_cubit.dart';

class PoiImportPage extends StatefulWidget {
  const PoiImportPage({super.key});
  @override
  State<PoiImportPage> createState() => _PoiImportPageState();
}

class _PoiImportPageState extends State<PoiImportPage> {
  PoiRowStatus? _filter;
  int _page = 0;
  bool _savingTemplate = false;
  Future<void> _template() async {
    if (_savingTemplate) return;
    setState(() => _savingTemplate = true);
    final l = AppLocalizations.of(context)!;
    try {
      final saved = await context.read<PoiImportCubit>().saveTemplate();
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
      if (mounted) setState(() => _savingTemplate = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cubit = context.read<PoiImportCubit>();
    return BlocConsumer<PoiImportCubit, PoiImportState>(
      listenWhen: (before, after) =>
          before.step != after.step || before.fileName != after.fileName,
      listener: (_, state) => setState(() {
        _page = 0;
        _filter = null;
      }),
      builder: (context, state) => PopScope(
        canPop: !state.busy,
        child: Scaffold(
          appBar: AppBar(
            title: Text(l.poiImportTitle, style: theme.textTheme.titleMedium),
            leading: BackButton(
              onPressed: state.busy ? null : () => context.pop(state.step == 3),
            ),
          ),
          body: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: ListView(
                padding: const EdgeInsets.all(AppSizes.p16),
                children: [
                  Text(l.poiImportSubtitle, style: theme.textTheme.bodySmall),
                  const SizedBox(height: AppSizes.p20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < 4; i++)
                        Expanded(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: i == 0
                                          ? Colors.transparent
                                          : theme.colorScheme.primary,
                                    ),
                                  ),
                                  Semantics(
                                    label: '${i + 1}',
                                    selected: state.step == i,
                                    child: CircleAvatar(
                                      radius: 12,
                                      backgroundColor: i <= state.step
                                          ? theme.colorScheme.primary
                                          : theme
                                                .colorScheme
                                                .surfaceContainerHighest,
                                      child: Icon(
                                        i < state.step
                                            ? Icons.check
                                            : Icons.circle,
                                        size: i < state.step ? 14 : 6,
                                        color: i <= state.step
                                            ? theme.colorScheme.onPrimary
                                            : theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: i == 3
                                          ? Colors.transparent
                                          : theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSizes.p8),
                              Text(
                                [
                                  l.poiUploadStep,
                                  l.poiValidate,
                                  l.poiPreview,
                                  l.poiConfirm,
                                ][i],
                                textAlign: TextAlign.center,
                                style: theme.textTheme.labelSmall,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.p24),
                  if (state.error)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.p16),
                      child: Text(
                        state.step == 0 ? l.poiInvalidFile : l.errorGeneric,
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  if (state.step == 0) ...[
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            l.poiUploadStep,
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(height: AppSizes.p12),
                          AppButton(
                            label: l.poiTemplate,
                            icon: Icons.download_outlined,
                            variant: AppButtonVariant.secondary,
                            isLoading: _savingTemplate,
                            onPressed: state.busy ? null : _template,
                          ),
                          const SizedBox(height: AppSizes.p16),
                          Text(
                            l.poiFileLimits,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSizes.p16),
                    AppCard(
                      child: Column(
                        children: [
                          Icon(
                            Icons.upload_file_outlined,
                            size: 40,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: AppSizes.p12),
                          Text(
                            state.fileName ?? l.poiFileHint,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSizes.p16),
                          AppButton(
                            label: l.poiBrowse,
                            variant: AppButtonVariant.secondary,
                            isLoading: state.busy,
                            onPressed: state.busy ? null : cubit.pick,
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (state.step == 1 || state.step == 2) ...[
                    Text(
                      state.step == 1
                          ? l.poiValidationTitle
                          : l.poiPreviewTitle,
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppSizes.p12),
                    Text(l.poiValidOnly, style: theme.textTheme.bodySmall),
                    const SizedBox(height: AppSizes.p12),
                    if (state.step == 1)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final status in [null, ...PoiRowStatus.values])
                            ChoiceChip(
                              selected: _filter == status,
                              label: Text(
                                '${_label(status, l)} (${status == null ? state.rows.length : state.rows.where((r) => r.status == status).length})',
                              ),
                              onSelected: state.busy
                                  ? null
                                  : (_) => setState(() {
                                      _filter = status;
                                      _page = 0;
                                    }),
                            ),
                        ],
                      ),
                    const SizedBox(height: AppSizes.p12),
                    _table(state, l),
                  ],
                  if (state.step == 3)
                    AppCard(
                      child: Column(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 56,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: AppSizes.p16),
                          Text(
                            l.poiImportComplete,
                            style: theme.textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSizes.p24),
                          Wrap(
                            spacing: 24,
                            runSpacing: 16,
                            alignment: WrapAlignment.center,
                            children: [
                              for (final entry in {
                                l.poiTotal: state.rows.length,
                                l.poiImported: state.imported,
                                l.poiSkipped:
                                    state.rows.length - state.imported,
                              }.entries)
                                Column(
                                  children: [
                                    Text(
                                      '${entry.value}',
                                      style: theme.textTheme.headlineSmall,
                                    ),
                                    Text(entry.key),
                                  ],
                                ),
                            ],
                          ),
                          const SizedBox(height: AppSizes.p24),
                          TextButton(
                            onPressed: () => context.pop(true),
                            child: Text(l.poiShowPoints),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.p16),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: AppButton(
                      label: [
                        l.poiValidate,
                        l.poiPreview,
                        l.poiConfirm,
                        l.poiShowPoints,
                      ][state.step],
                      isLoading: state.busy,
                      onPressed: state.busy
                          ? null
                          : switch (state.step) {
                              0 =>
                                state.fileName == null ? null : cubit.validate,
                              1 => state.valid.isEmpty ? null : cubit.preview,
                              2 => cubit.confirm,
                              _ => () => context.pop(true),
                            },
                    ),
                  ),
                  if (state.step < 3) ...[
                    const SizedBox(width: AppSizes.p8),
                    Expanded(
                      child: AppButton(
                        label: state.step == 0 ? l.poiCancel : l.poiPrevious,
                        variant: AppButtonVariant.secondary,
                        onPressed: state.busy
                            ? null
                            : () {
                                if (state.step == 0) {
                                  context.pop();
                                } else {
                                  cubit.previous();
                                }
                              },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _label(PoiRowStatus? status, AppLocalizations l) => switch (status) {
    PoiRowStatus.valid => l.poiValid,
    PoiRowStatus.invalid => l.poiInvalid,
    PoiRowStatus.duplicate => l.poiDuplicate,
    null => l.poiAll,
  };
  Widget _table(PoiImportState state, AppLocalizations l) {
    final rows = state.step == 2
        ? state.valid
        : state.rows
              .where((r) => _filter == null || r.status == _filter)
              .toList();
    final pages = (rows.length / 10).ceil().clamp(1, 500);
    final page = _page.clamp(0, pages - 1);
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            dataRowMinHeight: 48,
            dataRowMaxHeight: 90,
            columnSpacing: 20,
            columns: [
              for (final title in [
                '#',
                l.poiName,
                l.poiLatitude,
                l.poiLongitude,
                l.poiIcon,
                l.poiStatus,
                l.poiReason,
              ])
                DataColumn(label: Text(title)),
            ],
            rows: [
              for (final row in rows.skip(page * 10).take(10))
                DataRow(
                  cells: [
                    for (final value in [
                      '${row.number}',
                      row.name,
                      row.latitude,
                      row.longitude,
                      row.iconName,
                      _label(row.status, l),
                      row.status == PoiRowStatus.invalid
                          ? l.poiInvalidRow
                          : row.status == PoiRowStatus.duplicate
                          ? l.poiDuplicate
                          : '—',
                    ])
                      DataCell(
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 180),
                          child: Text(
                            value,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              tooltip: MaterialLocalizations.of(context).previousPageTooltip,
              onPressed: page == 0 || state.busy
                  ? null
                  : () => setState(() => _page--),
              icon: const BackButtonIcon(),
            ),
            Text('${page + 1} / $pages'),
            IconButton(
              tooltip: MaterialLocalizations.of(context).nextPageTooltip,
              onPressed: page + 1 >= pages || state.busy
                  ? null
                  : () => setState(() => _page++),
              icon: Transform.flip(flipX: true, child: const BackButtonIcon()),
            ),
          ],
        ),
      ],
    );
  }
}
