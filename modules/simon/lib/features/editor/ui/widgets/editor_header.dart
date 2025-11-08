import 'package:core/models/post.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class EditorHeader extends StatelessWidget {
  final Post selectedPost;

  const EditorHeader(
    this.selectedPost, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:  EdgeInsets.all(Spacing.d16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              selectedPost.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
        ],
      ),
    );
  }
}
