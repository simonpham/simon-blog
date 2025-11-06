import 'package:platform_utils/platform_utils.dart';
export 'package:flutter/foundation.dart' show kIsWeb;

export 'strings.dart';

bool get kIsDesktop =>
    Platform.isWindows || Platform.isLinux || Platform.isMacOS;
