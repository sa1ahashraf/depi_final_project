import 'package:depi_final_project/core/routing/app_router.dart';
import 'package:depi_final_project/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MosaedApp extends StatelessWidget {
  const MosaedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,

      // Application Theme
      theme: AppTheme.lightTheme,

      // Language
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],

      // Localization Delegates
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Navigation
      routerConfig: AppRouter.router,
    );
  }
}
