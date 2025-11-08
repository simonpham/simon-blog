import 'package:core/constants/constants.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:icons/icons.dart';
import 'package:ui_file_tree/ui_file_tree.dart';

typedef OnFileTreeItemTap = void Function(FileTreeItem item);

class FileTree extends StatelessWidget {
  final List<FileTreeCategory> categories;

  final OnFileTreeItemTap? onItemTap;

  const FileTree({
    required this.categories,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final textStyle = theme.textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.normal,
      fontFamily: kMonoFontFamily,
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
                        color: theme.primaryColor,
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
              return Tappable(
                onTap: () => onItemTap?.call(item),
                enableHover: true,
                enableHoverOverlay: true,
                child: Container(
                  margin: EdgeInsets.only(
                    left: Spacing.d24,
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
                          color: theme.primaryColor,
                        ),
                      ),
                      Spacing.h8,
                      Flexible(
                        child: Text(
                          item.name,
                          style: textStyle,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}
