import '../datasources/music_local_data_source.dart';
import '../datasources/music_remote_data_source.dart';
import '../../../../core/network/server_health_data_source.dart';
import '../../domain/repositories/playlist_repository.dart';
import '../models/playlist_model.dart';

class PlaylistRepositoryImpl implements PlaylistRepository {
  final MusicLocalDataSource localDataSource;
  final MusicRemoteDataSource remoteDataSource;
  final ServerHealthDataSource serverHealthDataSource;

  PlaylistRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.serverHealthDataSource,
  });

  Future<void> _ensureServerRunning() async {
    final isRunning = await serverHealthDataSource.isServerRunning();
    if (!isRunning) {
      throw Exception(
        'Server is unreachable. This operation requires an active server connection.',
      );
    }
  }

  @override
  Future<List<PlaylistModel>> getPlaylists() async {
    // Return cached data immediately if available
    final localPlaylists = await localDataSource.getCachedPlaylists();

    // Trigger background sync
    _syncPlaylists();

    return localPlaylists;
  }

  Future<void> _syncPlaylists() async {
    try {
      final remotePlaylists = await remoteDataSource.getAllPlaylists();
      await localDataSource.cachePlaylists(remotePlaylists);
    } catch (e) {
      // Log error or handle silently for background sync
    }
  }

  @override
  Future<void> createPlaylist(PlaylistModel playlist) async {
    await _ensureServerRunning();
    await remoteDataSource.createPlaylist(playlist);
  }

  @override
  Future<void> deletePlaylist(String id) async {
    await _ensureServerRunning();
    // Must be executed on the server first
    await remoteDataSource.deletePlaylist(id);
    // After success, remove from Hive
    await localDataSource.deleteCachedPlaylist(id);
  }

  @override
  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    await _ensureServerRunning();
    // Read from local first to get existing playlist
    final localPlaylists = await localDataSource.getCachedPlaylists();
    final playlist = localPlaylists.firstWhere((p) => p.id == playlistId);

    final updatedSongs = List<String>.from(playlist.songIds)..add(songId);
    final updatedPlaylist = playlist.copyWith(songIds: updatedSongs);

    // Update on server first
    final savedPlaylist = await remoteDataSource.updatePlaylist(
      updatedPlaylist,
    );
    // After success, update Hive
    await localDataSource.cachePlaylist(savedPlaylist);
  }
}
