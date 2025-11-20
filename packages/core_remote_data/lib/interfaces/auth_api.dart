import 'dart:async';

import 'package:core/core.dart';

abstract interface class AuthApis {
  FutureOr<AuthTokens?> login({
    required String username,
    required String password,
  });
}
