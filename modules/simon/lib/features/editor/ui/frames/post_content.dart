import 'package:core/core.dart';
import 'package:design_system/components/logo.dart';
import 'package:design_system/utils/extensions/build_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:simon/simon.dart';

class PostContent extends StatelessWidget {
  const PostContent({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedPost = context.select<PostViewModel, Post?>(
      (viewModel) => viewModel.selectedPost?.data,
    );

    if (selectedPost == null) {
      return GridPaper(
        color: context.theme.primaryColor.withValues(alpha: 0.05),
        child: const Opacity(
          opacity: 0.1,
          child: Center(
            child: LogoWithName(),
          ),
        ),
      );
    }

    return Column(
      children: [
        EditorHeader(selectedPost),
        Expanded(
          child: PostContentView(
            selectedPost,
          ),
        ),
      ],
    );
  }
}
