import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:simon/simon.dart';

class CommentPanel extends StatefulWidget {
  final Post? post;

  const CommentPanel({
    super.key,
    required this.post,
  });

  @override
  State<CommentPanel> createState() => _CommentPanelState();
}

class _CommentPanelState extends State<CommentPanel> {
  final CommentViewModel _viewModel = CommentViewModel();

  final TextEditingController _inputController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _viewModel.setPost(widget.post);
  }

  @override
  void dispose() {
    _inputController.dispose();
    _focusNode.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CommentPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post?.id != widget.post?.id) {
      _viewModel.setPost(widget.post);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<CommentViewModel>(
        builder: (context, viewModel, child) {
          final theme = context.theme;
          final comments = viewModel.comments;
          return Container(
            color: theme.colorScheme.surfaceContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CommentHeader(),
                const Divider(height: 1.0),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _focusNode.requestFocus();
                    },
                    child: Container(
                      color: theme.colorScheme.surface,
                      child: ListView.builder(
                        itemCount: comments.length + 1,
                        padding: EdgeInsets.symmetric(
                          horizontal: Spacing.d16,
                        ),
                        itemBuilder: (context, index) {
                          if (index == comments.length) {
                            return CommentInput(
                              focusNode: _focusNode,
                              controller: _inputController,
                              onEnter: (text) => _handleComment(
                                context,
                                viewModel,
                                text,
                              ),
                            );
                          }
                          final comment = comments[index];
                          final isSame =
                              comment.animal == viewModel.animal &&
                              comment.backgroundColor ==
                                  viewModel.backgroundColor;
                          return CommentRow(comment: comment, isSame: isSame);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleComment(
    BuildContext context,
    CommentViewModel viewModel,
    String text,
  ) async {
    final result = await _viewModel.createComment(text);
    if (result != null) {
      context.toastError(result.message);
      return;
    }

    unawaited(_viewModel.fetchComments());
    _inputController.clear();
  }
}
