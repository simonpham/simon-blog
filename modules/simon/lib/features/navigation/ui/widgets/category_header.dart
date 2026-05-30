import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:icons/icons.dart';
import 'package:simon/simon.dart';

class CategoryHeader extends StatelessWidget {
  const CategoryHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return PaneTabBar(
      children: [
        const PaneTabItem(
          label: 'Burrow files',
          icon: Assets.hierarchyFiles,
        ),
        Builder(
          builder: (context) {
            final user = context.select((AuthViewModel model) => model.user);
            if (user == null) {
              return const SizedBox.shrink();
            }
            return Tappable(
              onTap: () {
                context.read<PostViewModel>().startEditing(
                  author: user,
                );
              },
              tooltip: 'New Post',
              child: Padding(
                padding: EdgeInsets.all(Spacing.d8),
                child: ImageView(
                  Assets.bookOpen02,
                  size: Spacing.d14,
                  color: context.theme.colorScheme.onSurface.withValues(
                    alpha: 0.7,
                  ),
                ),
              ),
            );
          },
        ),
        Spacing.h8,
      ],
    );
  }
}
