import 'package:flutter/widgets.dart';

class LeftPanel extends StatelessWidget {
  static const double defaultWidth = 250.0;
  static const double minWidth = 56.0;
  static const double maxWidth = defaultWidth * 2;

  final WidgetBuilder builder;

  const LeftPanel(
    this.builder, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: minWidth,
      ),
      child: builder(context),
    );
  }
}
