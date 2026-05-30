import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/widgets.dart';

@immutable
class MarkdownPreviewStyle {
  final Color textColor;
  final Color headingColor;
  final Color linkColor;

  final Color codeBlockBackground;
  final BorderRadius codeBlockBorderRadius;
  final EdgeInsets codeBlockPadding;
  final TextStyle codeTextStyle;
  final Map<String, TextStyle> codeHighlightTheme;

  final Color inlineCodeBackground;
  final TextStyle inlineCodeTextStyle;

  final Color blockquoteBorderColor;
  final Color blockquoteBackground;
  final EdgeInsets blockquotePadding;

  final Color tableBorderColor;
  final Color tableHeaderBackground;

  final Color hrColor;
  final Color checkboxColor;

  const MarkdownPreviewStyle({
    required this.textColor,
    required this.headingColor,
    required this.linkColor,
    required this.codeBlockBackground,
    required this.codeBlockBorderRadius,
    required this.codeBlockPadding,
    required this.codeTextStyle,
    required this.codeHighlightTheme,
    required this.inlineCodeBackground,
    required this.inlineCodeTextStyle,
    required this.blockquoteBorderColor,
    required this.blockquoteBackground,
    required this.blockquotePadding,
    required this.tableBorderColor,
    required this.tableHeaderBackground,
    required this.hrColor,
    required this.checkboxColor,
  });

  factory MarkdownPreviewStyle.fromTheme(BuildContext context) {
    final theme = context.theme;
    final isDark = theme.brightness == Brightness.dark;
    final appTheme = context.themeConfigs;
    final colors = appTheme.colors;
    final onSurface = theme.colorScheme.onSurface;

    return MarkdownPreviewStyle(
      textColor: onSurface,
      headingColor: onSurface,
      linkColor: colors.primary,
      codeBlockBackground: isDark ? colors.neutral5 : colors.neutral3,
      codeBlockBorderRadius: Spacing.smoothR8,
      codeBlockPadding: EdgeInsets.all(Spacing.d12),
      codeTextStyle: TextStyle(
        fontFamily: kCodeFontFamily,
        fontSize: 13,
        height: 1.45,
        color: onSurface,
      ),
      codeHighlightTheme: isDark
          ? _ailurusDarkHighlightTheme(colors)
          : _ailurusLightHighlightTheme(colors),
      inlineCodeBackground: colors.primary.withValues(alpha: 0.12),
      inlineCodeTextStyle: TextStyle(
        fontFamily: kCodeFontFamily,
        fontSize: 13,
        color: onSurface,
      ),
      blockquoteBorderColor: colors.primary,
      blockquoteBackground: isDark ? colors.neutral7 : colors.neutral2,
      blockquotePadding: EdgeInsets.symmetric(
        horizontal: Spacing.d12,
        vertical: Spacing.d8,
      ),
      tableBorderColor: isDark ? colors.neutral5 : colors.neutral3,
      tableHeaderBackground: isDark ? colors.neutral6 : colors.neutral2,
      hrColor: isDark ? colors.neutral5 : colors.neutral3,
      checkboxColor: colors.primary,
    );
  }
}

