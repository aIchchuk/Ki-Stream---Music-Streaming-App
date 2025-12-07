import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/song_repository.dart';
import '../../data/models/song_model.dart';

// Events
abstract class SongEvent {}

class LoadSongs extends SongEvent {}

class AddSong extends SongEvent {
  final SongModel song;
  AddSong(this.song);
}

// States
abstract class SongState {}

class SongInitial extends SongState {}

class SongLoading extends SongState {}

class SongLoaded extends SongState {
  final List<SongModel> songs;
  SongLoaded(this.songs);
}

class SongError extends SongState {
  final String message;
  SongError(this.message);
}

// Bloc
class SongBloc extends Bloc<SongEvent, SongState> {
  final SongRepository _songRepository;

  SongBloc(this._songRepository) : super(SongInitial()) {
    on<LoadSongs>((event, emit) async {
      emit(SongLoading());
      try {
        final songs = await _songRepository.getSongs();
        emit(SongLoaded(songs));
      } catch (e) {
        emit(SongError(e.toString()));
      }
    });

    on<AddSong>((event, emit) async {
      try {
        await _songRepository.addSong(event.song);
        final songs = await _songRepository.getSongs();
        emit(SongLoaded(songs));
      } catch (e) {
        emit(SongError(e.toString()));
      }
    });
  }
}
