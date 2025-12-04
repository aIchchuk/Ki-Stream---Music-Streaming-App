import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final GoogleSignIn _googleSignIn;
  final Box<UserModel> _userBox;
  final Box _usersDbBox;

  AuthRepositoryImpl(this._googleSignIn, this._userBox, this._usersDbBox);

  @override
  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account != null) {
        final user = UserModel(
          id: account.id,
          email: account.email,
          displayName: account.displayName ?? 'User',
          photoUrl: account.photoUrl,
        );
        // Save to session box
        await _userBox.put('currentUser', user);
        return user;
      }
    } catch (e) {
      // Handle error
    }
    return null;
  }

  @override
  Future<UserModel?> signIn(String email, String password) async {
    try {
      final userData = _usersDbBox.get(email);
      if (userData != null) {
        final localUser = UserModel.fromJson(
          Map<String, dynamic>.from(userData),
        );
        if (localUser.password == password) {
          await _userBox.put('currentUser', localUser);
          return localUser;
        } else {
          throw Exception('Invalid credentials');
        }
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  @override
  Future<UserModel?> signUp(String email, String password, String name) async {
    try {
      if (_usersDbBox.containsKey(email)) {
        throw Exception('User already exists');
      }

      final newUser = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        displayName: name,
        password: password,
        photoUrl: '',
      );

      // Save to DB box
      await _usersDbBox.put(email, newUser.toJson());

      // Log them in locally (session)
      await _userBox.put('currentUser', newUser);

      return newUser;
    } catch (e) {
      throw Exception('Signup error: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _userBox.delete('currentUser');
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    return _userBox.get('currentUser');
  }

  @override
  Future<bool> get isSignedIn async {
    return _userBox.containsKey('currentUser');
  }

  @override
  Future<void> updateProfilePhoto(String path) async {
    final currentUser = _userBox.get('currentUser');
    if (currentUser != null) {
      final updatedUser = currentUser.copyWith(photoUrl: path);
      await _userBox.put('currentUser', updatedUser);

      if (_usersDbBox.containsKey(currentUser.email)) {
        final userData = Map<String, dynamic>.from(
          _usersDbBox.get(currentUser.email),
        );
        userData['userImageUrl'] = path;
        await _usersDbBox.put(currentUser.email, userData);
      }
    }
  }

  @override
  Future<void> updateEmail(String newEmail) async {
    final currentUser = _userBox.get('currentUser');
    if (currentUser != null) {
      final oldEmail = currentUser.email;
      final updatedUser = currentUser.copyWith(email: newEmail);
      await _userBox.put('currentUser', updatedUser);

      if (_usersDbBox.containsKey(oldEmail)) {
        final userData = _usersDbBox.get(oldEmail);
        await _usersDbBox.delete(oldEmail);
        await _usersDbBox.put(newEmail, userData);
      }
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    final currentUser = _userBox.get('currentUser');
    if (currentUser != null) {
      final updatedUser = currentUser.copyWith(password: newPassword);
      await _userBox.put('currentUser', updatedUser);

      if (_usersDbBox.containsKey(currentUser.email)) {
        final userData = Map<String, dynamic>.from(
          _usersDbBox.get(currentUser.email),
        );
        userData['password'] = newPassword;
        await _usersDbBox.put(currentUser.email, userData);
      }
    }
  }

  @override
  Future<void> updateDisplayName(String newName) async {
    final currentUser = _userBox.get('currentUser');
    if (currentUser != null) {
      final updatedUser = currentUser.copyWith(displayName: newName);
      await _userBox.put('currentUser', updatedUser);

      if (_usersDbBox.containsKey(currentUser.email)) {
        final userData = Map<String, dynamic>.from(
          _usersDbBox.get(currentUser.email),
        );
        userData['fullName'] = newName;
        await _usersDbBox.put(currentUser.email, userData);
      }
    }
  }

  @override
  Future<void> deleteAccount() async {
    final currentUser = _userBox.get('currentUser');
    if (currentUser != null) {
      await _usersDbBox.delete(currentUser.email);
    }
    await signOut();
  }

  @override
  Future<List<UserModel>> getAllUsers() async {
    final List<UserModel> users = [];
    for (var value in _usersDbBox.values) {
      if (value is Map) {
        users.add(UserModel.fromJson(Map<String, dynamic>.from(value)));
      }
    }
    return users;
  }

  @override
  Future<void> deleteUser(String email) async {
    await _usersDbBox.delete(email);
  }
}
