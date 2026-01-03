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

  AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<UserModel> signIn(String email, String password) async {
    final response = await client.post(
      Uri.parse('$baseUrl/users/login'), // Assuming a login route exists
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(json.decode(response.body));
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
      return UserModel.fromJson(json.decode(response.body));
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
      return decoded.map((item) => UserModel.fromJson(item)).toList();
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
    final response = await client.put(
      Uri.parse('$baseUrl/users/${user.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(user.toJson()),
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update profile');
    }
  }
}
