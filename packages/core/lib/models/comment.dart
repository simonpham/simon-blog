class Comment {
  final String id;
  final String content;
  final String authorName;
  final String? authorEmail;
  final DateTime createdAt;

  const Comment({
    required this.id,
    required this.content,
    required this.authorName,
    this.authorEmail,
    required this.createdAt,
  });
}
