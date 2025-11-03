class Comment {
  final String id;
  final String content;
  final String authorName;
  final String? authorEmail;

  final String postId;

  final String? parentCommentId;
  final List<Comment> children;

  final DateTime createdAt;

  const Comment({
    required this.id,
    required this.content,
    required this.authorName,
    this.authorEmail,
    required this.postId,
    this.parentCommentId,
    this.children = const [],
    required this.createdAt,
  });
}
