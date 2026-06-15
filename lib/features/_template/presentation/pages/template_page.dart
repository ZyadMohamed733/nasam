import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../bloc/template_bloc.dart';
import '../bloc/template_event.dart';
import '../bloc/template_state.dart';
import '../widgets/template_card_widget.dart';

class TemplatePage extends StatelessWidget {
  const TemplatePage({
    super.key,
    required this.id,
  });

  final String id;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TemplateBloc>()..add(LoadTemplate(id)),
      child: Scaffold(
        body: BlocBuilder<TemplateBloc, TemplateState>(
          builder: (context, state) {
            return state.when(
              initial: () => const SizedBox.shrink(),
              loading: () => const LoadingWidget(),
              success: (entity) => AppScaffold(
                title: 'Template Details',
                body: Padding(
                  padding: EdgeInsets.all(AppSizes.p16.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TemplateCardWidget(entity: entity),
                    ],
                  ),
                ),
              ),
              failure: (failure) => AppScaffold(
                title: 'Error',
                body: AppErrorWidget(
                  message: failure.message,
                  onRetry: () => context.read<TemplateBloc>().add(LoadTemplate(id)),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
