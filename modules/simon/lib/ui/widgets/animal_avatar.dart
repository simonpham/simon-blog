import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class AnimalAvatar extends StatelessWidget {
  final Animals animal;
  final BackgroundColorType background;

  final double size;

  const AnimalAvatar({
    super.key,
    required this.animal,
    required this.background,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final isRedPanda =
        animal == Animals.panda && background == BackgroundColorType.red;
    if (isRedPanda) {
      return ClipOval(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: background.color,
            shape: BoxShape.circle,
          ),
          child: Logo(
            size: size,
          ),
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background.color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          animal.emoji,
          style: TextStyle(
            fontSize: size * 0.75,
          ),
        ),
      ),
    );
  }
}
