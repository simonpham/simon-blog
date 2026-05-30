import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:highlight/highlight.dart' show Node, highlight;
import 'package:icons/icons.dart';
import 'package:ui_markdown/ui/markdown_preview/markdown_preview_style.dart';

class SyntaxHighlightedCode extends StatelessWidget {
  static const defaultLanguage = 'plaintext';

  final String code;
  final String language;
  final MarkdownPreviewStyle mdStyle;
  final bool isInline;

  const SyntaxHighlightedCode({
    super.key,
    required this.code,
    required this.language,
    required this.mdStyle,
    this.isInline = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isInline) {
      return RoundCard(
        borderRadius: 4,
        color: mdStyle.inlineCodeBackground,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Text(
          code,
          style: mdStyle.inlineCodeTextStyle,
        ),
      );
    }

    final effectiveLanguage = language.trim().isEmpty
        ? defaultLanguage
        : language.trim();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: mdStyle.codeBlockBackground,
        borderRadius: mdStyle.codeBlockBorderRadius,
        border: Border.all(color: mdStyle.tableBorderColor),
      ),
      child: Stack(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: mdStyle.codeBlockPadding,
            child: SelectableText.rich(
              TextSpan(
                style: mdStyle.codeTextStyle,
                children: _highlightSpans(
                  code,
                  language: effectiveLanguage,
                  theme: mdStyle.codeHighlightTheme,
                ),
              ),
            ),
          ),
          Positioned(
            top: Spacing.d4,
            right: Spacing.d4,
            child: _CopyButton(text: code),
          ),
        ],
      ),
    );
  }

  List<TextSpan> _highlightSpans(
    String source, {
    required String language,
    required Map<String, TextStyle> theme,
  }) {
    final nodes = highlight.parse(source, language: language).nodes;
    if (nodes == null) {
      return [TextSpan(text: source)];
    }
    return _convertNodes(nodes, theme);
  }

  List<TextSpan> _convertNodes(List<Node> nodes, Map<String, TextStyle> theme) {
    final spans = <TextSpan>[];
    var currentSpans = spans;
    final stack = <List<TextSpan>>[];

    void traverse(Node node) {
      if (node.value case final value?) {
        currentSpans.add(
          node.className == null
              ? TextSpan(text: value)
              : TextSpan(text: value, style: theme[node.className!]),
        );
        return;
      }

      final children = node.children;
      if (children == null) {
        return;
      }

      final nestedSpans = <TextSpan>[];
      currentSpans.add(
        TextSpan(children: nestedSpans, style: theme[node.className]),
      );
      stack.add(currentSpans);
      currentSpans = nestedSpans;

      for (final child in children) {
        traverse(child);
      }

      currentSpans = stack.isEmpty ? spans : stack.removeLast();
    }

    for (final node in nodes) {
      traverse(node);
    }

    return spans;
  }
}

class _CopyButton extends StatefulWidget {
  final String text;

  const _CopyButton({required this.text});

  @override
  State<_CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<_CopyButton> {
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    return Button(
      tooltip: 'Copy to clipboard',
      variant: ButtonVariant.ghost,
      padding: EdgeInsets.all(Spacing.d6),
      child: _copied
          ? Icon(
              Icons.check,
              size: Spacing.d12,
              color: context.themeConfigs.colors.primary,
            )
          : ImageView(
              Assets.copy01,
              size: Spacing.d12,
              color: context.theme.colorScheme.onSurface.withValues(
                alpha: 0.72,
              ),
            ),
      onPressed: () {
        Clipboard.setData(ClipboardData(text: widget.text));
        setState(() => _copied = true);
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() => _copied = false);
          }
        });
      },
    );
  }
}
