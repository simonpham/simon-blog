// ignore_for_file: depend_on_referenced_packages

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/themes/tomorrow-night-eighties.dart'
    as tomorrow;
import 'package:flutter_highlight/themes/tomorrow.dart' as tomorrow;
import 'package:icons/icons.dart';
import 'package:markdown_widget/markdown_widget.dart';

class MarkdownContent extends StatelessWidget {
  final String content;

  const MarkdownContent(this.content);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final config = isDark
        ? MarkdownConfig.darkConfig
        : MarkdownConfig.defaultConfig;
    final codeDecoration = ShapeDecoration(
      color: context.theme.cardColor,
      shape: SmoothRectangleBorder(
        borderRadius: Spacing.smoothR12,
      ),
    );
    Widget codeWrapper(child, text, language) => Container(
      decoration: codeDecoration,
      child: Stack(
        children: [
          Positioned(
            child: SelectionArea(
              child: child,
            ),
          ),
          Positioned(
            top: Spacing.d8,
            right: Spacing.d8,
            child: Button(
              padding: EdgeInsets.all(Spacing.d8),
              variant: ButtonVariant.ghost,
              child: ImageView(
                Assets.copy01,
                size: Spacing.d16,
                color: context.theme.colorScheme.onSurface,
              ),
              onPressed: () {
                Clipboard.setData(
                  ClipboardData(text: text),
                );
                context.toast(
                  'Copied to clipboard',
                  type: MessageType.success,
                );
              },
            ),
          ),
        ],
      ),
    );
    final codeTextStyle = const TextStyle(
      fontSize: 13,
    ).apply(fontFamily: kCodeFontFamily);
    return MarkdownWidget(
      selectable: false,
      config: config.copy(
        configs: [
          switch (isDark) {
            true => PreConfig.darkConfig.copy(
              decoration: const BoxDecoration(),
              wrapper: codeWrapper,
              textStyle: codeTextStyle,
              styleNotMatched: codeTextStyle,
              theme: tomorrow.tomorrowNightEightiesTheme,
            ),
            false => const PreConfig().copy(
              decoration: const BoxDecoration(),
              wrapper: codeWrapper,
              textStyle: codeTextStyle,
              styleNotMatched: codeTextStyle,
              theme: tomorrow.tomorrowTheme,
            ),
          },
        ],
      ),
      padding: EdgeInsets.symmetric(
        vertical: Spacing.d16,
        horizontal: Spacing.d24,
      ),
      data: content,
    );
  }
}
