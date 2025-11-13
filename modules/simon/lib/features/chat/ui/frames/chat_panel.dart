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
                child: SelectionArea(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(
                      vertical: Spacing.d16,
                    ),
                    reverse: true,
                    itemCount: model.chatMessages.length,
                    itemBuilder: (context, index) {
                      final message = model.chatMessages[index];
                      final isSame = model.senderName == message.senderName;
                      // In a reversed list, "previous" in time is at index + 1
                      // and "next" in time is at index - 1.
                      final hasPreviousMessage =
                          index < model.chatMessages.length - 1;
                      final hasNextMessage = index > 0;

                      final isPreviousSame =
                          hasPreviousMessage &&
                          model.chatMessages[index + 1].senderName ==
                              message.senderName;
                      final isNextSame =
                          hasNextMessage &&
                          model.chatMessages[index - 1].senderName ==
                              message.senderName;
                      return ChatMessageRow(
                        message: message,
                        isSame: isSame,
                        isPreviousSame: isPreviousSame,
                        isNextSame: isNextSame,
                      );
                    },
                  ),
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
