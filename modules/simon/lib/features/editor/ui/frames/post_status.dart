import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:simon/simon.dart';
import 'package:utils/utils.dart' hide Padding;
import 'package:utils/utils.dart' as timeago;

class PostStatusWidget extends StatelessWidget {
  const PostStatusWidget({
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
      true => 'posted on ${DateFormat.yMMMd().format(createdAt)}',
      false => 'posted ${timeago.format(createdAt)}',
    };

    final updatedAt = selectedPost.updatedAt.toLocal();
    final updatedDate = DateFormat.yMMMd().format(updatedAt);

    return Tooltip(
      message: 'Last updated: $updatedDate',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Tooltip(
            message: selectedPost.author.displayName,
            child: Container(
              width: Spacing.d16,
              height: Spacing.d16,
              alignment: Alignment.center,
              child: ClipOval(
                child: ImageView(
                  selectedPost.author.avatarUrl,
                  blurHash: selectedPost.author.avatarHash,
                  size: Spacing.d16,
                ),
              ),
            ),
          ),
          Spacing.h8,
          ValueListenableBuilder(
            valueListenable: [CoreSettings.screenSize].of(SettingsBox()),
            builder: (context, _, _) {
              if (SettingsBox().screenSize <= ScreenSize.normal) {
                return const SizedBox();
              }
              return Flexible(
                child: Padding(
                  padding: EdgeInsets.only(right: Spacing.d8),
                  child: Text(
                    selectedPost.author.displayName,
                    style: TextStyle(
                      color: context.theme.colorScheme.onSurface.withValues(
                        alpha: 0.5,
                      ),
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            },
          ),
          Flexible(
            child: Text(
              [dateText, ?readTimeText].join(' • '),
              style: TextStyle(
                color: context.theme.colorScheme.onSurface.withValues(
                  alpha: 0.5,
                ),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Spacing.h8,
        ],
      ),
    );
  }
}
