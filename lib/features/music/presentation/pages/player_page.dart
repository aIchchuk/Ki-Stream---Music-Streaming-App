import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/song_model.dart';
import '../../../shared/widgets/song_image.dart';
import '../bloc/player_bloc.dart';
import '../bloc/song_bloc.dart';
import '../bloc/downloads_bloc.dart';
import '../bloc/playlist_bloc/playlist_bloc.dart';
import '../../../../core/widgets/dynamic_background.dart';

class PlayerPage extends StatelessWidget {
  final SongModel song;
  const PlayerPage({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isShortScreen = screenHeight < 700;
    final Color purpleAccent = const Color(0xFF8B80F9);

    return DynamicBackground(
      child: BlocListener<PlayerBloc, PlayerState>(
        listener: (context, state) {
          if (state is PlayerError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<PlayerBloc, PlayerState>(
          builder: (context, state) {
            final currentSong = (state is PlayerPlaying) ? state.song : song;
            final isPlaying = (state is PlayerPlaying)
                ? state.isPlaying
                : false;

            return Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                toolbarHeight: isShortScreen ? 40 : 56,
                leading: IconButton(
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    size: 28,
                    color: Colors.white,
                  ),
                  onPressed: () => context.pop(),
                ),
                title: const Text(
                  "NOW PLAYING",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                centerTitle: true,
              ),
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Album Art
                      Hero(
                        tag: 'song_art_${currentSong.id}',
                        child: Center(
                          child: Container(
                            height:
                                MediaQuery.of(context).size.width *
                                (isShortScreen ? 0.45 : 0.55),
                            width:
                                MediaQuery.of(context).size.width *
                                (isShortScreen ? 0.45 : 0.55),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: purpleAccent.withValues(alpha: 0.2),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                              image: DecorationImage(
                                image: SongImage.getImageProvider(
                                  currentSong.songImage,
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Song Info
                      Column(
                        children: [
                          Text(
                            currentSong.songName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currentSong.artistName,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),

                      // Action Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildActionIcon(
                            icon: (currentSong.isFavorite ?? false)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            label: "Like",
                            color: purpleAccent,
                            onTap: () {
                              // Instant UI feedback via PlayerBloc
                              context.read<PlayerBloc>().add(
                                UpdateFavoriteStatus(
                                  currentSong.id,
                                  !(currentSong.isFavorite ?? false),
                                ),
                              );
                              // Persist to Hive via SongBloc
                              context.read<SongBloc>().add(
                                ToggleFavorite(currentSong),
                              );
                            },
                          ),
                          _buildActionIcon(
                            icon: Icons.add,
                            label: "Add to",
                            color: purpleAccent,
                            onTap: () => _showAddToPlaylistBottomSheet(
                              context,
                              currentSong,
                            ),
                          ),
                          _buildActionIcon(
                            icon: Icons.more_horiz,
                            label: "More",
                            color: purpleAccent,
                            onTap: () {},
                          ),
                        ],
                      ),

                      // Progress Bar using StreamBuilder (Reference logic)
                      StreamBuilder<Duration>(
                        stream: context.read<PlayerBloc>().positionStream,
                        builder: (context, positionSnapshot) {
                          final position =
                              positionSnapshot.data ?? Duration.zero;
                          return StreamBuilder<Duration?>(
                            stream: context.read<PlayerBloc>().durationStream,
                            builder: (context, durationSnapshot) {
                              final duration =
                                  durationSnapshot.data ?? Duration.zero;
                              final sliderValue = (duration.inMilliseconds > 0)
                                  ? position.inMilliseconds.toDouble()
                                  : 0.0;
                              final maxSlider = (duration.inMilliseconds > 0)
                                  ? duration.inMilliseconds.toDouble()
                                  : 1.0;

                              return Column(
                                children: [
                                  SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      trackHeight: 2,
                                      thumbShape: const RoundSliderThumbShape(
                                        enabledThumbRadius: 4,
                                      ),
                                      overlayShape:
                                          const RoundSliderOverlayShape(
                                            overlayRadius: 10,
                                          ),
                                      activeTrackColor: purpleAccent,
                                      inactiveTrackColor: Colors.white24,
                                      thumbColor: purpleAccent,
                                    ),
                                    child: Slider(
                                      value: sliderValue.clamp(0.0, maxSlider),
                                      max: maxSlider,
                                      onChanged: (val) {
                                        context.read<PlayerBloc>().add(
                                          Seek(
                                            Duration(milliseconds: val.toInt()),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _formatDuration(position),
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 11,
                                          ),
                                        ),
                                        Text(
                                          _formatDuration(duration),
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),

                      // Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Icon(
                            Icons.shuffle,
                            color: Color(0xFF8B80F9),
                            size: 22,
                          ),
                          IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.skip_previous,
                                color: Color(0xFF8B80F9),
                                size: 28,
                              ),
                            ),
                            onPressed: () =>
                                context.read<PlayerBloc>().add(PlayPrevious()),
                          ),
                          GestureDetector(
                            onTap: () =>
                                context.read<PlayerBloc>().add(TogglePlay()),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(35),
                              child: BackdropFilter(
                                filter: ui.ImageFilter.blur(
                                  sigmaX: 10,
                                  sigmaY: 10,
                                ),
                                child: Container(
                                  height: 70,
                                  width: 70,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        const Color(
                                          0xFF8B80F9,
                                        ).withValues(alpha: 0.9),
                                        const Color(
                                          0xFF6B60D9,
                                        ).withValues(alpha: 0.7),
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.25,
                                      ),
                                      width: 1.2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF8B80F9,
                                        ).withValues(alpha: 0.4),
                                        blurRadius: 20,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    isPlaying
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.skip_next,
                                color: Color(0xFF8B80F9),
                                size: 28,
                              ),
                            ),
                            onPressed: () =>
                                context.read<PlayerBloc>().add(PlayNext()),
                          ),
                          // Download Icon
                          BlocBuilder<DownloadsBloc, DownloadsState>(
                            builder: (context, downloadsState) {
                              bool isDownloaded = false;
                              if (downloadsState is DownloadsLoaded) {
                                isDownloaded = downloadsState.songs.any(
                                  (s) => s.id == currentSong.id,
                                );
                              }

                              return IconButton(
                                icon: Icon(
                                  isDownloaded
                                      ? Icons.check_circle
                                      : Icons.download_for_offline_outlined,
                                  color: isDownloaded
                                      ? const Color(0xFF8B80F9)
                                      : Colors.grey,
                                  size: 26,
                                ),
                                onPressed: () {
                                  if (isDownloaded) {
                                    context.read<DownloadsBloc>().add(
                                      DeleteDownloadedSong(currentSong.id),
                                    );
                                  } else {
                                    context.read<DownloadsBloc>().add(
                                      DownloadSong(currentSong),
                                    );
                                  }
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionIcon({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  void _showAddToPlaylistBottomSheet(BuildContext context, SongModel song) {
    context.read<PlaylistBloc>().add(LoadPlaylists());

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.8),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Add to Playlist",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: BlocBuilder<PlaylistBloc, PlaylistState>(
                      builder: (context, state) {
                        if (state is PlaylistLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (state is PlaylistLoaded) {
                          if (state.playlists.isEmpty) {
                            return const Center(
                              child: Text(
                                "No playlists found",
                                style: TextStyle(color: Colors.grey),
                              ),
                            );
                          }
                          return ListView.builder(
                            itemCount: state.playlists.length,
                            itemBuilder: (context, index) {
                              final playlist = state.playlists[index];
                              final isAlreadyIn = playlist.songIds.contains(
                                song.id,
                              );

                              return ListTile(
                                leading: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.white10,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.playlist_play,
                                    color: Color(0xFF8B80F9),
                                  ),
                                ),
                                title: Text(
                                  playlist.name,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  "${playlist.songIds.length} songs",
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                trailing: Icon(
                                  isAlreadyIn
                                      ? Icons.check_circle
                                      : Icons.add_circle_outline,
                                  color: isAlreadyIn
                                      ? const Color(0xFF8B80F9)
                                      : Colors.white24,
                                ),
                                onTap: isAlreadyIn
                                    ? null
                                    : () {
                                        context.read<PlaylistBloc>().add(
                                          AddSongToPlaylist(
                                            playlistId: playlist.id,
                                            songId: song.id,
                                          ),
                                        );
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Added to ${playlist.name}",
                                            ),
                                            backgroundColor: const Color(
                                              0xFF8B80F9,
                                            ),
                                          ),
                                        );
                                      },
                              );
                            },
                          );
                        } else if (state is PlaylistError) {
                          return Center(
                            child: Text(
                              state.message,
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
