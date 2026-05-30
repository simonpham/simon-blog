import 'package:flutter/widgets.dart';
import 'package:icons/icons.dart';
import 'package:simon/simon.dart';

class ChatHeader extends StatelessWidget {
  const ChatHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const PaneTabBar(
      children: [
        PaneTabItem(
          label: 'Chat den',
          icon: Assets.messageProgramming,
        ),
      ],
    );
  }
}
