import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class BottomBar extends StatelessWidget {
  final WidgetBuilder builder;

  const BottomBar(
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
