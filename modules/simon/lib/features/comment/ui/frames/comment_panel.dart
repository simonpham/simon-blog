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
    return GestureDetector(
      onTap: () {
        _focusNode.requestFocus();
      },
      child: ChangeNotifierProvider.value(
        value: _viewModel,
        child: Consumer<CommentViewModel>(
          builder: (context, viewModel, child) {
            final comments = viewModel.comments;
            final theme = context.theme;
            return Theme(
              data: theme.copyWith(
                textTheme: theme.textTheme.apply(
                  fontFamily: kCommentFontFamily,
                ),
                primaryTextTheme: theme.primaryTextTheme.apply(
                  fontFamily: kCommentFontFamily,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CommentHeader(),
                  const Divider(height: 1.0),
                  Flexible(
                    child: ListView.builder(
                      reverse: true,
                      shrinkWrap: true,
                      itemCount: comments.length + 1,
                      padding: EdgeInsets.symmetric(
                        horizontal: Spacing.d16,
                      ),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return CommentInput(
                            focusNode: _focusNode,
                            controller: _inputController,
                            user: viewModel.anonymousUser,
                            onEnter: (text) => _handleComment(
                              context,
                              viewModel,
                              text,
                            ),
                          );
                        }
                        final comment = comments[index - 1];
                        final isSame =
                            comment.animal == viewModel.animal &&
                            comment.backgroundColor ==
                                viewModel.backgroundColor;
                        return CommentRow(comment: comment, isSame: isSame);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
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
