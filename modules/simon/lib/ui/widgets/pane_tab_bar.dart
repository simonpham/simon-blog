import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class PaneTabBar extends StatelessWidget {
  final List<Widget> children;

  const PaneTabBar({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Spacing.d48,
      padding: EdgeInsets.only(
        left: Spacing.d8,
        right: Spacing.d8,
      ),
      alignment: Alignment.centerLeft,
      child: Row(
        spacing: Spacing.d8,
        children: [
          for (var index = 0; index < children.length; index++) ...[
            children[index],
          ],
        ],
      ),
    );
  }
}

class PaneTabItem extends StatelessWidget {
  final String label;
  final String? icon;
  final bool isActive;
  final bool showCloseButton;
  final bool showDirty;
  final String? tooltip;
  final VoidCallback? onTap;
  final VoidCallback? onClose;
  final Widget? trailing;

  const PaneTabItem({
    super.key,
    required this.label,
    this.icon,
    this.isActive = true,
    this.showCloseButton = false,
    this.showDirty = false,
    this.tooltip,
    this.onTap,
    this.onClose,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Tappable(
        onTap: onTap,
        tooltip: tooltip ?? label,
        enableHover: true,
        enableAnimation: false,
        hoverOverlayBorderRadius: 8.0,
        builder: (context, state) {
          final isHovered = state.isHovered;
          final hoverColor = context.theme.colorScheme.primary.withValues(
            alpha: 0.1,
          );

          return RoundCard(
            borderRadius: 8.0,
            borderColor: isActive
                ? context.theme.colorScheme.primary
                : Colors.transparent,
            color: switch ((isActive, isHovered)) {
              (true, _) || (_, true) => hoverColor,
              _ => Colors.transparent,
            },
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: Spacing.d200),
              child: SizedBox(
                height: Spacing.d28,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Spacing.h8,
                    if (icon case final icon?) ...[
                      ImageView(
                        icon,
                        size: Spacing.d14,
                        color: context.theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                      Spacing.h4,
                    ],
                    Flexible(
                      fit: FlexFit.loose,
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.theme.textTheme.bodySmall?.copyWith(
                          color: isActive
                              ? context.theme.colorScheme.onSurface
                              : context.theme.colorScheme.onSurface.withValues(
                                  alpha: 0.5,
                                ),
                        ),
                      ),
                    ),
                    if (showDirty) ...[
                      Spacing.h6,
                      Tooltip(
                        message: 'Unsaved changes',
                        child: Container(
                          width: Spacing.d6,
                          height: Spacing.d6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: context.theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                    if (trailing case final trailing?) ...[
                      Spacing.h6,
                      trailing,
                    ],
                    if (showCloseButton && onClose != null)
                      Tappable(
                        onTap: onClose,
                        enableHover: true,
                        enableHoverOverlay: true,
                        builder: (context, state) {
                          return Padding(
                            padding: EdgeInsets.all(Spacing.d6),
                            child: Icon(
                              Icons.close,
                              size: Spacing.d12,
                              color: switch (state) {
                                TappableState.hover =>
                                  context.theme.colorScheme.onSurface,
                                _ =>
                                  context.theme.colorScheme.onSurface
                                      .withValues(alpha: 0.5),
                              },
                            ),
                          );
                        },
                      )
                    else
                      Spacing.h8,
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
