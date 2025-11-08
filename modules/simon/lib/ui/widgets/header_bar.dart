import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:ide_layout/ide_layout.dart';

class HeaderBar extends StatelessWidget {
  const HeaderBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.theme.colorScheme.surfaceContainer,
      padding: EdgeInsets.all(Spacing.d8),
      child: Row(
        children: [
          Container(
            constraints: const BoxConstraints(
              minWidth: LeftPanel.defaultWidth,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.d8,
            ),
            child: Tappable(
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
          const Expanded(
            child: InputText(
              hintText: 'Sniffing out files and content...',
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
