import 'package:platform_utils/platform_utils.dart';

const String kAppFontFamily = 'Nunito';
const String kMonoFontFamily = 'Iosevka';
const String kCodeFontFamily = 'JetBrainsMono';

const String kDefaultLanguage = 'en';
const kSupportedLanguages = {
  'en': {
    'icon': 'assets/svg/flags/gb.svg',
    'title': 'English',
  },
  'vi': {
    'icon': 'assets/svg/flags/vn.svg',
    'title': 'Tiếng Việt',
  },
};

String get kDeviceLanguage {
  final localeName = Platform.localeName;
  if (localeName.contains('_')) {
    return localeName.split('_').firstOrNull ?? localeName;
  }
  return localeName;
}
