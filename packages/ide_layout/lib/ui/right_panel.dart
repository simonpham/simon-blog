import 'package:flutter/widgets.dart';

class RightPanel extends StatelessWidget {
  static const double defaultWidth = 250.0;

  static const double minWidth = 0;
  static const double maxWidth = defaultWidth * 2;

  final WidgetBuilder builder;

  const RightPanel(
    this.builder, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: maxWidth,
      ),
      child: builder(context),
    );
  }
}
