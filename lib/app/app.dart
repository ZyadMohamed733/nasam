import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/di/injection_container.dart';
import '../core/localization/app_localizations_setup.dart';
import '../core/router/app_router.dart';
import '../core/theme/app_theme.dart';

class NasamApp extends StatelessWidget {
  const NasamApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = getIt<AppRouter>();

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Nasam',
          debugShowCheckedModeBanner: false,
          
          // Router configuration
          routerConfig: appRouter.config,
          
          // Theme configurations
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.system,
          
          // Localization configurations
          supportedLocales: AppLocalizationsSetup.supportedLocales,
          localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
          localeResolutionCallback: AppLocalizationsSetup.localeResolutionCallback,
        );
      },
    );
  }
}
