import 'package:core/core.dart';
import 'package:flutter/material.dart';

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

  Color get color {
    const baseColor = 100;
    final color = switch (this) {
      BackgroundColorType.red => Colors.red[baseColor],
      BackgroundColorType.orange => Colors.orange[baseColor],
      BackgroundColorType.yellow => Colors.yellow[baseColor],
      BackgroundColorType.green => Colors.green[baseColor],
      BackgroundColorType.blue => Colors.blue[baseColor],
      BackgroundColorType.purple => Colors.purple[baseColor],
      BackgroundColorType.pink => Colors.pink[baseColor],
    };
    return color ?? Colors.orange;
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
