import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:simon/simon.dart';

class CommentInput extends StatelessWidget {
  final FocusNode focusNode;
  final TextEditingController controller;

  final AnonymousUser user;

  final ValueChanged<String> onEnter;

  const CommentInput({
    super.key,
    required this.focusNode,
    required this.controller,
    required this.user,
    required this.onEnter,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final textStyle = theme.textTheme.bodySmall;
    final animal = user.animal;
    final backgroundColor = user.backgroundColor;
    return ColoredBox(
      color: theme.colorScheme.surface,
      child: Row(
        children: [
          AnimalAvatar(
            animal: user.animal,
            background: backgroundColor,
            size: textStyle?.fontSize ?? Spacing.d24,
          ),
          Spacing.h8,
          Text(
            '@${backgroundColor.name}_${animal.name} \$ ',
            style: textStyle?.copyWith(
              color: theme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: SizedBox(
              height: Spacing.d18,
              child: InputText(
                focusNode: focusNode,
                controller: controller,
                onEditingComplete: () {
                  onEnter(controller.text);
                  controller.clear();
                },
                textInputAction: TextInputAction.send,
                decorationBuilder: (_, _, _, _) => const BoxDecoration(),
                textStyle: textStyle,
                hintText: 'Whisper your questions...',
                inputPadding: EdgeInsets.zero,
                cursorHeight: Spacing.d14,
                cursorWidth: Spacing.d4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
