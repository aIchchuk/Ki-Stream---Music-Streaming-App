import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:just_audio/just_audio.dart';
import '../../data/models/song_model.dart';

// Events
abstract class PlayerEvent extends Equatable {
  const PlayerEvent();

  @override
  List<Object?> get props => [];
}

class PlaySong extends PlayerEvent {
  final SongModel song;
  final List<SongModel>? queue;
  const PlaySong(this.song, {this.queue});

  @override
  List<Object?> get props => [song, queue];
}

class TogglePlay extends PlayerEvent {}

class PlayNext extends PlayerEvent {}

class PlayPrevious extends PlayerEvent {}

class SetQueue extends PlayerEvent {
  final List<SongModel> queue;
  const SetQueue(this.queue);

  @override
  List<Object?> get props => [queue];
}

class Seek extends PlayerEvent {
  final Duration position;
  const Seek(this.position);

  @override
  List<Object?> get props => [position];
}

class _UpdatePlayingStatus extends PlayerEvent {
  final bool isPlaying;
  const _UpdatePlayingStatus(this.isPlaying);

  @override
  List<Object?> get props => [isPlaying];
}

class UpdateFavoriteStatus extends PlayerEvent {
  final String songId;
  final bool isFavorite;
  const UpdateFavoriteStatus(this.songId, this.isFavorite);

  @override
  List<Object?> get props => [songId, isFavorite];
}

// States
abstract class PlayerState extends Equatable {
  const PlayerState();

  @override
  List<Object?> get props => [];
}

class PlayerInitial extends PlayerState {}

class PlayerPlaying extends PlayerState {
  final SongModel song;
  final bool isPlaying;

  const PlayerPlaying(this.song, {this.isPlaying = true});

  @override
  List<Object?> get props => [song, isPlaying];
}

class PlayerError extends PlayerState {
  final String message;
  const PlayerError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<SongModel> _queue = [];

  PlayerBloc() : super(PlayerInitial()) {
    on<PlaySong>(_onPlaySong);
    on<TogglePlay>(_onTogglePlay);
    on<Seek>(_onSeek);
    on<PlayNext>(_onPlayNext);
    on<PlayPrevious>(_onPlayPrevious);
    on<SetQueue>(_onSetQueue);
    on<_UpdatePlayingStatus>(_onUpdatePlayingStatus);
    on<UpdateFavoriteStatus>(_onUpdateFavoriteStatus);

    // Listen to player status changes to keep Bloc in sync
    _audioPlayer.playingStream.listen((isPlaying) {
      add(_UpdatePlayingStatus(isPlaying));
    });

    // Handle song completion for auto-play
    _audioPlayer.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        add(PlayNext());
      }
    });
  }

  // Stream accessors for the UI
  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<Duration> get bufferedPositionStream =>
      _audioPlayer.bufferedPositionStream;
  Stream<bool> get playingStream => _audioPlayer.playingStream;

  Future<void> _onPlaySong(PlaySong event, Emitter<PlayerState> emit) async {
    try {
      if (event.queue != null) {
        _queue = event.queue!;
      }

      if (event.song.audioFile.startsWith('http')) {
        await _audioPlayer.setUrl(event.song.audioFile);
      } else {
        if (File(event.song.audioFile).existsSync()) {
          await _audioPlayer.setFilePath(event.song.audioFile);
        } else {
          emit(const PlayerError("Audio file not found"));
          return;
        }
      }
      _audioPlayer.play();
      emit(PlayerPlaying(event.song, isPlaying: true));
    } catch (e) {
      emit(PlayerError(e.toString()));
    }
  }

  void _onSetQueue(SetQueue event, Emitter<PlayerState> emit) {
    _queue = event.queue;
  }

  Future<void> _onPlayNext(PlayNext event, Emitter<PlayerState> emit) async {
    if (state is PlayerPlaying && _queue.isNotEmpty) {
      final currentSong = (state as PlayerPlaying).song;
      final currentIndex = _queue.indexWhere((s) => s.id == currentSong.id);

      if (currentIndex != -1 && currentIndex < _queue.length - 1) {
        add(PlaySong(_queue[currentIndex + 1]));
      } else if (currentIndex == _queue.length - 1) {
        // Loop back to start
        add(PlaySong(_queue[0]));
      }
    }
  }

  Future<void> _onPlayPrevious(
    PlayPrevious event,
    Emitter<PlayerState> emit,
  ) async {
    if (state is PlayerPlaying && _queue.isNotEmpty) {
      final currentSong = (state as PlayerPlaying).song;
      final currentIndex = _queue.indexWhere((s) => s.id == currentSong.id);

      if (currentIndex > 0) {
        add(PlaySong(_queue[currentIndex - 1]));
      } else if (currentIndex == 0) {
        // Loop back to end
        add(PlaySong(_queue.last));
      }
    }
  }

  Future<void> _onTogglePlay(
    TogglePlay event,
    Emitter<PlayerState> emit,
  ) async {
    if (_audioPlayer.playing) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  void _onUpdatePlayingStatus(
    _UpdatePlayingStatus event,
    Emitter<PlayerState> emit,
  ) {
    if (state is PlayerPlaying) {
      final currentState = state as PlayerPlaying;
      emit(PlayerPlaying(currentState.song, isPlaying: event.isPlaying));
    }
  }

  void _onUpdateFavoriteStatus(
    UpdateFavoriteStatus event,
    Emitter<PlayerState> emit,
  ) {
    if (state is PlayerPlaying) {
      final currentState = state as PlayerPlaying;
      if (currentState.song.id == event.songId) {
        final updatedSong = currentState.song.copyWith(
          isFavorite: event.isFavorite,
        );
        emit(PlayerPlaying(updatedSong, isPlaying: currentState.isPlaying));

        // Update in queue
        final index = _queue.indexWhere((s) => s.id == event.songId);
        if (index != -1) {
          _queue[index] = updatedSong;
        }
      }
    }
  }

  Future<void> _onSeek(Seek event, Emitter<PlayerState> emit) async {
    await _audioPlayer.seek(event.position);
  }

  @override
  Future<void> close() {
    _audioPlayer.dispose();
    return super.close();
  }
}
