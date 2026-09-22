import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/router/app_routes.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import 'app_scaffold.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, required this.logout});

  /// Injected rather than resolved from getIt inside build(), so the drawer is
  /// testable with a fake usecase.
  final LogoutUseCase logout;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: Column(
        children: [
          // Drawer Header
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.onPrimary,
              child: Icon(
                Icons.person_rounded,
                size: AppSizes.iconLg,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            accountName: Text(
              'Nasam Fleet Operator',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium!.copyWith(color: Colors.white),
            ),
            accountEmail: Text(
              'operator@nasam.app',
              style: Theme.of(
                context,
              ).textTheme.bodySmall!.copyWith(color: Colors.white70),
            ),
          ),

          // Navigation Items — shared with the tablet/desktop NavigationRail.
          for (final destination in kAppDestinations)
            ListTile(
              leading: Icon(
                destination.icon,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              title: Text(
                destination.label,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              onTap: () {
                Navigator.pop(context); // Close drawer
                context.go(destination.route);
              },
            ),
          const Spacer(),

          // Logout Button
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.p16,
              vertical: AppSizes.p16,
            ),
            child: Divider(color: Theme.of(context).colorScheme.outline),
          ),
          ListTile(
            leading: Icon(
              Icons.logout_rounded,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              'Logout',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () async {
              Navigator.pop(context); // Close drawer
              // Fire-and-forget the Either: logout() clears the local
              // session unconditionally (a best-effort server call is not a
              // precondition for it), so there is nothing meaningful to
              // branch on here -- always land back on login.
              await logout();
              if (context.mounted) {
                context.go(AppRoutes.login);
              }
            },
          ),
          const SizedBox(height: AppSizes.p24),
        ],
      ),
    );
  }
}
