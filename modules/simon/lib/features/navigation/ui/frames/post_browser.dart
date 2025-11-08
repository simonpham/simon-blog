import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:icons/icons.dart';
import 'package:simon/simon.dart';
import 'package:ui_file_tree/ui_file_tree.dart';
import 'package:utils/constants.dart';

class PostBrowser extends StatelessWidget {
  const PostBrowser({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      color: theme.colorScheme.surfaceContainer,
      child: Consumer<PostViewModel>(
        builder: (context, viewModel, child) {
          final categories = viewModel.tags.map((tag) {
            return FileTreeCategory(
              id: kUuid.v4(),
              name: tag.tagName,
              items: tag.posts.map((post) {
                return FileTreeItem(
                  id: post.id,
                  icon: Assets.bookOpen01,
                  name: '${post.slug}.md',
                );
              }).toList(),
            );
          }).toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CategoryHeader(),
              const Divider(height: 1.0),
              Expanded(
                child: FileTree(
                  categories: categories,
                  onItemTap: (file) {
                    HomePage.goToPost(context, identifier: file.id);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
