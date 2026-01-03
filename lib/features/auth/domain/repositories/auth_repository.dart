import '../../data/models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel?> signInWithGoogle();
  Future<UserModel?> signIn(String email, String password);
  Future<UserModel?> signUp(String email, String password, String name);
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Future<bool> get isSignedIn;
  Future<void> updateProfilePhoto(String path);
  Future<void> updateEmail(String newEmail);
  Future<void> updatePassword(String newPassword);
  Future<void> updateDisplayName(String newName);
  Future<void> deleteAccount();

  // Admin methods
  Future<List<UserModel>> getAllUsers();
  Future<void> deleteUser(String id);
  Future<void> clearLocalCache();
}
