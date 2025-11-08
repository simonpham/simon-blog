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
      padding: EdgeInsets.symmetric(horizontal: Spacing.d8),
      child: Row(
        children: [
          MiniIconButton(
            icon: Assets.hierarchyFiles,
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
