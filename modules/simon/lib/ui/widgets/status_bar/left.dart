part of '../status_bar.dart';

class StatusBarLeftContent extends StatelessWidget {
  final bool isLeftPanelOpen;

  final ValueChanged<StatusBarAction> onAction;

  const StatusBarLeftContent({
    super.key,
    required this.isLeftPanelOpen,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Spacing.d16),
      child: Row(
        children: [
          MiniIconButton(
            icon: Assets.folder01,
            isActive: isLeftPanelOpen,
            onTap: () {
              onAction(StatusBarAction.toggleLeftPanel);
            },
          ),
        ],
      ),
    );
  }
}
