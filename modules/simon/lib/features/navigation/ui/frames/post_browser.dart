import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/widgets.dart';
import 'package:simon/simon.dart';

class PostBrowser extends StatelessWidget {
  const PostBrowser({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PostViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: viewModel.posts.length,
                itemBuilder: (context, index) {
                  final post = viewModel.posts[index];
                  return ListItem(
                    title: post.title,
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
    );
  }
}
