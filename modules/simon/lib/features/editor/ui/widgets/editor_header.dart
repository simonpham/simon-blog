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
    final theme = context.theme;
    return Container(
      height: Spacing.d32,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
      ),
      child: Row(
        children: [
          // Filename with hover-to-edit
          Builder(
            builder: (context) {
              final user = context.select((AuthViewModel model) => model.user);
              return Tappable(
                enableHover: true,
                enableAnimation: false,
                tooltip: user != null ? 'Click to edit' : 'Copy link',
                onTap: () {
                  if (user != null) {
                    // Start editing when logged in
                    context.read<PostViewModel>().startEditing(
                      post: selectedPost,
                      author: user,
                    );
                  } else {
                    // Copy link when not logged in
                    _copyLink(context);
                  }
                },
                builder: (context, state) {
                  final isHovering =
                      state == TappableState.hover ||
                      state == TappableState.pressed ||
                      state == TappableState.focus;
                  return Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      border: Border(
                        right: BorderSide(
                          color: theme.dividerColor,
                          width: 1.0,
                        ),
                      ),
                    ),
                    padding: EdgeInsets.only(
                      left: Spacing.d16,
                    ),
                    alignment: Alignment.center,
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: isHovering ? Spacing.d8 : Spacing.d16,
                        ),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              WidgetSpan(
                                child: Container(
                                  width: Spacing.d16,
                                  height: Spacing.d16,
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.only(right: Spacing.d8),
                                  child: ImageView(
                                    Assets.bookOpen01,
                                    size: Spacing.d16,
                                    color: theme.primaryColor,
                                  ),
                                ),
                              ),
                              TextSpan(
                                text: selectedPost.fileName,
                              ),
                              WidgetSpan(
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: isHovering
                                      ? Padding(
                                          padding: EdgeInsets.only(
                                            left: Spacing.d8,
                                          ),
                                          child: ImageView(
                                            user != null
                                                ? Assets.pencilEdit02
                                                : Assets.link04,
                                            color: theme.colorScheme.onSurface,
                                            size: Spacing.d16,
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                ),
                              ),
                            ],
                          ),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 1.0,
                color: theme.dividerColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copyLink(BuildContext context) {
    final link = 'https://sofluffy.io/${selectedPost.slug}.md';
    Clipboard.setData(ClipboardData(text: link));
    context.toast(
      'Copied to clipboard',
      type: MessageType.success,
    );
  }
}
