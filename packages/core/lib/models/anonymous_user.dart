import 'dart:math';

import 'package:core/core.dart';

class AnonymousUser {
  final Animals animal;
  final BackgroundColorType backgroundColor;
  final String randomNumber;

  const AnonymousUser._({
    required this.animal,
    required this.backgroundColor,
    required this.randomNumber,
  });

  String get displayName =>
      '${backgroundColor.name}_${animal.name}$randomNumber';

  factory AnonymousUser.create() {
    // random 3 number as String. min 100
    final String randomInt = '${Random().nextInt(900) + 100}';
    final reservedCombo = ['red_panda', 'red_fox'];
    Animals? animal;
    BackgroundColorType? backgroundColorType;
    do {
      animal = Animals.values[Random().nextInt(Animals.values.length)];
      backgroundColorType =
          BackgroundColorType.values[Random().nextInt(
            BackgroundColorType.values.length,
          )];
    } while (reservedCombo.contains(
      '${animal.name}${backgroundColorType.name}',
    ));
    return AnonymousUser._(
      animal: animal,
      backgroundColor: backgroundColorType,
      randomNumber: randomInt,
    );
  }

  factory AnonymousUser.fromJson(dynamic json) {
    return AnonymousUser._(
      animal: Animals.fromName(json['animal']),
      backgroundColor: BackgroundColorType.fromString(json['backgroundColor']),
      randomNumber: json['randomNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'animal': animal.name,
      'backgroundColor': backgroundColor.name,
      'randomNumber': randomNumber,
    };
  }
}
