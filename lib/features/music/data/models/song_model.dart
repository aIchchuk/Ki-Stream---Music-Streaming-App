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
    );
  }
}
