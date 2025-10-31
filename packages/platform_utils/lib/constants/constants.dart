import 'package:platform_utils/platform_utils.dart';

export 'strings.dart';

bool get kIsDesktop =>
    Platform.isWindows || Platform.isLinux || Platform.isMacOS;
