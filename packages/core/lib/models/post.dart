import 'package:core/models/common/common.dart';

enum PostVisibility { public, private, unlisted }

enum PostStatus { draft, published, archived }

extension PostExtension on Post {
  String get fileName => '$slug.md';
}

class Post {
  final String id;
  final String title;
  final String slug;

  final String content;

  /// AI generated summary.
  final String summary;
  final String? featuredImageUrl;

  final String authorId;
  final List<String> tags;

  final PostStatus status;
  final PostVisibility visibility;

  final int commentsCount;
  final int likesCount;
  final int readTimeMinutes;

  final DateTime createdAt;
  final DateTime updatedAt;

  const Post({
    required this.id,
    required this.title,
    required this.slug,
    required this.content,
    required this.summary,
    required this.authorId,
    required this.tags,
    this.featuredImageUrl,
    this.status = PostStatus.draft,
    required this.createdAt,
    required this.updatedAt,
    this.commentsCount = 0,
    this.likesCount = 0,
    this.readTimeMinutes = 0,
    this.visibility = PostVisibility.private,
  });

  static Post newPost({
    required String title,
    required String content,
    required String summary,
    String? featuredImageUrl,
    PostStatus status = PostStatus.draft,
    required List<String> tags,
    PostVisibility visibility = PostVisibility.private,
  }) {
    return Post(
      title: title,
      content: content,
      summary: summary,
      featuredImageUrl: featuredImageUrl,
      status: status,
      visibility: visibility,
      tags: tags,
      id: '',
      slug: '',
      authorId: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      commentsCount: 0,
      likesCount: 0,
      readTimeMinutes: 0,
    );
  }
}

class PostNotFoundFailure extends Failure {
  const PostNotFoundFailure(super.message);
}
