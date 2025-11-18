import 'package:core/core.dart';
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
    return DefaultTextStyle.merge(
      style: const TextStyle(
        fontFamily: kContentFontFamily,
      ),
      child: MarkdownContent(content),
    );
  }
}
