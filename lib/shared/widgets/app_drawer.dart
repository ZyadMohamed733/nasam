import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/di/injection_container.dart';
import '../../core/router/app_routes.dart';
import '../../core/services/auth_service.dart';

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
                size: AppSizes.iconLg.r,
                color: isDark ? Colors.white : AppColors.primary,
              ),
            ),
            accountName: Text(
              'Nasam Fleet Operator',
              style: AppTextStyles.h3.copyWith(color: Colors.white),
            ),
            accountEmail: Text(
              'operator@nasam.app',
              style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
            ),
          ),
          
          // Navigation Items
          ListTile(
            leading: Icon(
              Icons.dashboard_rounded,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
            title: Text(
              'Dashboard',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            onTap: () {
              Navigator.pop(context); // Close drawer
              context.go(AppRoutes.home);
            },
          ),
          const Spacer(),
          
          // Logout Button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.p16.w, vertical: AppSizes.p16.h),
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
              style: AppTextStyles.bodyMedium.copyWith(
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
          SizedBox(height: AppSizes.p24.h),
        ],
      ),
    );
  }
}
