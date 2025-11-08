import 'package:design_system/design_system.dart';
import 'package:flutter/widgets.dart';
import 'package:simon/simon.dart';

class ChatHeader extends StatelessWidget {
  const ChatHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.d16,
        vertical: Spacing.d8,
      ),
      child: Row(
        children: [
          Expanded(
            child: TitleText(
              '🦊 Chat den'.toUpperCase(),
            ),
          ),
        ],
      ),
    );
  }
}
