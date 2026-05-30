import 'package:flutter/widgets.dart';
import 'package:icons/icons.dart';
import 'package:simon/simon.dart';

class CommentHeader extends StatelessWidget {
  const CommentHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const PaneTabBar(
      children: [
        PaneTabItem(
          label: 'Comment nest',
          icon: Assets.terminal,
        ),
      ],
    );
  }
}
