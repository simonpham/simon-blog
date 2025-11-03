import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  final WidgetBuilder builder;

  const TopBar(
    this.builder, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return builder(context);
  }
}
