import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
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
    final localSongs = await localDataSource.getCachedSongs();
    _syncSongs();
    return localSongs;
  }

  Future<void> _syncSongs() async {
    try {
      final remoteSongs = await remoteDataSource.getAllSongs();
      await localDataSource.cacheSongs(remoteSongs);
    } catch (e) {
      // Background sync failed
    }
  }

  @override
  Future<void> addSong(SongModel song) async {
    await _ensureServerRunning();
    await remoteDataSource.createSong(song);
  }

  @override
  Future<void> deleteSong(String id) async {
    await _ensureServerRunning();
    await remoteDataSource.deleteSong(id);
    await localDataSource.deleteCachedSong(id);
  }

  @override
  Future<void> toggleFavorite(SongModel song) async {
    await _ensureServerRunning();
    final updatedSong = song.copyWith(isFavorite: !(song.isFavorite ?? false));
    final savedSong = await remoteDataSource.updateSong(updatedSong);
    await localDataSource.cacheSong(savedSong);
  }

  @override
  Future<List<SongModel>> getDownloadedSongs() async {
    return localDataSource.getDownloadedSongs();
  }

  @override
  Future<void> downloadSong(SongModel song) async {
    await _ensureServerRunning();

    final appDir = await getApplicationDocumentsDirectory();
    final downloadsDir = Directory(p.join(appDir.path, 'downloads'));
    if (!await downloadsDir.exists()) {
      await downloadsDir.create(recursive: true);
    }

    final songDir = Directory(p.join(downloadsDir.path, song.id));
    if (!await songDir.exists()) {
      await songDir.create(recursive: true);
    }

    // Download audio
    final audioFile = File(
      p.join(songDir.path, 'audio${p.extension(song.audioFile)}'),
    );
    final audioResp = await http.get(Uri.parse(song.audioFile));
    await audioFile.writeAsBytes(audioResp.bodyBytes);

    // Download image
    final imageFile = File(
      p.join(songDir.path, 'image${p.extension(song.songImage)}'),
    );
    final imageResp = await http.get(Uri.parse(song.songImage));
    await imageFile.writeAsBytes(imageResp.bodyBytes);

    final downloadedSong = song.copyWith(
      audioFile: audioFile.path,
      songImage: imageFile.path,
      isDownloaded: true,
    );

    await localDataSource.saveDownloadedSong(downloadedSong);
  }

  @override
  Future<void> deleteDownloadedSong(String id) async {
    final appDir = await getApplicationDocumentsDirectory();
    final songDir = Directory(p.join(appDir.path, 'downloads', id));
    if (await songDir.exists()) {
      await songDir.delete(recursive: true);
    }
    await localDataSource.deleteDownloadedSong(id);
  }

  @override
  Future<void> clearLocalCache() async {
    await localDataSource.clearCache();
  }
}
