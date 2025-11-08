import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:simon/simon.dart';

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
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CategoryHeader(),
              const Divider(height: 1.0),
              Expanded(
                child: ListView.builder(
                  itemCount: viewModel.posts.length,
                  itemBuilder: (context, index) {
                    final post = viewModel.posts[index];
                    return ListItem(
                      title: '${post.slug}.md',
                      onTap: () {
                        viewModel.selectPost(post);
                      },
                    );
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
