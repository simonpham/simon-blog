import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:simon_web/router.dart';

class SimonWeb extends StatelessWidget {
  const SimonWeb({super.key});

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
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: ThemeConfigs().theme.getTheme(
              isDark: false,
              fontFamily: kAppFontFamily,
            ),
            darkTheme: ThemeConfigs().theme.getTheme(
              isDark: true,
              fontFamily: kAppFontFamily,
            ),
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
}
