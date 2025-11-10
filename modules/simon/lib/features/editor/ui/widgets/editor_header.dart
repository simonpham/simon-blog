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
    final theme = context.theme;
    return Container(
      height: Spacing.d32,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                right: BorderSide(
                  color: theme.dividerColor,
                  width: 1.0,
                ),
              ),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.d16,
            ),
            alignment: Alignment.center,
            child: Text(
              selectedPost.fileName,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 1.0,
                color: theme.dividerColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
