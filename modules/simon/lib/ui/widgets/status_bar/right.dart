part of '../status_bar.dart';

class StatusBarRightContent extends StatelessWidget {
  final bool isBottomPanelOpen;

  final ValueChanged<StatusBarAction> onAction;

  const StatusBarRightContent({
    super.key,
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
          VerticalDivider(
            width: Spacing.d32,
            color: context.theme.dividerColor,
            thickness: 2.0,
          ),
          MiniIconButton(
            icon: Assets.securityLock,
            isActive: isBottomPanelOpen,
            onTap: () {
              onAction(StatusBarAction.toggleBottomPanel);
            },
          ),
        ],
      ),
    );
  }
}
