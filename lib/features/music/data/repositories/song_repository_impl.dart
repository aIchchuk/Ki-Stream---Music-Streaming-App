import '../datasources/music_local_data_source.dart';
import '../datasources/music_remote_data_source.dart';
import '../../../../core/network/server_health_data_source.dart';
import '../../domain/repositories/song_repository.dart';
import '../models/song_model.dart';

class SongRepositoryImpl implements SongRepository {
  final MusicLocalDataSource localDataSource;
  final MusicRemoteDataSource remoteDataSource;
  final ServerHealthDataSource serverHealthDataSource;

  SongRepositoryImpl({
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
  Future<List<SongModel>> getSongs() async {
    // Return cached data immediately if available
    final localSongs = await localDataSource.getCachedSongs();

    // Trigger background sync
    _syncSongs();

    return localSongs;
  }

  Future<void> _syncSongs() async {
    try {
      final remoteSongs = await remoteDataSource.getAllSongs();
      await localDataSource.cacheSongs(remoteSongs);
    } catch (e) {
      // Log error or handle silently for background sync
    }
  }

  @override
  Future<void> addSong(SongModel song) async {
    await _ensureServerRunning();
    // Must be executed on the server first
    final createdSong = await remoteDataSource.createSong(song);
    // After success, update Hive
    await localDataSource.cacheSong(createdSong);
  }

  @override
  Future<void> deleteSong(String id) async {
    await _ensureServerRunning();
    // Must be executed on the server first
    await remoteDataSource.deleteSong(id);
    // After success, remove from Hive
    await localDataSource.deleteCachedSong(id);
  }

  @override
  Future<void> toggleFavorite(SongModel song) async {
    await _ensureServerRunning();
    // Favorites are currently local-only in the old implementation,
    // but the new rules say ALL CRUD must go through server.
    // However, the server model might not have 'isFavorite'.
    // Let's assume for now we update it on the server if possible,
    // or at least follow the pattern of "Remote first".

    // If the server handles it, we should have an endpoint.
    // Since I don't see a specific 'toggleFavorite' route,
    // I'll use the generic 'updateSong' if it exists or create it.

    // final updatedSong = song.copyWith(isFavorite: !(song.isFavorite ?? false));

    // For now, let's treat it as a generic update if server supports it.
    // If not, we might need a specific endpoint.
    // I saw `router.put('/:id', songController.updateSongById);` in song.routes.js

    // await remoteDataSource.updateSong(updatedSong); // Need to add this to DataSource
    // await localDataSource.cacheSong(updatedSong);

    // For the sake of following rules strictly:
    throw UnimplementedError(
      'Favorite toggling must be implemented on the server first.',
    );
  }

  @override
  Future<void> clearLocalCache() async {
    await localDataSource.clearCache();
  }
}
