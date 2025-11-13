import 'package:core/core.dart';

enum UserData {
  anonymousUser,
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
}
