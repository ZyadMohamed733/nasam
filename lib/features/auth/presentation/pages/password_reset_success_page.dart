import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/success_screen.dart';

class PasswordResetSuccessPage extends StatelessWidget {
  const PasswordResetSuccessPage({super.key});

  @override
  Widget build(BuildContext context) => SuccessScreen(
    title: context.l10n.newPasswordDone,
    actionLabel: context.l10n.loginSubmit,
    onAction: () => context.go(AppRoutes.login),
  );
}
