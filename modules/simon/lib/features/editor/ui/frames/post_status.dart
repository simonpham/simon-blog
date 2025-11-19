import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:simon/simon.dart';
import 'package:utils/utils.dart';
import 'package:utils/utils.dart' as timeago;

class PostStatus extends StatelessWidget {
  const PostStatus({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final selectedPost = context.select<PostViewModel, Post?>(
      (viewModel) => viewModel.selectedPost?.data,
    );

    if (selectedPost == null) {
      return const SizedBox.shrink();
    }

    int readTimeMinutes = selectedPost.readTimeMinutes;
    if (readTimeMinutes == 0) {
      readTimeMinutes = WordCountUtils.calculateReadingTime(
        selectedPost.content,
      ).inMinutes;
    }

    final date = timeago.format(selectedPost.createdAt);

    return Text(
      '${selectedPost.readTimeMinutes} min read • $date',
    );
  }
}
