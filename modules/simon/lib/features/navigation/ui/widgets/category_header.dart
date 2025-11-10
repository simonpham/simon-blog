import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:simon/simon.dart';

class CategoryHeader extends StatelessWidget {
  const CategoryHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
          // Tappable(
          //   onTap: () {},
          //   child: ImageView(
          //     Assets.moreVertical,
          //     size: Spacing.d16,
          //     color: context.theme.primaryColor,
          //   ),
          // ),
        ],
      ),
    );
  }
}
