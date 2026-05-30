import 'package:design_system/design_system.dart';
import 'package:flutter/widgets.dart';

class TitleText extends StatelessWidget {
  final String text;

  final TextStyle? style;

  const TitleText(
    this.text, {
    super.key,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: context.theme.textTheme.labelSmall?.copyWith(
        color: context.theme.colorScheme.onSurface.withValues(alpha: 0.54),
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
