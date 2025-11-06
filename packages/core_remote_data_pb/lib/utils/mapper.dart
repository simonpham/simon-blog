import 'package:core/models/post.dart';
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
