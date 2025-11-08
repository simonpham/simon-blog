import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:simon/simon.dart';

class ChatPanel extends StatelessWidget {
  const ChatPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      color: theme.colorScheme.surfaceContainer,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChatHeader(),
          Divider(height: 1.0),
          Spacer(),
        ],
      ),
    );
  }
}
