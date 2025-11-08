import 'package:core/core.dart';
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
      style: context.theme.textTheme.titleSmall
          ?.copyWith(
            color: context.theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          )
          .apply(fontFamily: kMonoFontFamily),
    );
  }
}
