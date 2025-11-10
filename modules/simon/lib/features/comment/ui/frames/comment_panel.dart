import 'package:core/core.dart';
import 'package:core_remote_data/interfaces/comment_api.dart';
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
  CommentApis get _apis => injector<CommentApis>();

  List<Comment> _comments = [];

  void _fetchComments() async {
    final postId = widget.post?.id;
    if (postId == null) {
      return;
    }

    final comments = await _apis.getCommentsForPost(postId);
    _comments = comments;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  @override
  void didUpdateWidget(covariant CommentPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _fetchComments();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final comments = this._comments;
    return Container(
      color: theme.colorScheme.surfaceContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommentHeader(),
          const Divider(height: 1.0),
          Expanded(
            child: Container(
              color: theme.colorScheme.surface,
              child: ListView.builder(
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  final comment = comments[index];
                  return Text(comment.content);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
