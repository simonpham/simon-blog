import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:platform_utils/platform_utils.dart';
import 'package:ui_markdown/ui/markdown_preview/markdown_factory.dart';
import 'package:ui_markdown/ui/markdown_preview/markdown_preview_style.dart';

class MarkdownPreview extends StatelessWidget {
  final String data;
  final MarkdownPreviewStyle? style;
  final FutureOr<bool> Function(String url)? onLinkTap;
  final bool selectable;
  final Uri? baseUrl;
  final CustomWidgetBuilder? customWidgetBuilder;

  const MarkdownPreview({
    super.key,
    required this.data,
    this.style,
    this.onLinkTap,
    this.selectable = true,
    this.baseUrl,
    this.customWidgetBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = style ?? MarkdownPreviewStyle.fromTheme(context);
    final html = md.markdownToHtml(
      data,
      extensionSet: md.ExtensionSet.gitHubFlavored,
      encodeHtml: false,
    );

    Widget child = HtmlWidget(
      html,
      key: ValueKey(
        'MarkdownPreview_${context.theme.brightness}-'
        '${effectiveStyle.inlineCodeBackground.toARGB32()}-'
        '${effectiveStyle.codeBlockBackground.toARGB32()}',
      ),
      baseUrl: baseUrl,
      factoryBuilder: () => MarkdownFactory(effectiveStyle, baseUrl: baseUrl),
      customStylesBuilder: buildCustomStylesBuilder(effectiveStyle),
      customWidgetBuilder: customWidgetBuilder,
      onTapUrl: (url) async {
        if (onLinkTap != null) {
          final handled = await onLinkTap!(url);
          if (handled) return true;
        }

        final uri = Uri.tryParse(url);
        if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
          try {
            return await launchUrl(uri, mode: LaunchMode.externalApplication);
          } catch (_) {
            return false;
          }
        }

        return false;
      },
      textStyle: TextStyle(
        color: effectiveStyle.textColor,
        fontSize: 14,
        height: 1.6,
      ),
    );

    if (selectable) {
      child = SelectionArea(child: child);
    }

    return child;
  }
}
