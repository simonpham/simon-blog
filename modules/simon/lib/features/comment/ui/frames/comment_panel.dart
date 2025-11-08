import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:simon/simon.dart';

class CommentPanel extends StatelessWidget {
  const CommentPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      color: theme.colorScheme.surfaceContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommentHeader(),
          const Divider(height: 1.0),
          Expanded(
            child: Container(
              color: theme.colorScheme.surface,
            ),
          ),
        ],
      ),
    );
  }
}
