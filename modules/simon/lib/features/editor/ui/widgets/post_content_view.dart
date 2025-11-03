import 'package:core/core.dart';
import 'package:flutter/material.dart';

class PostContentView extends StatelessWidget {
  final Post post;

  const PostContentView(
    this.post, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Text(post.content),
    );
  }
}
