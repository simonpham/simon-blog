import 'package:core/models/post.dart';
import 'package:core/models/sidebar_post.dart';
import 'package:core_remote_data_pb/core_remote_data_pb.dart' as pb;

extension PostMapper on pb.Post {
  Post toModel() {
    return Post(
      id: id,
      title: title,
      slug: slug,
      content: content,
      summary: summary,
      authorId: authorId,
      tags: tags.toList(),
      featuredImageUrl: featuredImageUrl,
      status: switch (status) {
        pb.PostStatus.draft => PostStatus.draft,
        pb.PostStatus.published => PostStatus.published,
        pb.PostStatus.archived => PostStatus.archived,
        _ => PostStatus.draft,
      },
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        createdAt.toInt(),
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        updatedAt.toInt(),
      ),
      commentsCount: commentsCount,
      likesCount: likesCount,
      readTimeMinutes: readTimeMinutes,
      visibility: switch (visibility) {
        pb.PostVisibility.public => PostVisibility.public,
        pb.PostVisibility.private => PostVisibility.private,
        pb.PostVisibility.unlisted => PostVisibility.unlisted,
        _ => PostVisibility.public,
      },
    );
  }
}

extension SidebarPostMapper on pb.SidebarPost {
  SidebarPost toModel() {
    return SidebarPost(
      id: id,
      title: title,
      slug: slug,
    );
  }
}

extension TagSidebarMapper on pb.TagSidebar {
  TagSidebar toModel() {
    return TagSidebar(
      tagName: tagName,
      posts: posts.map((post) => post.toModel()).toList(),
    );
  }
}
