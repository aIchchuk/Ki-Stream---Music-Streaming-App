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
        final user = UserModel(
          id: account.id,
          email: account.email,
          displayName: account.displayName ?? 'User',
          photoUrl: account.photoUrl,
        );

        // In a real app, we would also verify this user with our server
        // and get the server-side user object (with ID, etc.)
        // For now, following the pattern of caching after success.

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
    final user = await remoteDataSource.signIn(email, password);
    // On success, cache user
    await localDataSource.cacheUser(user);
    return user;
  }

  @override
  Future<UserModel?> signUp(String email, String password, String name) async {
    await _ensureServerRunning();
    // Must go through server first
    final user = await remoteDataSource.signUp(email, password, name);
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
      final savedUser = await remoteDataSource.updateProfile(updatedUser);
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
      final savedUser = await remoteDataSource.updateProfile(updatedUser);
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
      final savedUser = await remoteDataSource.updateProfile(updatedUser);
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
      final savedUser = await remoteDataSource.updateProfile(updatedUser);
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
      await localDataSource.cacheUsers(remoteUsers);
    } catch (e) {
      // Handle sync error
    }
  }

  @override
  Future<void> deleteUser(String id) async {
    await _ensureServerRunning();
    // Delete from server first
    await remoteDataSource.deleteUser(id);
    // No specific local delete for a specific user in library yet,
    // but the next sync will handle it.
  }

  @override
  Future<void> clearLocalCache() async {
    await localDataSource.clearCache();
  }
}
