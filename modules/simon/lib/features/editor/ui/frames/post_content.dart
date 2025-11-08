import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:simon/simon.dart';

class PostContent extends StatelessWidget {
  const PostContent({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedPost = context.select<PostViewModel, Post?>(
      (viewModel) => viewModel.selectedPost,
    );

    if (selectedPost == null) {
      return const Text('No post selected');
    }

    return Column(
      children: [
        EditorHeader(selectedPost),
        Expanded(
          child: PostContentView(
            selectedPost,
          ),
        ),
      ],
    );
  }
}
