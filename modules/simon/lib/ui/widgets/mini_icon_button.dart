import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class MiniIconButton extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;

  final bool isActive;

  const MiniIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: onTap,
      child: ImageView(
        icon,
        size: Spacing.d16,
        color: switch (isActive) {
          true => context.theme.primaryColor,
          false => context.theme.colorScheme.onSurface,
        },
      ),
    );
  }
}
