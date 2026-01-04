import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/song_repository.dart';
import '../../data/models/song_model.dart';

// Events
abstract class DownloadsEvent {}

class LoadDownloadedSongs extends DownloadsEvent {}

class DownloadSong extends DownloadsEvent {
  final SongModel song;
  DownloadSong(this.song);
}

class DeleteDownloadedSong extends DownloadsEvent {
  final String id;
  DeleteDownloadedSong(this.id);
}

class DownloadPlaylist extends DownloadsEvent {
  final List<SongModel> songs;
  DownloadPlaylist(this.songs);
}

class DeletePlaylistDownload extends DownloadsEvent {
  final List<String> songIds;
  DeletePlaylistDownload(this.songIds);
}

// States
abstract class DownloadsState {}

class DownloadsInitial extends DownloadsState {}

class DownloadsLoading extends DownloadsState {}

class DownloadsLoaded extends DownloadsState {
  final List<SongModel> songs;
  DownloadsLoaded(this.songs);
}

class DownloadsError extends DownloadsState {
  final String message;
  DownloadsError(this.message);
}

// Bloc
class DownloadsBloc extends Bloc<DownloadsEvent, DownloadsState> {
  final SongRepository _songRepository;

  DownloadsBloc(this._songRepository) : super(DownloadsInitial()) {
    on<LoadDownloadedSongs>((event, emit) async {
      emit(DownloadsLoading());
      try {
        final songs = await _songRepository.getDownloadedSongs();
        emit(DownloadsLoaded(songs));
      } catch (e) {
        emit(DownloadsError(e.toString()));
      }
    });

    on<DownloadSong>((event, emit) async {
      try {
        await _songRepository.downloadSong(event.song);
        add(LoadDownloadedSongs());
      } catch (e) {
        // We might not want to emit Error here as it might disrupt the whole page
        // but for now let's do it.
        emit(DownloadsError(e.toString()));
      }
    });

    on<DeleteDownloadedSong>((event, emit) async {
      try {
        await _songRepository.deleteDownloadedSong(event.id);
        add(LoadDownloadedSongs());
      } catch (e) {
        emit(DownloadsError(e.toString()));
      }
    });

    on<DownloadPlaylist>((event, emit) async {
      int successCount = 0;
      int failCount = 0;

      for (final song in event.songs) {
        try {
          await _songRepository.downloadSong(song);
          successCount++;
          // Reload downloads after each successful download for progress feedback
          add(LoadDownloadedSongs());
        } catch (e) {
          failCount++;
          // Continue with next song even if this one fails
          print('Failed to download ${song.songName}: $e');
        }
      }

      // Final reload to ensure all downloads are shown
      add(LoadDownloadedSongs());

      // Only emit error if ALL songs failed
      if (failCount > 0 && successCount == 0) {
        emit(
          DownloadsError(
            'Failed to download playlist. Please check your connection.',
          ),
        );
      }
    });

    on<DeletePlaylistDownload>((event, emit) async {
      try {
        for (final songId in event.songIds) {
          await _songRepository.deleteDownloadedSong(songId);
        }
        add(LoadDownloadedSongs());
      } catch (e) {
        emit(DownloadsError(e.toString()));
      }
    });
  }
}
