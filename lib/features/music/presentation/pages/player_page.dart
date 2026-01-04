import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/song_model.dart';
import '../../../shared/widgets/song_image.dart';
import '../bloc/player_bloc.dart';
import '../bloc/song_bloc.dart';
import '../bloc/downloads_bloc.dart';

class PlayerPage extends StatelessWidget {
  final SongModel song;
  const PlayerPage({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isShortScreen = screenHeight < 700;
    final Color purpleAccent = const Color(0xFF8B80F9);

    return BlocListener<PlayerBloc, PlayerState>(
      listener: (context, state) {
        if (state is PlayerError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: BlocBuilder<PlayerBloc, PlayerState>(
        builder: (context, state) {
          final currentSong = (state is PlayerPlaying) ? state.song : song;
          final isPlaying = (state is PlayerPlaying) ? state.isPlaying : false;

          return Scaffold(
            backgroundColor: Colors.black,
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
                          onTap: () {},
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
                        final position = positionSnapshot.data ?? Duration.zero;
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
                                    overlayShape: const RoundSliderOverlayShape(
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
                          icon: const Icon(
                            Icons.skip_previous,
                            color: Color(0xFF8B80F9),
                            size: 32,
                          ),
                          onPressed: () =>
                              context.read<PlayerBloc>().add(PlayPrevious()),
                        ),
                        GestureDetector(
                          onTap: () =>
                              context.read<PlayerBloc>().add(TogglePlay()),
                          child: Container(
                            height: 60,
                            width: 60,
                            decoration: const BoxDecoration(
                              color: Color(0xFF8B80F9),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.black,
                              size: 34,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.skip_next,
                            color: Color(0xFF8B80F9),
                            size: 32,
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
}
