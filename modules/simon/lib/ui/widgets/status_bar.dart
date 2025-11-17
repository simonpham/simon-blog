import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:icons/icons.dart';
import 'package:simon/simon.dart';

part 'status_bar/left.dart';
part 'status_bar/center.dart';
part 'status_bar/right.dart';

enum StatusBarAction {
  toggleLeftPanel,
  toggleRightPanel,
  toggleBottomPanel,
}

class StatusBarMessage {
  final MessageType type;
  final String message;
  final String? customIcon;

  const StatusBarMessage({
    required this.type,
    required this.message,
    this.customIcon,
  });
}

class StatusBar extends StatelessWidget {
  final bool isLeftPanelOpen;
  final bool isRightPanelOpen;
  final bool isBottomPanelOpen;

  final ValueChanged<StatusBarAction> onAction;

  final StatusBarMessage? message;

  const StatusBar({
    super.key,
    required this.isLeftPanelOpen,
    required this.isRightPanelOpen,
    required this.isBottomPanelOpen,
    required this.onAction,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      height: Spacing.d32,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        border: Border(
          top: BorderSide(
            color: theme.dividerColor,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          StatusBarLeftContent(
            isLeftPanelOpen: isLeftPanelOpen,
            onAction: onAction,
            message: message,
          ),
          StatusBarCenterContent(onAction: onAction),
          StatusBarRightContent(
            isRightPanelOpen: isRightPanelOpen,
            isBottomPanelOpen: isBottomPanelOpen,
            onAction: onAction,
          ),
        ],
      ),
    );
  }
}
