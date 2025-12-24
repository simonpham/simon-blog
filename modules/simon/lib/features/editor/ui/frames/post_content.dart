import 'package:core/core.dart';
import 'package:design_system/components/logo.dart';
import 'package:design_system/utils/extensions/build_context.dart';
import 'package:flutter/material.dart';
import 'package:simon/simon.dart';

class PostContent extends StatelessWidget {
  const PostContent({super.key});

  @override
  Widget build(BuildContext context) {
    final isEditing = context.select<PostViewModel, bool>(
      (viewModel) => viewModel.isEditing,
    );

    // Show editor when in edit mode
    if (isEditing) {
      return _buildEditorView(context);
    }

    // Show post content when viewing
    return _buildContentView(context);
  }

  Widget _buildEditorView(BuildContext context) {
    final editingPost = context.select<PostViewModel, Post?>(
      (viewModel) => viewModel.editingPost,
    );

    return Title(
      title: editingPost != null
          ? 'Editing: ${editingPost.title} – SoFluffy'
          : 'New Post – SoFluffy',
      color: context.theme.primaryColor,
      child: PostEditor(key: PostEditor.editorKey),
    );
  }

  Widget _buildContentView(BuildContext context) {
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

    return Title(
      title: '${selectedPost.title} – SoFluffy',
      color: context.theme.primaryColor,
      child: Column(
        children: [
          EditorHeader(selectedPost),
          Expanded(
            child: PostContentView(selectedPost),
          ),
        ],
      ),
    );
  }
}
