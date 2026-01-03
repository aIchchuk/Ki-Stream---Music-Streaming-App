import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 1)
class UserModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String email;
  @HiveField(2)
  final String displayName;
  @HiveField(3)
  final String? photoUrl;
  @HiveField(4)
  final String? password;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.password,
  });

  UserModel copyWith({
    String? email,
    String? displayName,
    String? photoUrl,
    String? password,
  }) {
    return UserModel(
      id: id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      password: password ?? this.password,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': displayName,
      'userImageUrl': photoUrl,
      'password': password,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      email: json['email'] ?? '',
      displayName: json['fullName'] ?? json['displayName'] ?? '',
      photoUrl: json['userImageUrl'] ?? json['photoUrl'],
      password: json['password'],
    );
  }
}
