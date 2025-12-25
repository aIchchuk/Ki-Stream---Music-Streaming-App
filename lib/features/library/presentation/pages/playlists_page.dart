import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kistream/features/music/presentation/bloc/playlist_bloc/playlist_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import 'dart:io';
import '../../../../features/music/data/models/playlist_model.dart';
import '../../../../features/music/presentation/bloc/song_bloc.dart';
import '../../../../features/music/presentation/bloc/player_bloc.dart';

class PlaylistsPage extends StatelessWidget {
  const PlaylistsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Playlists",
          style: TextStyle(
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
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white, size: 30),
            onPressed: () => context.push('/create-playlist'),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: BlocBuilder<PlaylistBloc, PlaylistState>(
        builder: (context, state) {
          if (state is PlaylistLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PlaylistLoaded) {
            final playlists = state.playlists;

            return GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 24,
                childAspectRatio: 0.75,
              ),
              itemCount: playlists.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildCreatePlaylistCard(context);
                }
                final playlist = playlists[index - 1];
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
                      image: FileImage(File(playlist.imagePath!)),
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
                        // Play playlist
                        final songState = context.read<SongBloc>().state;
                        if (songState is SongLoaded) {
                          final playlistSongs = songState.songs
                              .where((s) => playlist.songIds.contains(s.id))
                              .toList();

                          if (playlistSongs.isNotEmpty) {
                            context.read<PlayerBloc>().add(
                              PlaySong(
                                playlistSongs.first,
                                queue: playlistSongs,
                              ),
                            );
                            context.push('/player', extra: playlistSongs.first);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("No songs in this playlist"),
                              ),
                            );
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
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
