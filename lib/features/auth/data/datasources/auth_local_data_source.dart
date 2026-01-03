import 'package:hive/hive.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<UserModel?> getCurrentUser();
  Future<void> cacheUser(UserModel user);
  Future<void> deleteUser();
  Future<List<UserModel>> getAllCachedUsers();
  Future<void> cacheUsers(List<UserModel> users);
  Future<void> clearCache();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final Box<UserModel> userBox;
  final Box usersDbBox;

  AuthLocalDataSourceImpl({required this.userBox, required this.usersDbBox});

  @override
  Future<UserModel?> getCurrentUser() async {
    return userBox.get('currentUser');
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    await userBox.put('currentUser', user);
  }

  @override
  Future<void> deleteUser() async {
    await userBox.delete('currentUser');
  }

  @override
  Future<List<UserModel>> getAllCachedUsers() async {
    final List<UserModel> users = [];
    for (var value in usersDbBox.values) {
      if (value is Map) {
        users.add(UserModel.fromJson(Map<String, dynamic>.from(value)));
      }
    }
    return users;
  }

  @override
  Future<void> cacheUsers(List<UserModel> users) async {
    final Map<String, dynamic> userMap = {
      for (var user in users) user.email: user.toJson(),
    };
    await usersDbBox.putAll(userMap);
  }

  @override
  Future<void> clearCache() async {
    await userBox.clear();
    await usersDbBox.clear();
  }
}
