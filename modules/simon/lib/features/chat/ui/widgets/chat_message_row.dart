import 'package:chat/chat.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:simon/simon.dart';

class ChatMessageRow extends StatelessWidget {
  final ChatMessage message;

  final bool isSame;
  final bool isPreviousSame;
  final bool isNextSame;

  const ChatMessageRow({
    super.key,
    required this.message,
    required this.isSame,
    required this.isPreviousSame,
    required this.isNextSame,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final textStyle = theme.textTheme.bodySmall;
    final avatarWidget = AnimalAvatar(
      animal: message.avatarName,
      background: message.avatarBackgroundColor,
      size: Spacing.d16,
    );

    final outerRadius = Spacing.smoothR24.topLeft;
    final innerRadius = Spacing.smoothR8.topRight;
    const zeroRadius = SmoothRadius.zero;
    return Align(
      alignment: switch (isSame) {
        true => Alignment.centerRight,
        false => Alignment.centerLeft,
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: Spacing.d16,
        ),
        child: Column(
          crossAxisAlignment: switch (isSame) {
            true => CrossAxisAlignment.end,
            false => CrossAxisAlignment.start,
          },
          children: [
            if (!isPreviousSame) ...[
              Spacing.v16,
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isSame) ...[
                    avatarWidget,
                    Spacing.h8,
                  ],
                  Flexible(
                    child: Text(
                      message.senderName,
                      style: textStyle,
                    ),
                  ),
                  if (isSame) ...[
                    Spacing.h8,
                    avatarWidget,
                  ],
                ],
              ),
            ],
            Container(
              margin: EdgeInsets.only(
                top: !isPreviousSame ? Spacing.d6 : Spacing.d2,
                left: !isSame ? Spacing.d24 : 0.0,
              ),
              decoration: ShapeDecoration(
                color: switch (isSame) {
                  false => theme.colorScheme.surface,
                  true => theme.primaryColor.withValues(alpha: 0.25),
                },
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius.only(
                    topLeft: !isSame && !isPreviousSame
                        ? zeroRadius
                        : isPreviousSame
                        ? innerRadius
                        : outerRadius,
                    topRight: isSame && !isPreviousSame
                        ? zeroRadius
                        : isPreviousSame
                        ? innerRadius
                        : outerRadius,
                    bottomLeft: isNextSame ? innerRadius : outerRadius,
                    bottomRight: isNextSame ? innerRadius : outerRadius,
                  ),
                ),
              ),
              padding: EdgeInsets.symmetric(
                vertical: Spacing.d8,
                horizontal: Spacing.d16,
              ),
              child: Text(
                message.message,
                style: textStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
