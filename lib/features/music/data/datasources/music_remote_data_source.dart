import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../models/song_model.dart';
import '../models/playlist_model.dart';

abstract class MusicRemoteDataSource {
  Future<List<SongModel>> getAllSongs();
  Future<SongModel> createSong(SongModel song);
  Future<void> deleteSong(String id);
  Future<SongModel> updateSong(SongModel song);

  Future<List<PlaylistModel>> getAllPlaylists();
  Future<PlaylistModel> createPlaylist(PlaylistModel playlist);
  Future<PlaylistModel> updatePlaylist(PlaylistModel playlist);
  Future<void> deletePlaylist(String id);
}

class MusicRemoteDataSourceImpl implements MusicRemoteDataSource {
  final http.Client client;
  final String baseUrl = ApiConstants.baseUrl;
  final String baseStaticUrl = ApiConstants.baseStaticUrl;

  MusicRemoteDataSourceImpl({required this.client});

  String _resolveAssetUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;

    // Ensure we don't end up with double slashes or no slash
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return '$baseStaticUrl/$cleanPath';
  }

  @override
  Future<List<SongModel>> getAllSongs() async {
    final response = await client.get(Uri.parse('$baseUrl/songs'));

    if (response.statusCode == 200) {
      final List decoded = json.decode(response.body);
      return decoded.map((item) {
        final song = SongModel.fromJson(item);
        return song.copyWith(
          songImage: _resolveAssetUrl(song.songImage),
          audioFile: _resolveAssetUrl(song.audioFile),
        );
      }).toList();
    } else {
      throw Exception('Failed to load songs');
    }
  }

  @override
  Future<SongModel> createSong(SongModel song) async {
    final uri = Uri.parse('$baseUrl/songs');
    final request = http.MultipartRequest('POST', uri);

    request.fields['songName'] = song.songName;
    request.fields['artistName'] = song.artistName;
    request.fields['albumName'] = song.albumName ?? '';
    request.fields['isManual'] = (song.isManual ?? false).toString();
    request.fields['isFavorite'] = (song.isFavorite ?? false).toString();

    // Handle song image
    if (song.songImage.isNotEmpty && !song.songImage.startsWith('http')) {
      final file = File(song.songImage);
      if (await file.exists()) {
        request.files.add(
          await http.MultipartFile.fromPath('songImage', file.path),
        );
      } else {
        request.fields['songImage'] = song.songImage;
      }
    } else {
      request.fields['songImage'] = song.songImage;
    }

    // Handle audio file
    if (song.audioFile.isNotEmpty && !song.audioFile.startsWith('http')) {
      final file = File(song.audioFile);
      if (await file.exists()) {
        request.files.add(
          await http.MultipartFile.fromPath('audioFile', file.path),
        );
      } else {
        request.fields['audioFile'] = song.audioFile;
      }
    } else {
      request.fields['audioFile'] = song.audioFile;
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201 || response.statusCode == 200) {
      final song = SongModel.fromJson(json.decode(response.body));
      return song.copyWith(
        songImage: _resolveAssetUrl(song.songImage),
        audioFile: _resolveAssetUrl(song.audioFile),
      );
    } else {
      throw Exception('Failed to create song: ${response.body}');
    }
  }

  @override
  Future<SongModel> updateSong(SongModel song) async {
    final uri = Uri.parse('$baseUrl/songs/${song.id}');
    final request = http.MultipartRequest('PUT', uri);

    request.fields['songName'] = song.songName;
    request.fields['artistName'] = song.artistName;
    request.fields['albumName'] = song.albumName ?? '';
    request.fields['isManual'] = (song.isManual ?? false).toString();
    request.fields['isFavorite'] = (song.isFavorite ?? false).toString();

    // Handle song image
    if (song.songImage.isNotEmpty && !song.songImage.startsWith('http')) {
      final file = File(song.songImage);
      if (await file.exists()) {
        request.files.add(
          await http.MultipartFile.fromPath('songImage', file.path),
        );
      } else {
        request.fields['songImage'] = song.songImage;
      }
    } else {
      request.fields['songImage'] = song.songImage;
    }

    // Handle audio file
    if (song.audioFile.isNotEmpty && !song.audioFile.startsWith('http')) {
      final file = File(song.audioFile);
      if (await file.exists()) {
        request.files.add(
          await http.MultipartFile.fromPath('audioFile', file.path),
        );
      } else {
        request.fields['audioFile'] = song.audioFile;
      }
    } else {
      request.fields['audioFile'] = song.audioFile;
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final song = SongModel.fromJson(json.decode(response.body));
      return song.copyWith(
        songImage: _resolveAssetUrl(song.songImage),
        audioFile: _resolveAssetUrl(song.audioFile),
      );
    } else {
      throw Exception('Failed to update song: ${response.body}');
    }
  }

  @override
  Future<void> deleteSong(String id) async {
    final response = await client.delete(Uri.parse('$baseUrl/songs/$id'));

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete song');
    }
  }

  @override
  Future<List<PlaylistModel>> getAllPlaylists() async {
    final response = await client.get(Uri.parse('$baseUrl/playlists'));

    if (response.statusCode == 200) {
      final List decoded = json.decode(response.body);
      return decoded.map((item) {
        final playlist = PlaylistModel.fromJson(item);
        return playlist.copyWith(
          imagePath: _resolveAssetUrl(playlist.imagePath),
        );
      }).toList();
    } else {
      throw Exception('Failed to load playlists');
    }
  }

  @override
  Future<PlaylistModel> createPlaylist(PlaylistModel playlist) async {
    final uri = Uri.parse('$baseUrl/playlists');
    final request = http.MultipartRequest('POST', uri);

    // Add fields
    request.fields['name'] = playlist.name;
    request.fields['mood'] = playlist.mood;
    request.fields['creatorId'] = playlist.creatorId ?? '';
    request.fields['creatorName'] = playlist.creatorName ?? '';
    request.fields['songIds'] = json.encode(playlist.songIds);
    request.fields['dateCreated'] = playlist.dateCreated.toIso8601String();

    // Add image file if it exists locally
    if (playlist.imagePath != null &&
        playlist.imagePath!.isNotEmpty &&
        !playlist.imagePath!.startsWith('http')) {
      final file = File(playlist.imagePath!);
      if (await file.exists()) {
        request.files.add(
          await http.MultipartFile.fromPath('imagePath', file.path),
        );
      } else {
        request.fields['imagePath'] = playlist.imagePath!;
      }
    } else if (playlist.imagePath != null) {
      request.fields['imagePath'] = playlist.imagePath!;
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201 || response.statusCode == 200) {
      final playlist = PlaylistModel.fromJson(json.decode(response.body));
      return playlist.copyWith(imagePath: _resolveAssetUrl(playlist.imagePath));
    } else {
      throw Exception('Failed to create playlist: ${response.body}');
    }
  }

  @override
  Future<PlaylistModel> updatePlaylist(PlaylistModel playlist) async {
    final uri = Uri.parse('$baseUrl/playlists/${playlist.id}');
    final request = http.MultipartRequest('PUT', uri);

    request.fields['name'] = playlist.name;
    request.fields['mood'] = playlist.mood;
    request.fields['songIds'] = json.encode(playlist.songIds);
    if (playlist.creatorId != null)
      request.fields['creatorId'] = playlist.creatorId!;
    if (playlist.creatorName != null)
      request.fields['creatorName'] = playlist.creatorName!;

    if (playlist.imagePath != null &&
        playlist.imagePath!.isNotEmpty &&
        !playlist.imagePath!.startsWith('http')) {
      final file = File(playlist.imagePath!);
      if (await file.exists()) {
        request.files.add(
          await http.MultipartFile.fromPath('imagePath', file.path),
        );
      } else {
        request.fields['imagePath'] = playlist.imagePath!;
      }
    } else if (playlist.imagePath != null) {
      request.fields['imagePath'] = playlist.imagePath!;
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final playlist = PlaylistModel.fromJson(json.decode(response.body));
      return playlist.copyWith(imagePath: _resolveAssetUrl(playlist.imagePath));
    } else {
      throw Exception('Failed to update playlist: ${response.body}');
    }
  }

  @override
  Future<void> deletePlaylist(String id) async {
    final response = await client.delete(Uri.parse('$baseUrl/playlists/$id'));

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete playlist');
    }
  }
}
