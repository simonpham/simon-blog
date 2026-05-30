import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:simon_web/router.dart';

class SimonWeb extends StatelessWidget {
  final AppTheme lightTheme;
  final AppTheme darkTheme;

  const SimonWeb({
    super.key,
    required this.lightTheme,
    required this.darkTheme,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: SettingsBox(),
      child: ValueListenableBuilder(
        valueListenable: [
          CoreSettings.language,
          CoreSettings.appTheme,
          CoreSettings.enableTransparency,
        ].of(SettingsBox()),
        builder: (context, _, _) {
          final lightThemeData = _getThemeData(lightTheme, isDark: false);
          final darkThemeData = _getThemeData(darkTheme, isDark: true);

          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: lightThemeData,
            darkTheme: darkThemeData,
            themeMode: SettingsBox().appTheme,
            routerConfig: kAppRouter,
            locale: Locale(SettingsBox().language),
            builder: (context, child) {
              final size = ScreenSize.of(context);
              SettingsBox().screenSize = size;
              printLog('[ScreenSize]: ${size.name}');
              return child!;
            },
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
          );
        },
      ),
    );
  }

  ThemeData _getThemeData(AppTheme appTheme, {required bool isDark}) {
    final themeData = appTheme.getTheme(
      isDark: isDark,
      fontFamily: kAppFontFamily,
    );
    final surface = isDark
        ? appTheme.colors.neutral6
        : appTheme.colors.neutral2;

    return themeData.copyWith(
      colorScheme: themeData.colorScheme.copyWith(
        surface: surface,
      ),
    );
  }
}
