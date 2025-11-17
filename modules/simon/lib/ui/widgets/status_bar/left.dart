part of '../status_bar.dart';

class StatusBarLeftContent extends StatelessWidget {
  final bool isLeftPanelOpen;

  final ValueChanged<StatusBarAction> onAction;

  final StatusBarMessage? message;

  const StatusBarLeftContent({
    super.key,
    required this.isLeftPanelOpen,
    required this.onAction,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final color = context.theme.colorScheme.onSurface.withValues(alpha: 0.6);
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
          if (message case StatusBarMessage message) ...[
            Spacing.h16,
            // VerticalDivider(
            //   width: 1.0,
            //   color: context.theme.dividerColor,
            //   thickness: 2.0,
            // ),
            // Spacing.h16,
            if (message.customIcon == null) ...[
              ImageView(
                switch (message.type) {
                  .info => Assets.informationCircle,
                  .error => Assets.alertDiamond,
                  .warning => Assets.alert02,
                  .success => Assets.informationSquare,
                },
                size: Spacing.d16,
                color: switch (message.type) {
                  .error => Colors.red.withValues(alpha: 0.8),
                  .warning => Colors.amber.withValues(alpha: 0.8),
                  _ => color,
                },
              ),
            ],
            if (message.customIcon case String customicon) ...[
              ImageView(
                customicon,
                size: Spacing.d16,
              ),
            ],
            Spacing.h8,
            Text(
              message.message,
              style: context.theme.textTheme.bodyMedium?.copyWith(
                color: color,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
