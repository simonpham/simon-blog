import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:icons/icons.dart';
import 'package:ide_layout/ide_layout.dart';
import 'package:simon/simon.dart';

class HeaderBar extends StatelessWidget {
  final VoidCallback onSearchTap;

  const HeaderBar({
    super.key,
    required this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.theme.colorScheme.surfaceContainer,
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.d8,
        vertical: Spacing.d6,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.d8,
            ),
            child: Tappable(
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
                SettingsBox().appTheme =
                    SettingsBox().appTheme == ThemeMode.light
                    ? ThemeMode.dark
                    : ThemeMode.light;
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: context.theme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: ImageView(
                      DesignSystemAssets.images.logoTransparent,
                      size: Spacing.d24,
                      assetPackage: kDesignSystemPackageName,
                    ),
                  ),
                  Spacing.h8,
                  Text(
                    'SoFluffy',
                    style: context.theme.textTheme.titleMedium?.copyWith(
                      color: context.theme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.d8,
            ),
            child: Tappable(
              onTap: onSearchTap,
              enableHover: true,
              enableAnimation: false,
              builder: (context, state) {
                final isHovered = state == TappableState.hover;
                final color = context.theme.colorScheme.onSurface.withValues(
                  alpha: isHovered ? 1.0 : 0.6,
                );
                return Container(
                  constraints: BoxConstraints(
                    minHeight: Spacing.d32,
                    maxWidth: SettingsBox().screenSize > ScreenSize.normal
                        ? LeftPanel.maxWidth
                        : Spacing.d40,
                  ),
                  decoration: ShapeDecoration(
                    color: context.theme.colorScheme.surface,
                    shape: SmoothRectangleBorder(
                      borderRadius: Spacing.smoothR12,
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: Spacing.d12,
                  ),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      if (SettingsBox().screenSize > ScreenSize.normal) ...[
                        Expanded(
                          child: Text(
                            'Sniffing out files and content...',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: color,
                            ),
                          ),
                        ),
                      ],
                      ImageView(
                        Assets.search,
                        size: Spacing.d16,
                        color: color,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const Spacer(),
          Container(
            color: Colors.red,
            child: Text(
              context.select(
                (AuthViewModel model) => '', // TODO: show logged-in user info.
              ),
            ),
          ),
        ],
      ),
    );
  }
}
