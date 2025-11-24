import 'package:core/models/post.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icons/icons.dart';

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
          Tappable(
            enableHover: true,
            enableAnimation: false,
            tooltip: 'Copy link',
            onTap: () {
              final link = 'https://sofluffy.io/${selectedPost.slug}.md';
              Clipboard.setData(
                ClipboardData(text: link),
              );
              context.toast(
                'Copied to clipboard',
                type: MessageType.success,
              );
            },
            builder: (context, state) {
              final shouldShowIcon =
                  state == .hover || state == .pressed || state == .focus;
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
                      right: shouldShowIcon ? Spacing.d8 : Spacing.d16,
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
                              child: switch (shouldShowIcon) {
                                true => Padding(
                                  padding: EdgeInsets.only(
                                    left: Spacing.d8,
                                  ),
                                  child: ImageView(
                                    Assets.link04,
                                    color: theme.colorScheme.onSurface,
                                    size: Spacing.d16,
                                  ),
                                ),
                                false => const SizedBox.shrink(),
                              },
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
}
