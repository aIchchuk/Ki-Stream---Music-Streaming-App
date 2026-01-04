import 'package:hive/hive.dart';
import '../models/song_model.dart';
import '../models/playlist_model.dart';

abstract class MusicLocalDataSource {
  Future<List<SongModel>> getCachedSongs();
  Future<void> cacheSongs(List<SongModel> songs);
  Future<void> cacheSong(SongModel song);
  Future<void> deleteCachedSong(String id);

  Future<List<SongModel>> getDownloadedSongs();
  Future<void> saveDownloadedSong(SongModel song);
  Future<void> deleteDownloadedSong(String id);

  Future<List<PlaylistModel>> getCachedPlaylists();
  Future<void> cachePlaylists(List<PlaylistModel> playlists);
  Future<void> cachePlaylist(PlaylistModel playlist);
  Future<void> deleteCachedPlaylist(String id);
  Future<void> clearCache();
}

class MusicLocalDataSourceImpl implements MusicLocalDataSource {
  final Box<SongModel> songBox;
  final Box<SongModel> downloadedSongsBox;
  final Box<PlaylistModel> playlistBox;

  MusicLocalDataSourceImpl({
    required this.songBox,
    required this.downloadedSongsBox,
    required this.playlistBox,
  });

  @override
  Future<List<SongModel>> getCachedSongs() async {
    return songBox.values.toList();
  }

  @override
  Future<void> cacheSongs(List<SongModel> songs) async {
    final Map<String, SongModel> songMap = {
      for (var song in songs) song.id: song,
    };
    await songBox.putAll(songMap);
  }

  @override
  Future<void> cacheSong(SongModel song) async {
    await songBox.put(song.id, song);
  }

  @override
  Future<void> deleteCachedSong(String id) async {
    await songBox.delete(id);
  }

  @override
  Future<List<SongModel>> getDownloadedSongs() async {
    return downloadedSongsBox.values.toList();
  }

  @override
  Future<void> saveDownloadedSong(SongModel song) async {
    await downloadedSongsBox.put(song.id, song);
  }

  @override
  Future<void> deleteDownloadedSong(String id) async {
    await downloadedSongsBox.delete(id);
  }

  @override
  Future<List<PlaylistModel>> getCachedPlaylists() async {
    return playlistBox.values.toList();
  }

  @override
  Future<void> cachePlaylists(List<PlaylistModel> playlists) async {
    final Map<String, PlaylistModel> playlistMap = {
      for (var playlist in playlists) playlist.id: playlist,
    };
    await playlistBox.putAll(playlistMap);
  }

  @override
  Future<void> cachePlaylist(PlaylistModel playlist) async {
    await playlistBox.put(playlist.id, playlist);
  }

  @override
  Future<void> deleteCachedPlaylist(String id) async {
    await playlistBox.delete(id);
  }

  @override
  Future<void> clearCache() async {
    await songBox.clear();
    await downloadedSongsBox.clear();
    await playlistBox.clear();
  }
}
