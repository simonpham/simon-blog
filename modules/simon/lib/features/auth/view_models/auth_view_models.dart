import 'dart:convert';

import 'package:core/core.dart';
import 'package:core_remote_data/core_remote_data.dart';
import 'package:flutter/material.dart';
import 'package:simon/data/user_data.dart';
import 'package:simon/simon.dart';

class AuthViewModel extends ChangeNotifier {
  AuthApis get _apis => injector<AuthApis>();
  UserApis get _userApis => injector<UserApis>();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AuthTokens? _tokens = SettingsBox().tokens;

  AuthTokens? get tokens => _tokens;

  User? _user;
  User? get user => _user;

  AuthViewModel() {
    if (_tokens != null) {
      loadUser();
    }
  }

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
      _tokens = result;
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

  void logout() {
    // TODO: add logout API to clear session.
    _isLoading = false;
    _tokens = null;
    _user = null;
    SettingsBox().tokens = null;
    notifyListeners();
  }

  Future<Failure?> loadUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      // For now get from access token.
      // TODO: add me API to get currently logged-in user info.
      final accessToken = tokens?.accessToken;
      if (accessToken == null) {
        return const Failure('Load user failed: No access token');
      }

      final jwtBody = accessToken.split('.')[1];
      final jwtDecodedBytes = base64.decode(jwtBody);
      final jwtDecoded = utf8.decode(jwtDecodedBytes);
      final jwtMap = jsonDecode(jwtDecoded);
      final sub = jwtMap['sub'] as String;

      final result = await _userApis.get(sub);
      if (result == null) {
        return const Failure('Load user failed: No user received');
      }

      _isLoading = false;
      _user = result;
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
