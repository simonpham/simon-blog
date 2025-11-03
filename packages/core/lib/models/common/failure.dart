import 'package:flutter/foundation.dart';

@immutable
class Failure {
  final String message;

  const Failure(this.message);

  @override
  String toString() => message;
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure() : super('Unauthorized');
}
