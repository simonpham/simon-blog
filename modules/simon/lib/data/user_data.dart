import 'package:core/core.dart';

enum UserData {
  anonymousUser,
  authTokens,
}

extension UserDataExtension on SettingsBox {
  AnonymousUser get anonymousUser {
    final rawValue = get(UserData.anonymousUser, defaultValue: null);
    if (rawValue == null) {
      final newUser = AnonymousUser.create();
      anonymousUser = newUser;
      return newUser;
    }
    return AnonymousUser.fromJson(
      Map<String, dynamic>.from(rawValue),
    );
  }

  set anonymousUser(AnonymousUser user) {
    put(UserData.anonymousUser, user.toJson());
  }

  AuthTokens? get tokens {
    final rawValue = get(UserData.authTokens, defaultValue: null);
    if (rawValue == null) {
      return null;
    }
    return AuthTokens.fromJson(rawValue);
  }

  set tokens(AuthTokens? tokens) {
    put(UserData.authTokens, tokens?.toJson());
  }
}
