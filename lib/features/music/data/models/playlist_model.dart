import 'package:hive/hive.dart';

part 'playlist_model.g.dart';

@HiveType(typeId: 2)
class PlaylistModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String mood;

  @HiveField(3)
  final List<String> songIds;

  @HiveField(4)
  final DateTime dateCreated;

  @HiveField(5)
  final String? imagePath;

  @HiveField(6)
  final String? creatorId;

  @HiveField(7)
  final String? creatorName;

  PlaylistModel({
    required this.id,
    required this.name,
    required this.mood,
    required this.songIds,
    required this.dateCreated,
    this.imagePath,
    this.creatorId,
    this.creatorName,
  });

  PlaylistModel copyWith({
    String? id,
    String? name,
    String? mood,
    List<String>? songIds,
    DateTime? dateCreated,
    String? imagePath,
    String? creatorId,
    String? creatorName,
  }) {
    return PlaylistModel(
      id: id ?? this.id,
      name: name ?? this.name,
      mood: mood ?? this.mood,
      songIds: songIds ?? this.songIds,
      dateCreated: dateCreated ?? this.dateCreated,
      imagePath: imagePath ?? this.imagePath,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mood': mood,
      'songIds': songIds,
      'dateCreated': dateCreated.toIso8601String(),
      'imagePath': imagePath,
      'creatorId': creatorId,
      'creatorName': creatorName,
    };
  }

  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    return PlaylistModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      mood: json['mood'] ?? '',
      songIds: List<String>.from(json['songIds'] ?? []),
      dateCreated: json['dateCreated'] != null
          ? DateTime.parse(json['dateCreated'])
          : DateTime.now(),
      imagePath: json['imagePath'],
      creatorId: json['creatorId'],
      creatorName: json['creatorName'],
    );
  }
}
