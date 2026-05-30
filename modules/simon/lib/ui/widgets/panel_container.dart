import 'package:design_system/design_system.dart';
import 'package:flutter/widgets.dart';

class PanelContainer extends StatelessWidget {
  final Widget child;

  const PanelContainer({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return RoundCard(
      color: context.theme.colorScheme.surface,
      child: child,
    );
  }
}
