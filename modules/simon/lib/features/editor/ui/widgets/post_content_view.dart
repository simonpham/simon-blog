import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:ui_markdown/ui_markdown.dart';

class PostContentView extends StatelessWidget {
  final Post post;

  const PostContentView(
    this.post, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MarkdownContent(post.content);
  }
}
