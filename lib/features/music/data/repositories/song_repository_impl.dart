import 'package:hive/hive.dart';
import '../../domain/repositories/song_repository.dart';
import '../models/song_model.dart';

class SongRepositoryImpl implements SongRepository {
  final Box<SongModel> _songBox;

  SongRepositoryImpl(this._songBox);

  @override
  Future<List<SongModel>> getSongs() async {
    return _songBox.values.toList();
  }

  @override
  Future<void> addSong(SongModel song) async {
    await _songBox.put(song.id, song);
  }

  @override
  Future<void> deleteSong(String id) async {
    await _songBox.delete(id);
  }

  @override
  Future<void> toggleFavorite(SongModel song) async {
    final existingSong = _songBox.get(song.id);
    if (existingSong != null) {
      final updatedSong = existingSong.copyWith(
        isFavorite: !(existingSong.isFavorite ?? false),
      );
      await _songBox.put(song.id, updatedSong);
    } else {
      final newSong = song.copyWith(isFavorite: true);
      await _songBox.put(song.id, newSong);
    }
  }
}
