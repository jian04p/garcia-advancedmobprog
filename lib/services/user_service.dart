import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../models/user.dart';

class UserService {
  static const _profileKey = 'saved_user_profile';
  firebase_auth.FirebaseAuth get _firebaseAuth =>
      firebase_auth.FirebaseAuth.instance;

  firebase_auth.User? get currentUser =>
      Firebase.apps.isEmpty ? null : _firebaseAuth.currentUser;

  Stream<firebase_auth.User?> get authStateChanges => Firebase.apps.isEmpty
      ? const Stream<firebase_auth.User?>.empty()
      : _firebaseAuth.authStateChanges();

  /// Lab 5 Enhancement 1: Firebase email/password sign-in.
  Future<firebase_auth.UserCredential> signIn({
    required String email,
    required String password,
  }) {
    _requireFirebase();
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Lab 5 Enhancement 1: creates an account through Firebase Auth.
  Future<firebase_auth.UserCredential> createAccount({
    required String email,
    required String password,
  }) {
    _requireFirebase();
    return _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Lab 5 Enhancement 1: updates the Firebase display name and saved profile.
  Future<void> updateUsername({required String username}) async {
    _requireFirebase();
    final firebaseUser = _requireCurrentFirebaseUser();
    await firebaseUser.updateDisplayName(username);
    await firebaseUser.reload();
    final user = await getUserData();
    if (user != null) await saveUserData(user.copyWith(username: username));
  }

  /// Lab 5 Enhancement 1: reauthenticates, deletes the account, then signs out.
  Future<void> deleteAccount({
    required String email,
    required String password,
  }) async {
    _requireFirebase();
    final firebaseUser = _requireCurrentFirebaseUser();
    final credential = firebase_auth.EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    await firebaseUser.reauthenticateWithCredential(credential);
    await firebaseUser.delete();
    await _clearSavedUser();
  }

  /// Lab 5 Enhancement 1: reauthenticates before changing the password.
  Future<void> resetPasswordFromCurrentPassword({
    required String currentPassword,
    required String newPassword,
    required String email,
  }) async {
    _requireFirebase();
    final firebaseUser = _requireCurrentFirebaseUser();
    final credential = firebase_auth.EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );
    await firebaseUser.reauthenticateWithCredential(credential);
    await firebaseUser.updatePassword(newPassword);
  }

  /// Preserves the Lab 4 DummyJSON path for the required login-type comparison.
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
    ).copyWith(loginType: LoginType.dummyJson);
    if (user.id == 0 || user.accessToken.isEmpty) {
      throw Exception('The login response did not include a valid user.');
    }
    await saveUserData(user);
    return user;
  }

  Future<void> saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(user.toJson()));
  }

  /// Lab 5 Enhancement 3: exposes the current DummyJSON or Firebase profile.
  Future<User?> getUserData() async {
    final storedUser = await _getStoredUser();
    if (Firebase.apps.isNotEmpty && _firebaseAuth.currentUser != null) {
      final firebaseUser = _firebaseAuth.currentUser!;
      final hasMatchingSavedProfile =
          storedUser?.loginType == LoginType.firebase &&
          storedUser?.firebaseUid == firebaseUser.uid;
      final profile = hasMatchingSavedProfile
          ? storedUser!
          : User(
              id: 0,
              username: firebaseUser.displayName ?? '',
              email: firebaseUser.email ?? '',
              firstName: '',
              lastName: '',
              gender: '',
              image: firebaseUser.photoURL ?? '',
              accessToken: '',
              refreshToken: '',
              loginType: LoginType.firebase,
              firebaseUid: firebaseUser.uid,
            );
      return profile.copyWith(
        username: firebaseUser.displayName ?? profile.username,
        email: firebaseUser.email ?? profile.email,
        firebaseUid: firebaseUser.uid,
        loginType: LoginType.firebase,
      );
    }
    return storedUser?.loginType == LoginType.dummyJson ? storedUser : null;
  }

  Future<User?> getSavedUser() => getUserData();

  Future<bool> isLoggedIn() async => await getUserData() != null;

  /// Lab 5 Enhancement 1: clears the Firebase/local session for logout.
  Future<void> signOut() async {
    if (Firebase.apps.isNotEmpty && _firebaseAuth.currentUser != null) {
      await _firebaseAuth.signOut();
    }
    await _clearSavedUser();
  }

  Future<void> logout() => signOut();

  Future<User?> _getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedUser = prefs.getString(_profileKey);
    if (encodedUser == null || encodedUser.isEmpty) return null;
    return User.fromJson(jsonDecode(encodedUser) as Map<String, dynamic>);
  }

  Future<void> _clearSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileKey);
  }

  void _requireFirebase() {
    if (Firebase.apps.isEmpty) {
      throw StateError('Firebase is not initialized.');
    }
  }

  firebase_auth.User _requireCurrentFirebaseUser() {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) {
      throw StateError('No Firebase user is signed in.');
    }
    return firebaseUser;
  }
}