Map<String, TextStyle> _ailurusDarkHighlightTheme(ColorData colors) {
  return {
    'root': TextStyle(
      color: colors.neutral1,
      backgroundColor: colors.neutral5,
    ),
    'comment': const TextStyle(color: Color(0xFF74838B)),
    'quote': const TextStyle(color: Color(0xFF74838B)),
    'keyword': const TextStyle(color: Color(0xFFC792EA)),
    'selector-tag': const TextStyle(color: Color(0xFFC792EA)),
    'subst': TextStyle(color: colors.neutral1),
    'number': colors.primary.textStyle,
    'literal': colors.primary.textStyle,
    'variable': TextStyle(color: colors.neutral1),
    'template-variable': const TextStyle(color: Color(0xFFD65D2E)),
    'string': const TextStyle(color: Color(0xFF87B379)),
    'doctag': const TextStyle(color: Color(0xFF87B379)),
    'title': const TextStyle(color: Color(0xFF389ECA)),
    'section': const TextStyle(color: Color(0xFF389ECA)),
    'selector-id': const TextStyle(color: Color(0xFF389ECA)),
    'type': const TextStyle(color: Color(0xFFD8A25E)),
    'class': const TextStyle(color: Color(0xFFD8A25E)),
    'tag': const TextStyle(color: Color(0xFFD8A25E)),
    'name': const TextStyle(color: Color(0xFFD8A25E)),
    'attribute': const TextStyle(color: Color(0xFF54B09E)),
    'regexp': const TextStyle(color: Color(0xFF54B09E)),
    'link': const TextStyle(color: Color(0xFF389ECA)),
    'symbol': const TextStyle(color: Color(0xFFD65D2E)),
    'bullet': const TextStyle(color: Color(0xFFD65D2E)),
    'built_in': const TextStyle(color: Color(0xFF389ECA)),
    'builtin-name': const TextStyle(color: Color(0xFF389ECA)),
    'meta': const TextStyle(color: Color(0xFF74838B)),
    'deletion': const TextStyle(color: Color(0xFFDF4B5A)),
    'addition': const TextStyle(color: Color(0xFF87B379)),
    'emphasis': const TextStyle(fontStyle: FontStyle.italic),
    'strong': const TextStyle(fontWeight: FontWeight.w700),
  };
}

Map<String, TextStyle> _ailurusLightHighlightTheme(ColorData colors) {
  return {
    'root': TextStyle(
      color: colors.neutral7,
      backgroundColor: colors.neutral3,
    ),
    'comment': const TextStyle(color: Color(0xFF889096)),
    'quote': const TextStyle(color: Color(0xFF889096)),
    'keyword': const TextStyle(color: Color(0xFF9E45AA)),
    'selector-tag': const TextStyle(color: Color(0xFF9E45AA)),
    'subst': TextStyle(color: colors.neutral7),
    'number': const TextStyle(color: Color(0xFFC44F22)),
    'literal': const TextStyle(color: Color(0xFFC44F22)),
    'variable': TextStyle(color: colors.neutral7),
    'template-variable': const TextStyle(color: Color(0xFFC44F22)),
    'string': const TextStyle(color: Color(0xFF386E2F)),
    'doctag': const TextStyle(color: Color(0xFF386E2F)),
    'title': const TextStyle(color: Color(0xFF1C6788)),
    'section': const TextStyle(color: Color(0xFF1C6788)),
    'selector-id': const TextStyle(color: Color(0xFF1C6788)),
    'type': const TextStyle(color: Color(0xFF946513)),
    'class': const TextStyle(color: Color(0xFF946513)),
    'tag': const TextStyle(color: Color(0xFF946513)),
    'name': const TextStyle(color: Color(0xFF946513)),
    'attribute': const TextStyle(color: Color(0xFF1C6B5A)),
    'regexp': const TextStyle(color: Color(0xFF1C6B5A)),
    'link': const TextStyle(color: Color(0xFF217B9E)),
    'symbol': const TextStyle(color: Color(0xFFC44F22)),
    'bullet': const TextStyle(color: Color(0xFFC44F22)),
    'built_in': const TextStyle(color: Color(0xFF217B9E)),
    'builtin-name': const TextStyle(color: Color(0xFF217B9E)),
    'meta': const TextStyle(color: Color(0xFF889096)),
    'deletion': const TextStyle(color: Color(0xFFD1394B)),
    'addition': const TextStyle(color: Color(0xFF386E2F)),
    'emphasis': const TextStyle(fontStyle: FontStyle.italic),
    'strong': const TextStyle(fontWeight: FontWeight.w700),
  };
}

extension on Color {
  TextStyle get textStyle => TextStyle(color: this);
}
