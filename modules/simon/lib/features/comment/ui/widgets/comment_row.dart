import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:simon/simon.dart';

class CommentRow extends StatelessWidget {
  final Comment comment;

  final bool isSame;

  const CommentRow({
    required this.comment,
    required this.isSame,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final textStyle = theme.textTheme.bodySmall?.copyWith(
      fontFamily: kMonoFontFamily,
    );
    return Row(
      children: [
        AnimalAvatar(
          animal: comment.animal,
          background: comment.backgroundColor,
          size: textStyle?.fontSize ?? 0.0,
        ),
        Spacing.h8,
        Expanded(
          child: SelectableText.rich(
            TextSpan(
              children: [
                TextSpan(
                  text:
                      '@${comment.backgroundColor.name}_${comment.animal.name}: ',
                  style: textStyle?.copyWith(
                    color: isSame ? theme.primaryColor : null,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: comment.content,
                  style: textStyle,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
