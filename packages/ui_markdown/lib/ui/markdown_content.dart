import 'package:flutter/material.dart';
import 'package:ui_markdown/ui/markdown_preview/markdown_preview.dart';

class MarkdownContent extends StatelessWidget {
  final String content;
  final bool shrinkWrap;

  const MarkdownContent(
    this.content, {
    super.key,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    return MarkdownPreview(data: content);
  }
}
