import 'dart:async';

import 'package:core/core.dart';
import 'package:core_remote_data/core_remote_data.dart';

abstract interface class PostApis implements BaseRepository<Post> {
  FutureOr<Post?> getPostBySlug(String slug);
  FutureOr<List<TagSidebar>> getSidebarPostsByTags({
    String? tagNameFilter,
  });

  /// Creates a new post (admin only).
  FutureOr<Post> createPost(Post post);

  /// Updates an existing post (admin only).
  FutureOr<Post> updatePost(Post post);
}
