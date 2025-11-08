import 'package:design_system/design_system.dart';
import 'package:flutter/widgets.dart';

class BottomPanel extends StatelessWidget {
  static const double defaultHeight = 240.0;
  static const double minHeight = 0.0;
  static const double maxHeight = 480.0;

  final WidgetBuilder builder;

  const BottomPanel(
    this.builder, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.theme.colorScheme.surface,
      child: builder(context),
    );
  }
}
