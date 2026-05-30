import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icons/icons.dart';
import 'package:simon/simon.dart';

class EditorHeader extends StatelessWidget {
  final Post selectedPost;

  const EditorHeader(
    this.selectedPost, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return PaneTabBar(
      children: [
        Builder(
          builder: (context) {
            final user = context.select((AuthViewModel model) => model.user);
            return Flexible(
              child: PaneTabItem(
                label: selectedPost.fileName,
                icon: Assets.bookOpen01,
                tooltip: user != null ? 'Click to edit' : 'Copy link',
                trailing: ImageView(
                  user != null ? Assets.pencilEdit02 : Assets.link04,
                  color: context.theme.colorScheme.onSurface.withValues(
                    alpha: 0.5,
                  ),
                  size: Spacing.d12,
                ),
                onTap: () {
                  if (user != null) {
                    context.read<PostViewModel>().startEditing(
                      post: selectedPost,
                      author: user,
                    );
                  } else {
                    _copyLink(context);
                  }
                },
              ),
            );
          },
        ),
      ],
    );
  }

  void _copyLink(BuildContext context) {
    final link = 'https://share.sofluffy.io/s/${selectedPost.slug}';
    Clipboard.setData(ClipboardData(text: link));
    context.toast(
      'Copied to clipboard',
      type: MessageType.success,
    );
  }
}
