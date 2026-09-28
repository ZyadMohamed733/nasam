import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/user_type.dart';
import '../cubit/current_user_cubit.dart';
import '../cubit/logout_cubit.dart';

/// [AppDrawer] for the signed-in user: their name and role, and sign-out
/// wired to a [LogoutCubit].
///
/// Hosts drop this in where the drawer goes; they do not handle sign-out
/// themselves. Nothing here navigates — the route guard moves the user to
/// login once the session ends.
class SessionDrawer extends StatelessWidget {
  const SessionDrawer({
    super.key,
    this.showBackground = true,
    this.selected,
    this.onSelect,
    this.available = const {DrawerDestination.trackingDashboard},
    this.cubit,
    this.currentUserCubit,
  });

  final bool showBackground;

  /// Where the user is now, and what to do when an entry is tapped; see
  /// [AppDrawer.selected] and [AppDrawer.onSelect].
  final DrawerDestination? selected;
  final ValueChanged<DrawerDestination>? onSelect;
  final Set<DrawerDestination> available;

  /// Injected in tests; resolved from the container otherwise.
  final LogoutCubit? cubit;
  final CurrentUserCubit? currentUserCubit;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LogoutCubit>(create: (_) => cubit ?? getIt<LogoutCubit>()),
        BlocProvider<CurrentUserCubit>(
          create: (_) =>
              (currentUserCubit ?? getIt<CurrentUserCubit>())..load(),
        ),
      ],
      child: Builder(
        builder: (context) {
          final logout = context.watch<LogoutCubit>().state;
          final user = switch (context.watch<CurrentUserCubit>().state) {
            CurrentUserLoaded(:final user) => user,
            _ => null,
          };
          return AppDrawer(
            showBackground: showBackground,
            loggingOut: logout is! LogoutIdle,
            onLogout: context.read<LogoutCubit>().logout,
            selected: selected,
            onSelect: onSelect,
            available: available,
            profileName: user == null ? null : _displayName(context, user),
            profileRole: user == null ? null : _role(context, user.type),
          );
        },
      ),
    );
  }

  /// The name in the reader's language when the account has one, the other
  /// one when it does not, and the username as a last resort.
  static String _displayName(BuildContext context, UserEntity user) {
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final preferred = arabic ? user.nameAr : user.nameEn;
    final other = arabic ? user.nameEn : user.nameAr;
    for (final name in [preferred, other]) {
      if (name != null && name.trim().isNotEmpty) return name;
    }
    return user.username;
  }

  static String _role(BuildContext context, UserType type) {
    final l = AppLocalizations.of(context)!;
    return switch (type) {
      UserType.admin => l.userTypeAdmin,
      UserType.employee => l.userTypeEmployee,
      UserType.clientAdmin => l.userTypeClientAdmin,
      UserType.clientEmployee => l.userTypeClientEmployee,
    };
  }
}
