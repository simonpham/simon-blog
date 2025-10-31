import 'package:core/constants/constants.dart';
import 'package:core/core.dart'
    show injector, kDeviceLanguage, kSupportedLanguages;
import 'package:design_system/design_system.dart';
import 'package:easy_hive/easy_hive.dart';
import 'package:flutter/material.dart';
import 'package:platform_utils/platform_utils.dart';

part 'settings_core.dart';

class SettingsBox extends RefreshableBox {
  @override
  String get boxKey => 'settings';

  factory SettingsBox() => injector<SettingsBox>();

  factory SettingsBox.create() => SettingsBox._();

  SettingsBox._();
}
