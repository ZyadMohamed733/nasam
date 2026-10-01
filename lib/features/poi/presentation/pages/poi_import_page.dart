import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_form_bottom_bar.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../../../shared/widgets/app_stepper.dart';
import '../cubit/poi_import_cubit.dart';
import '../widgets/import/poi_import_confirm_view.dart';
import '../widgets/import/poi_import_layout.dart';
import '../widgets/import/poi_import_preview_view.dart';
import '../widgets/import/poi_import_upload_view.dart';
import '../widgets/import/poi_import_validation_view.dart';

/// The POI bulk upload (`647:7950`–`647:8007`): the header, the stepper,
/// the current step's body and its actions. Each step's body is its own
/// widget; this page only arranges them.
class PoiImportPage extends StatelessWidget {
  const PoiImportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final s = context.semanticColors;
    return BlocBuilder<PoiImportCubit, PoiImportState>(
      builder: (context, state) {
        final done = state.step is PoiImportConfirmStep;
        return PopScope(
          canPop: !state.busy,
          child: Scaffold(
            backgroundColor: s.pageBackground,
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  AppPageHeader(
                    title: l.poiImportTitle,
                    subtitle: l.poiImportSubtitle,
                    showDivider: true,
                    onBack: () {
                      if (!state.busy) context.pop(done);
                    },
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: PoiImportLayout.maxWidth,
                        ),
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(
                            PoiImportLayout.gutter,
                            PoiImportLayout.contentTop,
                            PoiImportLayout.gutter,
                            PoiImportLayout.gutter,
                          ),
                          children: [
                            AppStepper(
                              steps: [
                                l.poiUploadStep,
                                l.poiValidate,
                                l.poiPreview,
                                l.poiConfirm,
                              ],
                              // Confirm is the end: every step done.
                              current: done ? 4 : state.step.index,
                            ),
                            const SizedBox(height: PoiImportLayout.stepperGap),
                            if (state.error) _Error(state: state),
                            switch (state.step) {
                              PoiImportUploadStep() => PoiImportUploadView(
                                state: state,
                              ),
                              PoiImportValidationStep() =>
                                PoiImportValidationView(state: state),
                              PoiImportPreviewStep() => PoiImportPreviewView(
                                state: state,
                              ),
                              PoiImportConfirmStep(:final summary) =>
                                PoiImportConfirmView(summary: summary),
                            },
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: _BottomBar(state: state),
          ),
        );
      },
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.state});

  final PoiImportState state;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: PoiImportLayout.stepperGap),
      child: Text(
        state.step is PoiImportUploadStep ? l.poiInvalidFile : l.errorGeneric,
        style: AppTextStyles.bodyMR.copyWith(
          color: context.semanticColors.failText,
        ),
      ),
    );
  }
}

/// Each step's actions; Confirm has none.
class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.state});

  final PoiImportState state;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cubit = context.read<PoiImportCubit>();
    final idle = !state.busy;
    return switch (state.step) {
      PoiImportUploadStep() => AppFormBottomBar(
        primaryLabel: l.poiValidate,
        onPrimary: idle && state.file != null ? cubit.validate : null,
        loading: state.busy && state.file != null,
        cancelLabel: l.poiCancel,
        onCancel: idle ? () => context.pop() : null,
      ),
      PoiImportValidationStep() => AppFormBottomBar(
        primaryLabel: l.poiPreview,
        onPrimary: idle && state.validRows.isNotEmpty ? cubit.preview : null,
        cancelLabel: l.poiPrevious,
        cancelVariant: AppButtonVariant.tertiary,
        onCancel: idle ? cubit.previous : null,
      ),
      PoiImportPreviewStep() => AppFormBottomBar(
        primaryLabel: l.poiConfirm,
        onPrimary: idle ? cubit.confirm : null,
        loading: state.busy,
        cancelLabel: l.poiPrevious,
        cancelVariant: AppButtonVariant.tertiary,
        onCancel: idle ? cubit.previous : null,
      ),
      PoiImportConfirmStep() => const SizedBox.shrink(),
    };
  }
}
