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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authService = getIt<AuthService>();

    return Drawer(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      child: Column(
        children: [
          // Drawer Header
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.primary,
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: isDark ? AppColors.primaryLight : Colors.white,
              child: Icon(
                Icons.person_rounded,
                size: AppSizes.iconLg,
                color: isDark ? Colors.white : AppColors.primary,
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
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
              title: Text(
                destination.label,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
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
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
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
