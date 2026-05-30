import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:icons/icons.dart';
import 'package:simon/simon.dart';

part 'status_bar/left.dart';
part 'status_bar/center.dart';
part 'status_bar/right.dart';

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
  final StatusBarMessage? message;

  const StatusBar({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final foreground = theme.colorScheme.onSurface.withValues(alpha: 0.5);
    return Container(
      height: Spacing.d24,
      padding: EdgeInsets.symmetric(horizontal: Spacing.d12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.dividerTheme.color ?? Colors.transparent,
            width: 1,
          ),
        ),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(
          color: foreground,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        child: IconTheme.merge(
          data: IconThemeData(
            color: foreground,
            size: Spacing.d14,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatusBarLeftContent(
                message: message,
              ),
              const StatusBarCenterContent(),
              const StatusBarRightContent(),
            ],
          ),
        ),
      ),
    );
  }
}
