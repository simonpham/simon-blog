import 'package:design_system/design_system.dart';
import 'package:flutter/widgets.dart';
import 'package:icons/icons.dart';
import 'package:panes/panes.dart';

class PaneToggleButton extends StatelessWidget {
  final IdePane pane;
  final void Function(IdePane pane) onTogglePane;
  final bool Function(IdePane pane) isPaneVisible;

  const PaneToggleButton({
    super.key,
    required this.pane,
    required this.onTogglePane,
    required this.isPaneVisible,
  });

  @override
  Widget build(BuildContext context) {
    final icon = _getIconForPane(pane);
    if (icon == null) {
      return const SizedBox.shrink();
    }

    return Listener(
      onPointerDown: (_) {
        onTogglePane(pane);
      },
      child: Tappable(
        enableHover: true,
        enableHoverOverlay: true,
        child: Padding(
          padding: EdgeInsets.all(Spacing.d4),
          child: ImageView(
            icon,
            size: Spacing.d16,
            color: context.theme.colorScheme.onSurface,
          ),
        ),
        onTap: () {},
      ),
    );
  }

  String? _getIconForPane(IdePane pane) => switch (pane) {
    IdePane.left => Assets.hierarchyFiles,
    IdePane.right => Assets.messageProgramming,
    IdePane.bottom => Assets.terminal,
    IdePane.center => null,
    IdePane.centerContainer => null,
  };
}
