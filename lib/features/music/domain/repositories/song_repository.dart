import 'package:kistream/features/music/data/models/song_model.dart';

abstract class SongRepository {
  Future<List<SongModel>> getSongs();
  Future<void> addSong(SongModel song);
  Future<void> deleteSong(String id);
  Future<void> toggleFavorite(SongModel song);
  Future<void> clearLocalCache();
}
