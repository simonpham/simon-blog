import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class FileFormat extends StatelessWidget {
  const FileFormat({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Implement file format widget.
    const format = 'Markdown';
    return Text(
      format,
      style: TextStyle(
        color: context.theme.colorScheme.onSurface.withValues(alpha: 0.5),
      ),
    );
  }
}
