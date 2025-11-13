import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:simon/simon.dart';

class ChatPanel extends StatefulWidget {
  const ChatPanel({super.key});

  @override
  State<ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<ChatPanel> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Consumer<ChatViewModel>(
      builder: (context, model, _) {
        return Container(
          color: theme.colorScheme.surfaceContainer,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ChatHeader(),
              const Divider(height: 1.0),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  reverse: true,
                  itemCount: model.chatMessages.length,
                  itemBuilder: (context, index) {
                    final message = model.chatMessages[index];
                    final isSame = model.senderName == message.senderName;
                    return ChatMessageRow(
                      message: message,
                      isSame: isSame,
                    );
                  },
                ),
              ),
              ChatInput(
                focusNode: _focusNode,
                controller: _controller,
                animal: model.animal,
                backgroundColor: model.backgroundColor,
                onEnter: (message) {
                  model.sendMessage(message);
                  _controller.clear();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
