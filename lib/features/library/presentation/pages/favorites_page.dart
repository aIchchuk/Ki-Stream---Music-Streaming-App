import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/network/server_health_data_source.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../music/presentation/bloc/song_bloc.dart';
import '../../../music/presentation/bloc/player_bloc.dart';
import '../../../shared/widgets/song_image.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
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
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          "Favorites",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
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
            : BlocBuilder<SongBloc, SongState>(
                builder: (context, state) {
                  if (state is SongLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is SongLoaded) {
                    final favoriteSongs = state.songs
                        .where((s) => s.isFavorite == true)
                        .toList();

                    if (favoriteSongs.isEmpty) {
                      return const Center(
                        child: Text(
                          "No favorite songs yet.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: favoriteSongs.length,
                      itemBuilder: (context, index) {
                        final song = favoriteSongs[index];
                        return GestureDetector(
                          onTap: () {
                            context.read<PlayerBloc>().add(
                              PlaySong(song, queue: favoriteSongs),
                            );
                            context.push('/player', extra: song);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 25),
                            child: Row(
                              children: [
                                SongImage(
                                  imageUrl: song.songImage,
                                  width: 70,
                                  height: 70,
                                  borderRadius: 12,
                                ),
                                const SizedBox(width: 25),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        song.songName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        song.artistName,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.favorite,
                                  color: AppTheme.primaryColor,
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
      ),
    );
  }
}
