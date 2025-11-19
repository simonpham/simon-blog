import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart' hide Padding;
import 'package:flutter/widgets.dart';
import 'package:simon/simon.dart';
import 'package:utils/utils.dart' hide Padding;
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
    final readTimeText = readTimeMinutes > 0
        ? '$readTimeMinutes min read'
        : null;

    final now = DateTime.now().toLocal();
    final createdAt = selectedPost.createdAt.toLocal();
    final offset = now.difference(createdAt);
    final dateText = switch (offset.inDays > 30) {
      true => 'Posted on ${DateFormat.yMMMd().format(createdAt)}',
      false => 'Posted ${timeago.format(createdAt)}',
    };

    final updatedAt = selectedPost.updatedAt.toLocal();
    final updatedDate = DateFormat.yMMMd().format(updatedAt);

    return Tooltip(
      message: 'Last updated: $updatedDate',
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Spacing.d8,
        ),
        child: Text(
          [?readTimeText, dateText].join(' • '),
        ),
      ),
    );
  }
}
