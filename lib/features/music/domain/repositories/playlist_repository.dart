import '../../data/models/playlist_model.dart';

abstract class PlaylistRepository {
  Future<List<PlaylistModel>> getPlaylists();
  Future<void> createPlaylist(PlaylistModel playlist);
  Future<void> deletePlaylist(String id);
  Future<void> addSongToPlaylist(String playlistId, String songId);
}
