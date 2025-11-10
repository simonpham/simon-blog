import 'package:core/core.dart';
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
