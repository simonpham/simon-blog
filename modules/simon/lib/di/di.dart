import 'package:core/core.dart';
import 'package:core_remote_data/core_remote_data.dart';
import 'package:core_remote_data_pb/core_remote_data_pb.dart';
import 'package:simon/content/content.dart';

class Injector {
  static Future<void> init() async {
    const host = 'api.nowis.sofluffy.io';

    injector.registerLazySingleton<AuthApis>(
      () => RestNowisAuthApis(host: host),
    );
    injector.registerLazySingleton<UserApis>(
      () => MockUserApis(),
    );
    injector.registerLazySingleton<CommentApis>(
      () => RestCommentNowisApis(host: host),
    );
    injector.registerLazySingleton<PostApis>(
      () => RestNowisPostApis(host: host),
    );
  }

  static Future<void> dispose() async {
    await injector.resetLazySingleton<PostApis>();
    await injector.resetLazySingleton<CommentApis>();
    await injector.resetLazySingleton<UserApis>();
    await injector.resetLazySingleton<AuthApis>();
  }
}
