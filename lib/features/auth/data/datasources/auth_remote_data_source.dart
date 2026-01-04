import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signIn(String email, String password);
  Future<UserModel> signUp(String email, String password, String name);
  Future<void> deleteAccount(String id);
  Future<List<UserModel>> getAllUsers();
  Future<void> deleteUser(String id);
  Future<UserModel> updateProfile(UserModel user);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;
  final String baseUrl = ApiConstants.baseUrl;
  final String baseStaticUrl = ApiConstants.baseStaticUrl;

  AuthRemoteDataSourceImpl({required this.client});

  String _resolveAssetUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return '$baseStaticUrl/$path';
  }

  @override
  Future<UserModel> signIn(String email, String password) async {
    final response = await client.post(
      Uri.parse('$baseUrl/users/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final user = UserModel.fromJson(json.decode(response.body));
      return user.copyWith(photoUrl: _resolveAssetUrl(user.photoUrl));
    } else {
      final error = json.decode(response.body)['message'] ?? 'Login failed';
      throw Exception(error);
    }
  }

  @override
  Future<UserModel> signUp(String email, String password, String name) async {
    final response = await client.post(
      Uri.parse('$baseUrl/users'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
        'fullName': name,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final user = UserModel.fromJson(json.decode(response.body));
      return user.copyWith(photoUrl: _resolveAssetUrl(user.photoUrl));
    } else {
      final error = json.decode(response.body)['message'] ?? 'Signup failed';
      throw Exception(error);
    }
  }

  @override
  Future<void> deleteAccount(String id) async {
    final response = await client.delete(Uri.parse('$baseUrl/users/$id'));

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete account');
    }
  }

  @override
  Future<List<UserModel>> getAllUsers() async {
    final response = await client.get(Uri.parse('$baseUrl/users'));

    if (response.statusCode == 200) {
      final List decoded = json.decode(response.body);
      return decoded.map((item) {
        final user = UserModel.fromJson(item);
        return user.copyWith(photoUrl: _resolveAssetUrl(user.photoUrl));
      }).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  @override
  Future<void> deleteUser(String id) async {
    final response = await client.delete(Uri.parse('$baseUrl/users/$id'));

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete user');
    }
  }

  @override
  Future<UserModel> updateProfile(UserModel user) async {
    final uri = Uri.parse('$baseUrl/users/${user.id}');
    final request = http.MultipartRequest('PUT', uri);

    request.fields['fullName'] = user.displayName;
    request.fields['email'] = user.email;
    if (user.password != null) {
      request.fields['password'] = user.password!;
    }

    if (user.photoUrl != null &&
        user.photoUrl!.isNotEmpty &&
        !user.photoUrl!.startsWith('http')) {
      final file = File(user.photoUrl!);
      if (await file.exists()) {
        request.files.add(
          await http.MultipartFile.fromPath('userImageUrl', file.path),
        );
      } else {
        request.fields['userImageUrl'] = user.photoUrl!;
      }
    } else if (user.photoUrl != null) {
      request.fields['userImageUrl'] = user.photoUrl!;
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final user = UserModel.fromJson(json.decode(response.body));
      return user.copyWith(photoUrl: _resolveAssetUrl(user.photoUrl));
    } else {
      throw Exception('Failed to update profile');
    }
  }
}
