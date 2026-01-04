import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../shared/widgets/song_image.dart';
import '../../../shared/widgets/song_list_tile.dart';
import '../bloc/player_bloc.dart';
import '../bloc/song_bloc.dart';
import '../bloc/downloads_bloc.dart';
import '../../data/models/song_model.dart';
import '../../data/models/playlist_model.dart';

class PlaylistDetailPage extends StatelessWidget {
  final PlaylistModel playlist;

  const PlaylistDetailPage({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    // Generate color
    final color =
        Colors.primaries[playlist.mood.hashCode % Colors.primaries.length];

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: color,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                playlist.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: playlist.imagePath == null
                      ? LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [color, AppTheme.backgroundColor],
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
                ),
                child: playlist.imagePath == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.music_note_rounded,
                              size: 80,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              playlist.mood,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "- ${playlist.creatorName ?? 'Unknown'}",
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.5),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
          ),
          BlocBuilder<DownloadsBloc, DownloadsState>(
            builder: (context, downloadsState) {
              return BlocBuilder<SongBloc, SongState>(
                builder: (context, songState) {
                  final allSongs = songState is SongLoaded
                      ? songState.songs
                      : <SongModel>[];
                  final downloadedSongs = downloadsState is DownloadsLoaded
                      ? downloadsState.songs
                      : <SongModel>[];

                  // Resolve playlist songs: prefer downloaded versions (local paths)
                  final playlistSongs = playlist.songIds
                      .map((id) {
                        final downloaded = downloadedSongs
                            .where((s) => s.id == id)
                            .firstOrNull;
                        if (downloaded != null) return downloaded;
                        return allSongs.where((s) => s.id == id).firstOrNull;
                      })
                      .whereType<SongModel>()
                      .toList();

                  if (playlistSongs.isEmpty && songState is SongLoading) {
                    return const SliverToBoxAdapter(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (playlistSongs.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Center(
                          child: Text(
                            "No songs in this playlist.",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${playlistSongs.length} songs",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "By ${playlist.creatorName ?? 'Unknown'}",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          // Download Button for Playlist
                          IconButton(
                            onPressed: () {
                              final allSongsDownloaded = playlistSongs.every(
                                (song) =>
                                    downloadedSongs.any((s) => s.id == song.id),
                              );

                              if (allSongsDownloaded) {
                                context.read<DownloadsBloc>().add(
                                  DeletePlaylistDownload(
                                    playlistSongs.map((s) => s.id).toList(),
                                  ),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Playlist downloads removed'),
                                  ),
                                );
                              } else {
                                context.read<DownloadsBloc>().add(
                                  DownloadPlaylist(playlistSongs),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Downloading playlist...'),
                                  ),
                                );
                              }
                            },
                            icon: Builder(
                              builder: (context) {
                                final allSongsDownloaded = playlistSongs.every(
                                  (song) => downloadedSongs.any(
                                    (s) => s.id == song.id,
                                  ),
                                );
                                return Icon(
                                  allSongsDownloaded
                                      ? Icons.download_done
                                      : Icons.download_for_offline,
                                  color: allSongsDownloaded
                                      ? AppTheme.primaryColor
                                      : Colors.grey,
                                  size: 28,
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Shuffle Button
                          IconButton(
                            onPressed: () {
                              final shuffledSongs = List<SongModel>.from(
                                playlistSongs,
                              )..shuffle();
                              if (shuffledSongs.isNotEmpty) {
                                context.read<PlayerBloc>().add(
                                  PlaySong(
                                    shuffledSongs.first,
                                    queue: shuffledSongs,
                                  ),
                                );
                                context.push(
                                  '/player',
                                  extra: shuffledSongs.first,
                                );
                              }
                            },
                            icon: const Icon(
                              Icons.shuffle,
                              color: Colors.grey,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Main Play Button
                          BlocBuilder<PlayerBloc, PlayerState>(
                            builder: (context, playerState) {
                              bool isPlaylistPlaying = false;
                              if (playerState is PlayerPlaying) {
                                final currentSongId = playerState.song.id;
                                isPlaylistPlaying =
                                    playlist.songIds.contains(currentSongId) &&
                                    playerState.isPlaying;
                              }

                              return GestureDetector(
                                onTap: () {
                                  if (isPlaylistPlaying) {
                                    context.read<PlayerBloc>().add(
                                      TogglePlay(),
                                    );
                                  } else {
                                    if (playlistSongs.isNotEmpty) {
                                      context.read<PlayerBloc>().add(
                                        PlaySong(
                                          playlistSongs.first,
                                          queue: playlistSongs,
                                        ),
                                      );
                                    }
                                  }
                                },
                                child: Container(
                                  width: 56,
                                  height: 56,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isPlaylistPlaying
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 38,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          BlocBuilder<DownloadsBloc, DownloadsState>(
            builder: (context, downloadsState) {
              return BlocBuilder<SongBloc, SongState>(
                builder: (context, songState) {
                  final allSongs = songState is SongLoaded
                      ? songState.songs
                      : <SongModel>[];
                  final downloadedSongs = downloadsState is DownloadsLoaded
                      ? downloadsState.songs
                      : <SongModel>[];

                  final playlistSongs = playlist.songIds
                      .map((id) {
                        final downloaded = downloadedSongs
                            .where((s) => s.id == id)
                            .firstOrNull;
                        if (downloaded != null) return downloaded;
                        return allSongs.where((s) => s.id == id).firstOrNull;
                      })
                      .whereType<SongModel>()
                      .toList();

                  if (playlistSongs.isEmpty) {
                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final song = playlistSongs[index];
                      return SongListTile(
                        song: song,
                        queue: playlistSongs,
                        onTap: () {
                          context.read<PlayerBloc>().add(
                            PlaySong(song, queue: playlistSongs),
                          );
                          context.push('/player', extra: song);
                        },
                      );
                    }, childCount: playlistSongs.length),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
