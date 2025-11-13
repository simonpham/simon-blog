import 'package:chat/chat.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:simon/simon.dart';

class ChatMessageRow extends StatelessWidget {
  final ChatMessage message;
  final bool isSame;

  const ChatMessageRow({
    super.key,
    required this.message,
    required this.isSame,
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
          animal: message.avatarName,
          background: message.avatarBackgroundColor,
          size: textStyle?.fontSize ?? 0.0,
        ),
        Spacing.h8,
        Expanded(
          child: SelectableText.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '@${message.senderName}: ',
                  style: textStyle?.copyWith(
                    color: isSame ? theme.primaryColor : null,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: message.message,
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
