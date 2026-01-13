import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/network/server_health_data_source.dart';
import '../../../music/presentation/bloc/song_bloc.dart';
import '../../../music/presentation/bloc/player_bloc.dart';
import '../../../music/presentation/bloc/downloads_bloc.dart';
import '../../../music/data/models/song_model.dart';
import '../../../shared/widgets/song_list_tile.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  bool isServerOnline = true;

  @override
  void initState() {
    super.initState();
    _checkServerStatus();
    context.read<SongBloc>().add(LoadSongs());
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
      backgroundColor: Colors.transparent,
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
                    onTap: () => context.push('/downloads'),
                  ),
                  _buildQuickAction(
                    icon: Icons.playlist_play_rounded,
                    label: isServerOnline ? "Playlists" : "Playlists",
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
                child: !isServerOnline
                    ? const Center(
                        child: Text(
                          "You are offline",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : BlocBuilder<DownloadsBloc, DownloadsState>(
                        builder: (context, downloadsState) {
                          return BlocBuilder<SongBloc, SongState>(
                            builder: (context, state) {
                              if (state is SongLoading) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else if (state is SongLoaded) {
                                List<SongModel> manualSongs = state.songs
                                    .where((s) => s.isManual == true)
                                    .toList();

                                if (isServerOnline &&
                                    downloadsState is DownloadsLoaded) {
                                  final loadedSongs = downloadsState.songs;
                                  // Filter out songs that are already downloaded when online
                                  manualSongs = manualSongs.where((song) {
                                    return !loadedSongs.any(
                                      (s) => s.id == song.id,
                                    );
                                  }).toList();
                                }

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
                                    return SongListTile(
                                      song: song,
                                      queue: manualSongs,
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
                          );
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: (MediaQuery.of(context).size.width - 60) / 3.2,
            height: 95,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1A1A2E).withValues(alpha: 0.6),
                  const Color(0xFF121221).withValues(alpha: 0.4),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B80F9).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: const Color(0xFF9E8CF4), size: 28),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
