import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/constants/app_sizes.dart';
import '../core/di/injection_container.dart';
import '../core/localization/app_localizations_setup.dart';
import '../core/router/app_router.dart';
import '../core/theme/app_theme.dart';
import 'app_settings_controller.dart';

class NasamApp extends StatelessWidget {
  const NasamApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = getIt<AppRouter>();
    final settings = getIt<AppSettingsController>();

    return ScreenUtilInit(
      designSize: const Size(AppSizes.designWidth, AppSizes.designHeight),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return ListenableBuilder(
          listenable: settings,
          builder: (context, _) => MaterialApp.router(
            title: 'Nasam',
            debugShowCheckedModeBanner: false,

            // Router configuration
            routerConfig: appRouter.config,

            // Theme configurations
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: settings.themeMode,

            // Localization configurations
            locale: settings.locale,
            supportedLocales: AppLocalizationsSetup.supportedLocales,
            localizationsDelegates:
                AppLocalizationsSetup.localizationsDelegates,
            localeResolutionCallback:
                AppLocalizationsSetup.localeResolutionCallback,
          ),
        );
      },
    );
  }
}
