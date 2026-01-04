import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:google_sign_in/google_sign_in.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../../../../core/network/server_health_data_source.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final GoogleSignIn _googleSignIn;
  final AuthLocalDataSource localDataSource;
  final AuthRemoteDataSource remoteDataSource;
  final ServerHealthDataSource serverHealthDataSource;

  AuthRepositoryImpl({
    required GoogleSignIn googleSignIn,
    required this.localDataSource,
    required this.remoteDataSource,
    required this.serverHealthDataSource,
  }) : _googleSignIn = googleSignIn;

  Future<void> _ensureServerRunning() async {
    final isRunning = await serverHealthDataSource.isServerRunning();
    if (!isRunning) {
      throw Exception(
        'Server is unreachable. This operation requires an active server connection.',
      );
    }
  }

  @override
  Future<UserModel?> signInWithGoogle() async {
    await _ensureServerRunning();
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account != null) {
        UserModel user = UserModel(
          id: account.id,
          email: account.email,
          displayName: account.displayName ?? 'User',
          photoUrl: account.photoUrl,
        );

        user = await _downloadAndCacheProfileImage(user);

        await localDataSource.cacheUser(user);
        return user;
      }
    } catch (e) {
      // Handle error
    }
    return null;
  }

  @override
  Future<UserModel?> signIn(String email, String password) async {
    await _ensureServerRunning();
    // Must go through server first
    UserModel user = await remoteDataSource.signIn(email, password);
    // Download and cache image for offline
    user = await _downloadAndCacheProfileImage(user);
    // On success, cache user
    await localDataSource.cacheUser(user);
    return user;
  }

  @override
  Future<UserModel?> signUp(String email, String password, String name) async {
    await _ensureServerRunning();
    // Must go through server first
    UserModel user = await remoteDataSource.signUp(email, password, name);
    // Download and cache image for offline
    user = await _downloadAndCacheProfileImage(user);
    // On success, cache user
    await localDataSource.cacheUser(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await localDataSource.deleteUser();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    return localDataSource.getCurrentUser();
  }

  @override
  Future<bool> get isSignedIn async {
    final user = await localDataSource.getCurrentUser();
    return user != null;
  }

  @override
  Future<void> updateProfilePhoto(String path) async {
    final currentUser = await localDataSource.getCurrentUser();
    if (currentUser != null) {
      await _ensureServerRunning();
      final updatedUser = currentUser.copyWith(photoUrl: path);
      // Update on server first
      UserModel savedUser = await remoteDataSource.updateProfile(updatedUser);
      // Download and cache image for offline
      savedUser = await _downloadAndCacheProfileImage(savedUser);
      // Update local cache
      await localDataSource.cacheUser(savedUser);
    }
  }

  @override
  Future<void> updateEmail(String newEmail) async {
    final currentUser = await localDataSource.getCurrentUser();
    if (currentUser != null) {
      await _ensureServerRunning();
      final updatedUser = currentUser.copyWith(email: newEmail);
      // Update on server first
      UserModel savedUser = await remoteDataSource.updateProfile(updatedUser);
      // Download and cache image for offline
      savedUser = await _downloadAndCacheProfileImage(savedUser);
      // Update local cache
      await localDataSource.cacheUser(savedUser);
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    final currentUser = await localDataSource.getCurrentUser();
    if (currentUser != null) {
      await _ensureServerRunning();
      final updatedUser = currentUser.copyWith(password: newPassword);
      // Update on server first
      UserModel savedUser = await remoteDataSource.updateProfile(updatedUser);
      // Download and cache image for offline
      savedUser = await _downloadAndCacheProfileImage(savedUser);
      // Update local cache
      await localDataSource.cacheUser(savedUser);
    }
  }

  @override
  Future<void> updateDisplayName(String newName) async {
    final currentUser = await localDataSource.getCurrentUser();
    if (currentUser != null) {
      await _ensureServerRunning();
      final updatedUser = currentUser.copyWith(displayName: newName);
      // Update on server first
      UserModel savedUser = await remoteDataSource.updateProfile(updatedUser);
      // Download and cache image for offline
      savedUser = await _downloadAndCacheProfileImage(savedUser);
      // Update local cache
      await localDataSource.cacheUser(savedUser);
    }
  }

  @override
  Future<void> deleteAccount() async {
    final currentUser = await localDataSource.getCurrentUser();
    if (currentUser != null) {
      await _ensureServerRunning();
      // Delete from server first
      await remoteDataSource.deleteAccount(currentUser.id);
    }
    await signOut();
  }

  @override
  Future<List<UserModel>> getAllUsers() async {
    // Return cached users immediately
    final localUsers = await localDataSource.getAllCachedUsers();

    // Background sync
    _syncUsers();

    return localUsers;
  }

  Future<void> _syncUsers() async {
    try {
      final remoteUsers = await remoteDataSource.getAllUsers();
      final List<UserModel> updatedUsers = [];
      for (var user in remoteUsers) {
        final updatedUser = await _downloadAndCacheProfileImage(user);
        updatedUsers.add(updatedUser);
      }
      await localDataSource.cacheUsers(updatedUsers);
    } catch (e) {
      // Handle sync error
    }
  }

  @override
  Future<void> deleteUser(String id) async {
    await _ensureServerRunning();
    // Delete from server first
    await remoteDataSource.deleteUser(id);
    // Sync local cache
    await localDataSource.deleteCachedUser(id);
  }

  @override
  Future<void> clearLocalCache() async {
    await localDataSource.clearCache();
  }

  Future<UserModel> _downloadAndCacheProfileImage(UserModel user) async {
    if (user.photoUrl == null ||
        user.photoUrl!.isEmpty ||
        !user.photoUrl!.startsWith('http')) {
      return user;
    }

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final profileDir = Directory(p.join(appDir.path, 'profile'));
      if (!await profileDir.exists()) {
        await profileDir.create(recursive: true);
      }

      final fileName =
          'profile_${user.id}${p.extension(user.photoUrl!.split('?').first)}';
      final localFile = File(p.join(profileDir.path, fileName));

      final response = await http.get(Uri.parse(user.photoUrl!));
      if (response.statusCode == 200) {
        await localFile.writeAsBytes(response.bodyBytes);
        return user.copyWith(photoUrl: localFile.path);
      }
    } catch (e) {
      print('Error downloading profile image: $e');
    }
    return user;
  }
}
