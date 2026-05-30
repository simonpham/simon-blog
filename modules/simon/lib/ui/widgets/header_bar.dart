import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:icons/icons.dart';
import 'package:panes/panes.dart';
import 'package:platform_utils/platform_utils.dart';
import 'package:simon/simon.dart';

class HeaderBar extends StatelessWidget {
  final VoidCallback onSearchTap;
  final void Function(IdePane pane) onTogglePane;
  final bool Function(IdePane pane) isPaneVisible;

  const HeaderBar({
    super.key,
    required this.onSearchTap,
    required this.onTogglePane,
    required this.isPaneVisible,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final appTheme = context.themeConfigs;
    return Container(
      height: Spacing.d36,
      color: theme.scaffoldBackgroundColor,
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Spacing.h12,
                PaneToggleButton(
                  pane: IdePane.left,
                  isPaneVisible: isPaneVisible,
                  onTogglePane: onTogglePane,
                ),
                Spacing.h8,
                PaneToggleButton(
                  pane: IdePane.bottom,
                  isPaneVisible: isPaneVisible,
                  onTogglePane: onTogglePane,
                ),
                Spacing.h8,
                PaneToggleButton(
                  pane: IdePane.right,
                  isPaneVisible: isPaneVisible,
                  onTogglePane: onTogglePane,
                ),
                Spacing.h8,
              ],
            ),
          ),
          Tappable(
            onDoubleTap: () {
              final authModel = context.read<AuthViewModel>();
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return ChangeNotifierProvider.value(
                    value: authModel,
                    child: const Dialog(
                      child: LoginFrame(),
                    ),
                  );
                },
              );
            },
            onTap: () {
              SettingsBox().appTheme = SettingsBox().appTheme == ThemeMode.light
                  ? ThemeMode.dark
                  : ThemeMode.light;
            },
            enableHover: true,
            enableHoverOverlay: true,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Spacing.d8,
                vertical: Spacing.d2,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: Spacing.d20,
                    height: Spacing.d20,
                    decoration: BoxDecoration(
                      color: appTheme.colors.primary,
                      borderRadius: Spacing.smoothR6,
                    ),
                    child: ImageView(
                      DesignSystemAssets.images.logoTransparent,
                      size: Spacing.d20,
                      assetPackage: kDesignSystemPackageName,
                    ),
                  ),
                  Spacing.h6,
                  Text(
                    'SoFluffy',
                    style: appTheme.typography.base2.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Spacing.h8,
                Tappable(
                  onTap: () {
                    launchUrl(
                      Uri.parse('https://lumide.dev'),
                      webOnlyWindowName: '_blank',
                    );
                  },
                  tooltip: 'Try Lumide IDE',
                  enableHover: true,
                  enableHoverOverlay: true,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Spacing.d8,
                      vertical: Spacing.d4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Try Lumide',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.72,
                            ),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Spacing.h4,
                        ImageView(
                          Assets.link04,
                          size: Spacing.d14,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.72,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Spacing.h8,
                _TopBarDivider(),
                Spacing.h8,
                Tappable(
                  onTap: onSearchTap,
                  tooltip: 'Search in Blog',
                  enableHover: true,
                  enableHoverOverlay: true,
                  child: Padding(
                    padding: EdgeInsets.all(Spacing.d4),
                    child: ImageView(
                      Assets.search,
                      size: Spacing.d16,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                Spacing.h12,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBarDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: VerticalDivider(
        indent: Spacing.d8,
        endIndent: Spacing.d8,
        thickness: 0.25,
        width: 0.25,
        color: context.theme.colorScheme.onSurfaceVariant.withValues(
          alpha: 0.5,
        ),
      ),
    );
  }
}
