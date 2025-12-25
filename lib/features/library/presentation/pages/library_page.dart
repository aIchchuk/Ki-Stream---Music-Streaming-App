import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../music/presentation/bloc/song_bloc.dart';
import '../../../music/presentation/bloc/player_bloc.dart';
import '../../../shared/widgets/song_image.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  @override
  void initState() {
    super.initState();
    context.read<SongBloc>().add(LoadSongs());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Your Library",
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              // Quick Actions Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildQuickAction(
                    icon: Icons.file_download_outlined,
                    label: "Downloads",
                  ),
                  _buildQuickAction(
                    icon: Icons.playlist_play_rounded,
                    label: "Playlists",
                    onTap: () => context.push('/playlists'),
                  ),
                  _buildQuickAction(
                    icon: Icons.favorite_border_rounded,
                    label: "Favorites",
                    onTap: () => context.push('/favorites'),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              const Text(
                "Recently Added Songs",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 25),

              // Recently Added List - Scrollable
              Expanded(
                child: BlocBuilder<SongBloc, SongState>(
                  builder: (context, state) {
                    if (state is SongLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is SongLoaded) {
                      final manualSongs = state.songs
                          .where((s) => s.isManual == true)
                          .toList();

                      if (manualSongs.isEmpty) {
                        return const Center(
                          child: Text(
                            "No manual songs added yet.",
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: manualSongs.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final song = manualSongs[index];
                          return _buildRecentlyStreamedItem(
                            image: song.songImage,
                            title: song.songName,
                            artist: song.artistName,
                            onTap: () {
                              context.read<PlayerBloc>().add(
                                PlaySong(song, queue: manualSongs),
                              );
                              context.push('/player', extra: song);
                            },
                          );
                        },
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
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: (MediaQuery.of(context).size.width - 60) / 3.2,
        height: 90,
        decoration: BoxDecoration(
          color: const Color(0xFF121221),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF9E8CF4), size: 30),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentlyStreamedItem({
    required String image,
    required String title,
    required String artist,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 25),
        child: Row(
          children: [
            SongImage(imageUrl: image, width: 90, height: 90, borderRadius: 12),
            const SizedBox(width: 25),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    artist,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
