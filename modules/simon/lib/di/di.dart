import 'package:core/core.dart';
import 'package:core_remote_data/core_remote_data.dart';
import 'package:simon/content/content.dart';

class Injector {
  static Future<void> init() async {
    injector.registerLazySingleton<UserApis>(
      () => MockUserApis(),
    );
    injector.registerLazySingleton<CommentApis>(
      () => MockCommentApis(),
    );
    injector.registerLazySingleton<PostApis>(
      () => MockPostApis(),
    );
  }

  static Future<void> dispose() async {
    await injector.resetLazySingleton<PostApis>();
    await injector.resetLazySingleton<CommentApis>();
    await injector.resetLazySingleton<UserApis>();
  }
}
