import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../app/app_config.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/di/injection_container.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final config = getIt<AppConfig>();

    // Never in a release build, and never in production: this prints the API
    // and socket hosts to anyone who reaches the login screen.
    final showFlavorBanner = kDebugMode && !config.isProd;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Login Screen Placeholder',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            if (showFlavorBanner) ...[
              const SizedBox(height: AppSizes.p24),
              _FlavorDebugBanner(config: config),
            ],
          ],
        ),
      ),
    );
  }
}

class _FlavorDebugBanner extends StatelessWidget {
  const _FlavorDebugBanner({required this.config});

  final AppConfig config;

  @override
  Widget build(BuildContext context) {
    final color = switch (config.flavor) {
      Flavor.dev => Colors.green,
      Flavor.staging => Colors.orange,
      Flavor.prod => Colors.red,
    };

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.p24),
      padding: const EdgeInsets.all(AppSizes.p12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(AppSizes.r8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            config.flavor.name.toUpperCase(),
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSizes.p4),
          Text('App name: ${config.appName}'),
          Text('Base URL: ${config.baseUrl}'),
          Text('WS URL: ${config.wsUrl}'),
        ],
      ),
    );
  }
}
