import 'package:flutter/material.dart';
import '../../../../app/app_config.dart';
import '../../../../core/constants/app_colors.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Login Screen Placeholder',
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 24),
            const _FlavorDebugBanner(),
          ],
        ),
      ),
    );
  }
}
class _FlavorDebugBanner extends StatelessWidget {
  const _FlavorDebugBanner();

  @override
  Widget build(BuildContext context) {
    final color = switch (AppConfig.flavor) {
      Flavor.dev => Colors.green,
      Flavor.staging => Colors.orange,
      Flavor.prod => Colors.red,
    };

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppConfig.flavor.name.toUpperCase(),
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text('App name: ${AppConfig.appName}'),
          Text('Base URL: ${AppConfig.baseUrl}'),
          Text('WS URL: ${AppConfig.wsUrl}'),
         // Text('Timeouts: ${AppConfig.connectTimeoutMs}ms / ${AppConfig.receiveTimeoutMs}ms'),
        ],
      ),
    );
  }
}