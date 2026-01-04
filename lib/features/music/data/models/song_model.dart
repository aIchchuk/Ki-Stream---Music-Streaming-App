import 'package:hive/hive.dart';

part 'song_model.g.dart';

@HiveType(typeId: 0)
class SongModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String songName;

  @HiveField(2)
  final String artistName;

  @HiveField(3)
  final String songImage;

  @HiveField(4)
  final String audioFile;

  @HiveField(5)
  final DateTime dateAdded;

  @HiveField(6)
  final String? albumName;

  @HiveField(7)
  final bool? isManual;

  @HiveField(8)
  final bool? isFavorite;

  @HiveField(9)
  final bool? isDownloaded;

  SongModel({
    required this.id,
    required this.songName,
    required this.artistName,
    required this.songImage,
    required this.audioFile,
    required this.dateAdded,
    this.albumName,
    this.isManual,
    this.isFavorite = false,
    this.isDownloaded = false,
  });

  SongModel copyWith({
    String? id,
    String? songName,
    String? artistName,
    String? songImage,
    String? audioFile,
    DateTime? dateAdded,
    String? albumName,
    bool? isManual,
    bool? isFavorite,
    bool? isDownloaded,
  }) {
    return SongModel(
      id: id ?? this.id,
      songName: songName ?? this.songName,
      artistName: artistName ?? this.artistName,
      songImage: songImage ?? this.songImage,
      audioFile: audioFile ?? this.audioFile,
      dateAdded: dateAdded ?? this.dateAdded,
      albumName: albumName ?? this.albumName,
      isManual: isManual ?? this.isManual,
      isFavorite: isFavorite ?? this.isFavorite,
      isDownloaded: isDownloaded ?? this.isDownloaded,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'songName': songName,
      'artistName': artistName,
      'songImage': songImage,
      'audioFile': audioFile,
      'dateAdded': dateAdded.toIso8601String(),
      'albumName': albumName,
      'isManual': isManual,
      'isFavorite': isFavorite,
      'isDownloaded': isDownloaded,
    };
  }

  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      id: json['id'] ?? json['_id'] ?? '',
      songName: json['songName'] ?? '',
      artistName: json['artistName'] ?? '',
      songImage: json['songImage'] ?? '',
      audioFile: json['audioFile'] ?? '',
      dateAdded: json['dateAdded'] != null
          ? DateTime.parse(json['dateAdded'])
          : DateTime.now(),
      albumName: json['albumName'],
      isManual: json['isManual'],
      isFavorite: json['isFavorite'] ?? false,
      isDownloaded: json['isDownloaded'] ?? false,
    );
  }
}
