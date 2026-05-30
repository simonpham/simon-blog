part of '../status_bar.dart';

class StatusBarLeftContent extends StatelessWidget {
  final StatusBarMessage? message;

  const StatusBarLeftContent({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final color = context.theme.colorScheme.onSurface.withValues(alpha: 0.5);
    return Row(
      children: [
        if (message case StatusBarMessage message) ...[
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
            style: context.theme.textTheme.bodySmall?.copyWith(
              color: color,
            ),
          ),
        ],
      ],
    );
  }
}
