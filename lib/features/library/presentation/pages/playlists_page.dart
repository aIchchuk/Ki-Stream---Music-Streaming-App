import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:kistream/core/network/server_health_data_source.dart';
import 'package:kistream/features/music/presentation/bloc/downloads_bloc.dart';
import 'package:kistream/features/music/presentation/bloc/playlist_bloc/playlist_bloc.dart';
import 'package:kistream/features/music/data/models/playlist_model.dart';
import 'package:kistream/features/music/presentation/bloc/song_bloc.dart';
import 'package:kistream/features/music/presentation/bloc/player_bloc.dart';
import 'package:kistream/features/shared/widgets/playing_highlight.dart';
import 'package:kistream/features/shared/widgets/song_image.dart';
import 'package:kistream/core/theme/app_theme.dart';

class PlaylistsPage extends StatefulWidget {
  const PlaylistsPage({super.key});

  @override
  State<PlaylistsPage> createState() => _PlaylistsPageState();
}

class _PlaylistsPageState extends State<PlaylistsPage> {
  bool isServerOnline = true;

  @override
  void initState() {
    super.initState();
    _checkServerStatus();
  }

  Future<void> _checkServerStatus() async {
    final status = await GetIt.I<ServerHealthDataSource>().isServerRunning();
    if (mounted) {
      setState(() {
        isServerOnline = status;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          isServerOnline ? "Playlists" : "Downloaded Playlists",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (isServerOnline)
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white, size: 30),
              onPressed: () => context.push('/create-playlist'),
            ),
          const SizedBox(width: 10),
        ],
      ),
      body: BlocBuilder<DownloadsBloc, DownloadsState>(
        builder: (context, downloadsState) {
          return BlocBuilder<PlaylistBloc, PlaylistState>(
            builder: (context, state) {
              if (state is PlaylistLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is PlaylistLoaded) {
                List<PlaylistModel> playlists = state.playlists;

                if (downloadsState is DownloadsLoaded) {
                  final loadedSongs = downloadsState.songs;
                  playlists = playlists.where((playlist) {
                    if (isServerOnline) return true; // Show all when online

                    // When offline, only show if all songs are downloaded
                    if (playlist.songIds.isEmpty) return false;
                    return playlist.songIds.every(
                      (id) => loadedSongs.any((s) => s.id == id),
                    );
                  }).toList();
                }

                if (!isServerOnline && playlists.isEmpty) {
                  return const Center(
                    child: Text(
                      "No downloaded playlists found",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 24,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: isServerOnline
                      ? playlists.length + 1
                      : playlists.length,
                  itemBuilder: (context, index) {
                    if (isServerOnline && index == 0) {
                      return _buildCreatePlaylistCard(context);
                    }
                    final playlist =
                        playlists[isServerOnline ? index - 1 : index];
                    final color =
                        Colors.primaries[playlist.mood.hashCode %
                            Colors.primaries.length];
                    return _buildPlaylistCard(
                      context,
                      playlist.name,
                      playlist.songIds.length,
                      color,
                      playlist,
                    );
                  },
                );
              } else if (state is PlaylistError) {
                return Center(
                  child: Text(
                    "Error: ${state.message}",
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }

  Widget _buildCreatePlaylistCard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: InkWell(
              onTap: () => context.push('/create-playlist'),
              borderRadius: BorderRadius.circular(8),
              child: Center(
                child: Icon(
                  Icons.add,
                  color: Colors.white.withValues(alpha: 0.7),
                  size: 50,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "Create Playlist",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Add new collection",
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPlaylistCard(
    BuildContext context,
    String name,
    int count,
    Color color,
    PlaylistModel playlist,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: BlocBuilder<PlayerBloc, PlayerState>(
            builder: (context, playerState) {
              // Check if this playlist is currently playing
              bool isPlaylistPlaying = false;
              if (playerState is PlayerPlaying) {
                final currentSongId = playerState.song.id;
                isPlaylistPlaying =
                    playlist.songIds.contains(currentSongId) &&
                    playerState.isPlaying;
              }

              return PlayingHighlight(
                isActive: isPlaylistPlaying,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: playlist.imagePath == null
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              color.withValues(alpha: 0.8),
                              color.withValues(alpha: 0.4),
                            ],
                          )
                        : null,
                    image: playlist.imagePath != null
                        ? DecorationImage(
                            image: SongImage.getImageProvider(
                              playlist.imagePath!,
                            ),
                            fit: BoxFit.cover,
                          )
                        : null,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () {
                      context.push('/playlist-detail', extra: playlist);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      children: [
                        if (playlist.imagePath == null)
                          Center(
                            child: Icon(
                              Icons.music_note_rounded,
                              color: Colors.white.withValues(alpha: 0.5),
                              size: 60,
                            ),
                          ),
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: GestureDetector(
                            onTap: () {
                              if (isPlaylistPlaying) {
                                // Pause current playback
                                context.read<PlayerBloc>().add(TogglePlay());
                              } else {
                                // Play playlist
                                final songState = context
                                    .read<SongBloc>()
                                    .state;
                                if (songState is SongLoaded) {
                                  final playlistSongs = songState.songs
                                      .where(
                                        (s) => playlist.songIds.contains(s.id),
                                      )
                                      .toList();

                                  if (playlistSongs.isNotEmpty) {
                                    context.read<PlayerBloc>().add(
                                      PlaySong(
                                        playlistSongs.first,
                                        queue: playlistSongs,
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "No songs in this playlist",
                                        ),
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isPlaylistPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 4),
        Text(
          "By ${playlist.creatorName ?? 'Unknown'}",
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
