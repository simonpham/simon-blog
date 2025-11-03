import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:platform_utils/platform_utils.dart';
import 'package:simon/simon.dart' as simon;
import 'package:simon_web/app.dart';

export 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  usePathUrlStrategy();

  await ThemeConfigs().init();

  await injector.reset();
  await Injector.init();
  await simon.Injector.init();

  await EasyBox.initialize(subDir: kDataFolderName);
  await SettingsBox().init();

  runApp(
    const SimonWeb(),
  );
}
