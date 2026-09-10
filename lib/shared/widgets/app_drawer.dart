import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/di/injection_container.dart';
import '../../core/router/app_routes.dart';
import '../../core/services/auth_service.dart';
import 'app_scaffold.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = getIt<AuthService>();

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
              style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white),
            ),
            accountEmail: Text(
              'operator@nasam.app',
              style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white70),
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
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16, vertical: AppSizes.p16),
            child: Divider(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.logout_rounded,
              color: AppColors.error,
            ),
            title: Text(
              'Logout',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () async {
              Navigator.pop(context); // Close drawer
              await authService.logout();
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
