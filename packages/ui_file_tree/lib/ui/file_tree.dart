import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:icons/icons.dart';
import 'package:ui_file_tree/ui_file_tree.dart';

typedef OnFileTreeItemTap = void Function(FileTreeItem item);

class FileTree extends StatelessWidget {
  final List<FileTreeCategory> categories;

  final OnFileTreeItemTap? onItemTap;

  final String? selectedId;

  const FileTree({
    required this.categories,
    this.onItemTap,
    this.selectedId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final textStyle = theme.textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.normal,
      color: theme.textTheme.titleSmall?.color?.withValues(alpha: 0.6),
    );
    return CustomScrollView(
      slivers: [
        for (final category in categories) ...[
          SliverToBoxAdapter(
            child: Tappable(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: Spacing.d4,
                  horizontal: Spacing.d16,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: Spacing.d2,
                        bottom: Spacing.d2,
                      ),
                      child: ImageView(
                        Assets.folder02,
                        size: Spacing.d16,
                        color: theme.iconTheme.color,
                      ),
                    ),
                    Spacing.h8,
                    Flexible(
                      child: Text(
                        category.name,
                        style: textStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverList.builder(
            itemCount: category.items.length,
            itemBuilder: (BuildContext context, int index) {
              final item = category.items[index];
              final isSelected =
                  selectedId == item.id || selectedId == item.name;
              return Tappable(
                tooltip: item.tooltip,
                onTap: () => onItemTap?.call(item),
                enableHover: true,
                builder: (context, state) {
                  final isHovered = state == TappableState.hover;
                  return Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: Spacing.d8,
                    ),
                    decoration: switch (isSelected || isHovered) {
                      true => ShapeDecoration(
                        shape: SmoothRectangleBorder(
                          borderRadius: Spacing.smoothR8,
                        ),
                        color: theme.primaryColor.withValues(alpha: 0.1),
                      ),
                      _ => null,
                    },
                    child: Container(
                      margin: EdgeInsets.only(
                        left: Spacing.d16,
                      ),
                      padding: EdgeInsets.all(Spacing.d4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              top: Spacing.d2,
                              bottom: Spacing.d2,
                            ),
                            child: ImageView(
                              item.icon,
                              size: Spacing.d16,
                              color: switch (isSelected) {
                                true => theme.primaryColor,
                                false => theme.iconTheme.color,
                              },
                            ),
                          ),
                          Spacing.h8,
                          Flexible(
                            child: Text(
                              item.name,
                              style: switch (isSelected) {
                                true => textStyle?.copyWith(
                                  color: textStyle.color?.withValues(
                                    alpha: 1,
                                  ),
                                ),
                                _ when isHovered => textStyle?.copyWith(
                                  decoration: TextDecoration.underline,
                                ),
                                false => textStyle,
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ],
    );
  }
}
