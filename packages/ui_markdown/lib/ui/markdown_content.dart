import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
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
    final codeWrapper = (child, text, language) => Container(
      decoration: codeDecoration,
      child: child,
    );
    final codeTextStyle = const TextStyle().apply(fontFamily: kCodeFontFamily);
    return MarkdownWidget(
      selectable: false,
      config: config.copy(
        configs: [
          switch (isDark) {
            true => PreConfig.darkConfig.copy(
              decoration: const BoxDecoration(),
              wrapper: codeWrapper,
              textStyle: codeTextStyle,
            ),
            false => const PreConfig().copy(
              decoration: const BoxDecoration(),
              wrapper: codeWrapper,
              textStyle: codeTextStyle,
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
