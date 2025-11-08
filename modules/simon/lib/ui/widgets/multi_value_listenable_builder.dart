import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MultiValueListenableBuilder extends StatelessWidget {
  final List<ValueListenable> listenables;
  final WidgetBuilder builder;

  const MultiValueListenableBuilder({
    super.key,
    required this.listenables,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    if (listenables.isEmpty) {
      return builder.call(context);
    }
    return _buildValueListenable(context, listenables, 0);
  }

  Widget _buildValueListenable(
    BuildContext context,
    List<ValueListenable> listenables,
    int index,
  ) {
    if (index >= listenables.length) {
      return builder.call(context);
    }
    return ValueListenableBuilder(
      valueListenable: listenables[index],
      builder: (context, _, _) {
        return _buildValueListenable(context, listenables, index + 1);
      },
    );
  }
}
