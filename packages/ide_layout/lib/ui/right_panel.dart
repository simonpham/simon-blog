import 'package:flutter/widgets.dart';

class RightPanel extends StatelessWidget {
  static const String id = 'right_panel';
  static const double defaultWidth = 250.0;

  static const double minWidth = defaultWidth;
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
        minWidth: defaultWidth,
      ),
      child: builder(context),
    );
  }
}
