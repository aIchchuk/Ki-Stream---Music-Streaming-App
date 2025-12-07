import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kistream/core/theme/app_theme.dart';
import 'package:kistream/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kistream/features/auth/data/models/user_model.dart';
import 'package:kistream/features/music/data/models/song_model.dart';
import 'package:kistream/features/music/presentation/bloc/player_bloc.dart';
import 'package:kistream/features/music/presentation/bloc/song_bloc.dart';
import 'package:kistream/features/shared/widgets/song_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const SizedBox(height: 15),
              const HomeHeader(),
              const SizedBox(height: 20),

              // Search / Mood
              const FeelingWidget(),
              const SizedBox(height: 30),

              // Trending / Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Trending Songs",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.queue_music_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () {
                      context.push('/add-song');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 5),
              _buildTrendingSongsSection(context),
              const SizedBox(height: 30),

              // Newly Added Songs
              Text(
                "Newly Added Songs",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 15),
              BlocBuilder<SongBloc, SongState>(
                builder: (context, state) {
                  if (state is SongLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is SongLoaded) {
                    final manualSongs = state.songs
                        .where((s) => s.isManual == true)
                        .toList();
                    if (manualSongs.isEmpty) {
                      return const Text(
                        "No manual songs added yet.",
                        style: TextStyle(color: Colors.grey),
                      );
                    }
                    return SizedBox(
                      height: 160,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: manualSongs.length,
                        itemBuilder: (context, index) {
                          final song = manualSongs[index];
                          return SongCard(
                            songImage: song.songImage,
                            songName: song.songName,
                            onTap: () {
                              context.read<PlayerBloc>().add(
                                PlaySong(song, queue: manualSongs),
                              );
                              context.push('/player', extra: song);
                            },
                          );
                        },
                      ),
                    );
                  } else if (state is SongError) {
                    return Text(
                      "Error: ${state.message}",
                      style: const TextStyle(color: Colors.red),
                    );
                  }
                  return const Text(
                    "No manual songs added yet.",
                    style: TextStyle(color: Colors.grey),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrendingSongsSection(BuildContext context) {
    // Create the trending songs list
    final trendingSongs = [
      SongModel(
        id: "4",
        songName: "Dreaming",
        artistName: "Dream Artist",
        songImage: "https://picsum.photos/200/200?random=4",
        audioFile:
            "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
        dateAdded: DateTime.now(),
      ),
      SongModel(
        id: "5",
        songName: "Peace",
        artistName: "Peace Artist",
        songImage: "https://picsum.photos/200/200?random=5",
        audioFile:
            "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
        dateAdded: DateTime.now(),
      ),
      SongModel(
        id: "6",
        songName: "Enjoy World",
        artistName: "World Artist",
        songImage: "https://picsum.photos/200/200?random=6",
        audioFile:
            "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
        dateAdded: DateTime.now(),
      ),
      SongModel(
        id: "13",
        songName: "As It Was",
        artistName: "Harry Styles",
        songImage: "https://picsum.photos/200/200?random=13",
        audioFile:
            "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
        dateAdded: DateTime.now(),
      ),
      SongModel(
        id: "14",
        songName: "Anti-Hero",
        artistName: "Taylor Swift",
        songImage: "https://picsum.photos/200/200?random=14",
        audioFile:
            "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
        dateAdded: DateTime.now(),
      ),
      SongModel(
        id: "15",
        songName: "Flowers",
        artistName: "Miley Cyrus",
        songImage: "https://picsum.photos/200/200?random=15",
        audioFile:
            "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
        dateAdded: DateTime.now(),
      ),
      SongModel(
        id: "16",
        songName: "Calm Down",
        artistName: "Rema & Selena Gomez",
        songImage: "https://picsum.photos/200/200?random=16",
        audioFile:
            "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
        dateAdded: DateTime.now(),
      ),
    ];

    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: trendingSongs.length,
        itemBuilder: (context, index) {
          final song = trendingSongs[index];
          return SongCard(
            songImage: song.songImage,
            songName: song.songName,
            onTap: () {
              // Play this song with the full trending queue
              context.read<PlayerBloc>().add(
                PlaySong(song, queue: trendingSongs),
              );
              context.push('/player', extra: song);
            },
          );
        },
      ),
    );
  }
}

class FeelingWidget extends StatefulWidget {
  const FeelingWidget({super.key});

  @override
  State<FeelingWidget> createState() => _FeelingWidgetState();
}

class _FeelingWidgetState extends State<FeelingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    const curve = Curves.easeOutQuart;

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: curve));

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: curve));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: curve));

    _startAnimationLoop();
  }

  void _startAnimationLoop() async {
    while (mounted) {
      await _controller.forward();
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) break;
      await _controller.reverse();
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.go('/search');
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(30),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 10),
                  Text(
                    "What do you want to listen to?",
                    style: TextStyle(color: Colors.grey[400], fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        UserModel? user;
        if (state is Authenticated) {
          user = state.user;
        }

        final hour = DateTime.now().hour;
        String greeting = "Good Evening,";
        if (hour < 12) {
          greeting = "Good Morning,";
        } else if (hour < 17) {
          greeting = "Good Afternoon,";
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  user?.displayName ?? "Guest",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),

            GestureDetector(
              onTap: () => context.go('/profile'),
              child: CircleAvatar(
                radius: 25,
                backgroundImage: _getProfileImage(user?.photoUrl),
              ),
            ),
          ],
        );
      },
    );
  }

  ImageProvider _getProfileImage(String? photoUrl) {
    if (photoUrl != null && photoUrl.isNotEmpty) {
      if (photoUrl.startsWith('http') || photoUrl.startsWith('https')) {
        return NetworkImage(photoUrl);
      } else if (File(photoUrl).existsSync()) {
        return FileImage(File(photoUrl));
      }
    }
    return const NetworkImage(
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS-DXFpesytRtBxTDt3pmlwFLKZAPbUkQ_CDg&s",
    );
  }
}
