part of 'settings.dart';

enum CoreSettings {
  language,
  appTheme,
  enableTransparency,
  screenSize,
  isSideBarExpanded,
}

extension CoreSettingsExt on SettingsBox {
  String get language {
    final String savedLanguage = get(
      CoreSettings.language,
      defaultValue: kDeviceLanguage,
    );
    if (!kSupportedLanguages.keys.contains(savedLanguage)) {
      return kDefaultLanguage;
    }
    return savedLanguage;
  }

  set language(String value) => put(CoreSettings.language, value);

  ThemeMode get appTheme {
    final rawData = get(
      CoreSettings.appTheme,
      defaultValue: ThemeMode.system.name,
    );
    return ThemeMode.values.firstWhere(
      (e) => e.name == '$rawData',
      orElse: () => ThemeMode.system,
    );
  }

  set appTheme(ThemeMode value) => put(CoreSettings.appTheme, value.name);

  ScreenSize get screenSize {
    final index = get(
      CoreSettings.screenSize,
      defaultValue: ScreenSize.normal.index,
    );
    return ScreenSize.values[index];
  }

  bool get enableTransparency => kIsDesktop
      ? get(
          CoreSettings.enableTransparency,
          defaultValue: kIsDesktop,
        )
      : false;

  set enableTransparency(bool value) => put(
    CoreSettings.enableTransparency,
    value,
  );

  set screenSize(ScreenSize value) => put(
    CoreSettings.screenSize,
    value.index,
  );

  bool get isSideBarExpanded => get(
    CoreSettings.isSideBarExpanded,
    defaultValue: true,
  );

  set isSideBarExpanded(bool value) => put(
    CoreSettings.isSideBarExpanded,
    value,
  );
}
