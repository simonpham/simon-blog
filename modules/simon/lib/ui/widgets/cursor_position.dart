import 'package:flutter/material.dart';

class CursorPosition extends StatelessWidget {
  const CursorPosition({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Implement cursor position widget.
    const line = 23;
    const column = 3;
    return const Text(
      '$line:$column',
    );
  }
}
