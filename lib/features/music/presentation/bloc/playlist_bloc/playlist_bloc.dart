import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/playlist_repository.dart';
import '../../../data/models/playlist_model.dart';

// Events
abstract class PlaylistEvent {}

class LoadPlaylists extends PlaylistEvent {}

class CreatePlaylist extends PlaylistEvent {
  final PlaylistModel playlist;
  CreatePlaylist(this.playlist);
}

class DeletePlaylist extends PlaylistEvent {
  final String id;
  DeletePlaylist(this.id);
}

// States
abstract class PlaylistState {}

class PlaylistInitial extends PlaylistState {}

class PlaylistLoading extends PlaylistState {}

class PlaylistLoaded extends PlaylistState {
  final List<PlaylistModel> playlists;
  PlaylistLoaded(this.playlists);
}

class PlaylistError extends PlaylistState {
  final String message;
  PlaylistError(this.message);
}

// Bloc
class PlaylistBloc extends Bloc<PlaylistEvent, PlaylistState> {
  final PlaylistRepository _playlistRepository;

  PlaylistBloc(this._playlistRepository) : super(PlaylistInitial()) {
    on<LoadPlaylists>((event, emit) async {
      emit(PlaylistLoading());
      try {
        final playlists = await _playlistRepository.getPlaylists();
        emit(PlaylistLoaded(playlists));
      } catch (e) {
        emit(PlaylistError("Failed to load playlists: $e"));
      }
    });

    on<CreatePlaylist>((event, emit) async {
      try {
        await _playlistRepository.createPlaylist(event.playlist);
        add(LoadPlaylists());
      } catch (e) {
        emit(PlaylistError("Failed to create playlist: $e"));
      }
    });

    on<DeletePlaylist>((event, emit) async {
      try {
        await _playlistRepository.deletePlaylist(event.id);
        add(LoadPlaylists());
      } catch (e) {
        emit(PlaylistError("Failed to delete playlist: $e"));
      }
    });
  }
}
