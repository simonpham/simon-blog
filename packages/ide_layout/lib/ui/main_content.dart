import 'package:design_system/design_system.dart';
import 'package:flutter/widgets.dart';

class MainContent extends StatelessWidget {
  static const String id = 'main_content';

  final WidgetBuilder builder;

  const MainContent(
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
