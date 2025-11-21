import 'package:core/core.dart';
import 'package:core_remote_data/core_remote_data.dart';
import 'package:flutter/material.dart';
import 'package:simon/data/user_data.dart';
import 'package:simon/simon.dart';

class AuthViewModel extends ChangeNotifier {
  AuthApis get _apis => injector<AuthApis>();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AuthTokens? _tokens = SettingsBox().tokens;

  AuthTokens? get tokens => _tokens;

  User? _user;
  User? get user => _user;

  Future<Failure?> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _apis.login(
        username: username,
        password: password,
      );

      if (result == null) {
        return const Failure('Login failed: No tokens received');
      }

      _isLoading = false;
      _tokens = tokens;
      SettingsBox().tokens = tokens;
      notifyListeners();
      return null;
    } on Failure catch (failure) {
      _isLoading = false;
      notifyListeners();
      return failure;
    } catch (err, trace) {
      printError(err, trace);
      _isLoading = false;
      notifyListeners();
      return Failure(err.toString());
    }
  }
}
