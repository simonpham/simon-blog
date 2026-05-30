import 'package:design_system/design_system.dart';
import 'package:flutter/widgets.dart';
import 'package:html/dom.dart' as dom;
import 'package:ui_markdown/ui/markdown_preview/markdown_preview_style.dart';
import 'package:ui_markdown/ui/markdown_preview/syntax_highlighted_code.dart';

class MarkdownFactory extends WidgetFactory {
  final MarkdownPreviewStyle mdStyle;
  final Uri? baseUrl;

  MarkdownFactory(this.mdStyle, {this.baseUrl});

  @override
  Widget? buildImageWidget(BuildTree tree, ImageSource src) {
    var url = src.url;
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return super.buildImageWidget(tree, src);
    }

    if (uri.scheme.isEmpty && baseUrl != null) {
      url = baseUrl!.resolveUri(uri).toString();
    }

    return ClipRRect(
      borderRadius: Spacing.smoothR6,
      child: ImageView(
        url,
        width: src.width,
        height: src.height,
      ),
    );
  }

  @override
  void parse(BuildTree tree) {
    final element = tree.element;

    if (element.localName == 'pre') {
      final firstChild = element.children.isNotEmpty
          ? element.children.first
          : null;
      if (firstChild?.localName == 'code') {
        final code = firstChild!.text.trimRight();
        final langClass = firstChild.classes
            .where((className) => className.startsWith('language-'))
            .firstOrNull;
        final language =
            langClass?.replaceFirst('language-', '') ??
            SyntaxHighlightedCode.defaultLanguage;

        tree.register(
          BuildOp(
            onRenderBlock: (_, _) => SyntaxHighlightedCode(
              code: code,
              language: language,
              mdStyle: mdStyle,
            ),
          ),
        );
        return;
      }
    }

    if (element.localName == 'code' && !_isInsidePre(element)) {
      final code = element.text;
      tree.register(
        BuildOp.inline(
          onRenderInlineBlock: (_, _) => SyntaxHighlightedCode(
            code: code,
            language: '',
            mdStyle: mdStyle,
            isInline: true,
          ),
        ),
      );
      return;
    }

    if (element.localName == 'input' &&
        element.attributes['type'] == 'checkbox') {
      final checked = element.attributes.containsKey('checked');
      tree.register(
        BuildOp(
          onRenderBlock: (_, _) => _buildCheckbox(checked),
        ),
      );
      return;
    }

    super.parse(tree);
  }

  Widget _buildCheckbox(bool checked) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: SizedBox(
        width: 16,
        height: 16,
        child: Center(
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              border: Border.all(
                color: checked
                    ? mdStyle.checkboxColor
                    : mdStyle.tableBorderColor,
                width: 1.5,
              ),
              color: checked
                  ? mdStyle.checkboxColor.withValues(alpha: 0.15)
                  : null,
            ),
            child: checked
                ? Icon(
                    const IconData(0x2713),
                    size: 10,
                    color: mdStyle.checkboxColor,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

CustomStylesBuilder buildCustomStylesBuilder(MarkdownPreviewStyle style) {
  return (dom.Element element) {
    final tag = element.localName;

    return switch (tag) {
      'pre' => {
        'background-color': _colorToCss(style.codeBlockBackground),
        'border-radius': '${style.codeBlockBorderRadius.topLeft.x}px',
        'padding': _edgeInsetsToCss(style.codeBlockPadding),
        'margin': '8px 0',
        'overflow-x': 'auto',
      },
      'code' when !_isInsidePre(element) => {
        'background-color': _colorToCss(style.inlineCodeBackground),
        'padding': '2px 6px',
        'border-radius': '4px',
        'font-size': '${style.inlineCodeTextStyle.fontSize ?? 13}px',
      },
      'code' => {
        'background-color': _colorToCss(style.codeBlockBackground),
        'font-size': '${style.codeTextStyle.fontSize ?? 13}px',
      },
      'blockquote' => {
        'border-left': '3px solid ${_colorToCss(style.blockquoteBorderColor)}',
        'background-color': _colorToCss(style.blockquoteBackground),
        'padding': _edgeInsetsToCss(style.blockquotePadding),
        'margin': '8px 0',
      },
      'table' => {
        'border-collapse': 'collapse',
        'margin': '8px 0',
      },
      'th' => {
        'background-color': _colorToCss(style.tableHeaderBackground),
        'border': '1px solid ${_colorToCss(style.tableBorderColor)}',
        'padding': '6px 12px',
        'font-weight': 'bold',
      },
      'td' => {
        'border': '1px solid ${_colorToCss(style.tableBorderColor)}',
        'padding': '6px 12px',
      },
      'hr' => {
        'border-top': '1px solid ${_colorToCss(style.hrColor)}',
        'margin': '16px 0',
      },
      'a' => {
        'color': _colorToCss(style.linkColor),
        'text-decoration': 'none',
      },
      'img' => {
        'max-width': '100%',
        'border-radius': '6px',
      },
      'h1' => {
        'color': _colorToCss(style.headingColor),
        'border-bottom': '1px solid ${_colorToCss(style.hrColor)}',
        'padding-bottom': '4px',
        'margin': '24px 0 16px 0',
      },
      'h2' => {
        'color': _colorToCss(style.headingColor),
        'border-bottom': '1px solid ${_colorToCss(style.hrColor)}',
        'padding-bottom': '4px',
        'margin': '20px 0 12px 0',
      },
      'h3' || 'h4' || 'h5' || 'h6' => {
        'color': _colorToCss(style.headingColor),
        'margin': '16px 0 8px 0',
      },
      _ => null,
    };
  };
}

bool _isInsidePre(dom.Element element) {
  dom.Element? parent = element.parent;
  while (parent != null) {
    if (parent.localName == 'pre') {
      return true;
    }
    parent = parent.parent;
  }
  return false;
}

String _colorToCss(Color color) {
  final r = (color.r * 255).round();
  final g = (color.g * 255).round();
  final b = (color.b * 255).round();
  final a = color.a;
  if (a < 1.0) {
    return 'rgba($r, $g, $b, ${a.toStringAsFixed(2)})';
  }
  return '#${r.toRadixString(16).padLeft(2, '0')}'
      '${g.toRadixString(16).padLeft(2, '0')}'
      '${b.toRadixString(16).padLeft(2, '0')}';
}

String _edgeInsetsToCss(EdgeInsets insets) {
  return '${insets.top}px ${insets.right}px '
      '${insets.bottom}px ${insets.left}px';
}
