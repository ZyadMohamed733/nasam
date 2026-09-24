import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../cubit/logout_cubit.dart';

/// [AppDrawer] with sign-out wired to a [LogoutCubit].
///
/// Hosts drop this in where the drawer goes; they do not handle sign-out
/// themselves. Nothing here navigates — the route guard moves the user to
/// login once the session ends.
class SessionDrawer extends StatelessWidget {
  const SessionDrawer({super.key, this.showBackground = true, this.cubit});

  final bool showBackground;

  /// Injected in tests; resolved from the container otherwise.
  final LogoutCubit? cubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LogoutCubit>(
      create: (_) => cubit ?? getIt<LogoutCubit>(),
      child: BlocBuilder<LogoutCubit, LogoutState>(
        builder: (context, state) => AppDrawer(
          showBackground: showBackground,
          loggingOut: state is! LogoutIdle,
          onLogout: context.read<LogoutCubit>().logout,
        ),
      ),
    );
  }
}
