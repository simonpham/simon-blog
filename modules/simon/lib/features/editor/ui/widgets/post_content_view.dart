import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:ui_markdown/ui_markdown.dart';

class PostContentView extends StatelessWidget {
  final Post post;

  const PostContentView(
    this.post, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final appTheme = context.themeConfigs;
    final headerBlock = '# ${post.title}';
    final summaryBlock = switch (post.summary.isNotEmpty) {
      true => '> _${post.summary}_\n',
      false => '',
    };
    final imageBlock = switch (post.featuredImageUrl) {
      final String url => '![$url]($url)\n',
      null => '',
    };
    final content =
        '''
$headerBlock
$summaryBlock
$imageBlock
${post.content}
''';
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(Spacing.d24),
        child: DefaultTextStyle.merge(
          style: TextStyle(
            fontFamily: kContentFontFamily,
            color: theme.colorScheme.onSurface,
            height: 1.6,
          ),
          child: IconTheme.merge(
            data: IconThemeData(
              color: appTheme.colors.primary,
            ),
            child: MarkdownPreview(
              data: content,
              selectable: false,
            ),
          ),
        ),
      ),
    );
  }
}
