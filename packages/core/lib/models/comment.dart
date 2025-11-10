import 'package:core/core.dart';

enum BackgroundColorType {
  red,
  orange,
  yellow,
  green,
  blue,
  purple,
  pink;

  factory BackgroundColorType.fromString(String value) {
    return switch (value) {
      'red' => BackgroundColorType.red,
      'orange' => BackgroundColorType.orange,
      'yellow' => BackgroundColorType.yellow,
      'green' => BackgroundColorType.green,
      'blue' => BackgroundColorType.blue,
      'purple' => BackgroundColorType.purple,
      'pink' => BackgroundColorType.pink,
      _ => BackgroundColorType.blue,
    };
  }
}

class Comment {
  final String id;
  final String content;
  final Animals animal;
  final BackgroundColorType backgroundColor;

  final String postId;

  final String? parentCommentId;
  final List<Comment> children;

  final DateTime createdAt;

  const Comment({
    required this.id,
    required this.content,
    required this.animal,
    required this.backgroundColor,
    required this.postId,
    this.parentCommentId,
    this.children = const [],
    required this.createdAt,
  });
}
