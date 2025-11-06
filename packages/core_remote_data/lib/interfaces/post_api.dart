import 'dart:async';

import 'package:core/core.dart';
import 'package:core_remote_data/core_remote_data.dart';

abstract interface class PostApis implements BaseRepository<Post> {
  FutureOr<Post?> getPostBySlug(String slug);
  FutureOr<List<TagSidebar>> getSidebarPostsByTags();
}
