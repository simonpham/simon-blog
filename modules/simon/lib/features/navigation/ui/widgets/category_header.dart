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
    final theme = context.theme;

    return Container(
      height: Spacing.d32,
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.d16,
      ),
      child: Row(
        children: [
          Expanded(
            child: TitleText(
              'Burrow files'.toUpperCase(),
            ),
          ),
          // New Post button - visible when admin logged in
          Builder(
            builder: (context) {
              final user = context.select((AuthViewModel model) => model.user);
              if (user == null) {
                return const SizedBox.shrink();
              }
              return Tappable(
                onTap: () async {
                  await PostEditorDialog.show(
                    context,
                    author: user,
                  );
                },
                tooltip: 'New Post',
                child: ImageView(
                  Assets.bookOpen02,
                  size: Spacing.d16,
                  color: theme.primaryColor,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
