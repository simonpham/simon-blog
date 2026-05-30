import 'package:core/core.dart';
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
    return Consumer<PostViewModel>(
      builder: (context, viewModel, child) {
        final routerState = context.router.state;
        final postIdentifier =
            routerState.pathParameters[HomePage.identifierParam];

        final categories = viewModel.tags.map((tag) {
          return FileTreeCategory(
            id: kUuid.v4(),
            name: tag.tagName,
            items: tag.posts.map((post) {
              return FileTreeItem(
                id: post.id,
                icon: Assets.bookOpen01,
                name: post.fileName,
                tooltip: post.title,
              );
            }).toList(),
          );
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CategoryHeader(),
            Expanded(
              child: FileTree(
                categories: categories,
                selectedId: postIdentifier,
                onItemTap: (file) {
                  HomePage.goToPost(context, identifier: file.name);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
