import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:icons/icons.dart';

class ChatInput extends StatelessWidget {
  final FocusNode focusNode;
  final TextEditingController controller;

  final Animals animal;
  final BackgroundColorType backgroundColor;

  final ValueChanged<String> onEnter;

  const ChatInput({
    super.key,
    required this.focusNode,
    required this.controller,
    required this.animal,
    required this.backgroundColor,
    required this.onEnter,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final textStyle = theme.textTheme.bodySmall;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.d16,
        vertical: Spacing.d8,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.dividerColor,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: InputText(
              focusNode: focusNode,
              controller: controller,
              onEditingComplete: () {
                final text = controller.text.trim();
                if (text.isEmpty) {
                  return;
                }

                onEnter(text);
                controller.clear();
              },
              textInputAction: TextInputAction.send,
              inputPadding: EdgeInsets.symmetric(
                vertical: Spacing.d12,
                horizontal: Spacing.d16,
              ),
              textStyle: textStyle,
              hintText: 'Say something fluffy...',
            ),
          ),
          Spacing.h8,
          Spacing.h4,
          Button(
            variant: ButtonVariant.primary,
            child: ImageView(
              Assets.sent,
              size: Spacing.d20,
              color: theme.colorScheme.onPrimary,
            ),
            padding: EdgeInsets.all(Spacing.d8),
          ),
        ],
      ),
    );
  }
}
