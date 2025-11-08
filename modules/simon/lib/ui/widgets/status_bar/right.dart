part of '../status_bar.dart';

class StatusBarRightContent extends StatelessWidget {
  final bool isRightPanelOpen;
  final bool isBottomPanelOpen;

  final ValueChanged<StatusBarAction> onAction;

  const StatusBarRightContent({
    super.key,
    required this.isRightPanelOpen,
    required this.isBottomPanelOpen,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Spacing.d16),
      child: Row(
        children: [
          const CursorPosition(),
          Spacing.h16,
          const FileFormat(),
          Spacing.h16,
          VerticalDivider(
            width: 1.0,
            color: context.theme.dividerColor,
            thickness: 2.0,
          ),
          Spacing.h16,
          MiniIconButton(
            icon: Assets.terminal,
            isActive: isBottomPanelOpen,
            onTap: () {
              onAction(StatusBarAction.toggleBottomPanel);
            },
          ),
          Spacing.h8,
          MiniIconButton(
            icon: Assets.messageProgramming,
            isActive: isRightPanelOpen,
            onTap: () {
              onAction(StatusBarAction.toggleRightPanel);
            },
          ),
        ],
      ),
    );
  }
}
