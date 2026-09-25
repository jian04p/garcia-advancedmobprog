import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../models/user.dart';

class UserService {
  static const _idKey = 'id';
  static const _usernameKey = 'username';
  static const _emailKey = 'email';
  static const _firstNameKey = 'firstName';
  static const _lastNameKey = 'lastName';
  static const _genderKey = 'gender';
  static const _imageKey = 'image';
  static const _accessTokenKey = 'accessToken';
  static const _refreshTokenKey = 'refreshToken';

  /// Enhancement 2: authenticates with DummyJSON and persists the response.
  Future<User> loginUser(String username, String password) async {
    final response = await http.post(
      Uri.parse('$host/auth/login'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'expiresInMins': 60,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Login failed (${response.statusCode}).');
    }

    final user = User.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
    if (user.id == 0 || user.accessToken.isEmpty) {
      throw Exception('The login response did not include a valid user.');
    }
    await saveUserData(user);
    return user;
  }

  /// Stores only the fields needed to restore the signed-in user next launch.
  Future<void> saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_idKey, user.id);
    await prefs.setString(_usernameKey, user.username);
    await prefs.setString(_emailKey, user.email);
    await prefs.setString(_firstNameKey, user.firstName);
    await prefs.setString(_lastNameKey, user.lastName);
    await prefs.setString(_genderKey, user.gender);
    await prefs.setString(_imageKey, user.image);
    await prefs.setString(_accessTokenKey, user.accessToken);
    await prefs.setString(_refreshTokenKey, user.refreshToken);
  }

  Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'id': prefs.getInt(_idKey) ?? 0,
      'username': prefs.getString(_usernameKey) ?? '',
      'email': prefs.getString(_emailKey) ?? '',
      'firstName': prefs.getString(_firstNameKey) ?? '',
      'lastName': prefs.getString(_lastNameKey) ?? '',
      'gender': prefs.getString(_genderKey) ?? '',
      'image': prefs.getString(_imageKey) ?? '',
      'accessToken': prefs.getString(_accessTokenKey) ?? '',
      'refreshToken': prefs.getString(_refreshTokenKey) ?? '',
    };
  }

  /// Enhancement 1: restores the persisted session during the splash screen.
  Future<User?> getSavedUser() async {
    final data = await getUserData();
    final user = User.fromJson(data);
    return user.id > 0 && user.accessToken.isNotEmpty ? user : null;
  }

  Future<bool> isLoggedIn() async => await getSavedUser() != null;

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
