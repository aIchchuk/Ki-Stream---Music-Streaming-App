import 'package:hive/hive.dart';
import '../../domain/repositories/playlist_repository.dart';
import '../models/playlist_model.dart';

class PlaylistRepositoryImpl implements PlaylistRepository {
  final Box<PlaylistModel> _playlistBox;

  PlaylistRepositoryImpl(this._playlistBox);

  @override
  Future<List<PlaylistModel>> getPlaylists() async {
    return _playlistBox.values.toList();
  }

  @override
  Future<void> createPlaylist(PlaylistModel playlist) async {
    await _playlistBox.put(playlist.id, playlist);
  }

  @override
  Future<void> deletePlaylist(String id) async {
    await _playlistBox.delete(id);
  }

  @override
  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    final playlist = _playlistBox.get(playlistId);
    if (playlist != null) {
      final updatedSongs = List<String>.from(playlist.songIds)..add(songId);
      final updatedPlaylist = playlist.copyWith(songIds: updatedSongs);
      await _playlistBox.put(playlistId, updatedPlaylist);
    }
  }
}
