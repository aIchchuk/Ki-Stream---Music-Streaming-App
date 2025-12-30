import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../music/data/models/song_model.dart';
import '../../../music/presentation/bloc/player_bloc.dart';

/// MainShell widget with dismissible MiniPlayer and route-aware hiding
class MainShell extends StatefulWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  bool _miniPlayerDismissed = false;

  bool _isPlayerRoute(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    return location.startsWith('/player');
  }

  void _onDismissed() {
    setState(() {
      _miniPlayerDismissed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hideForPlayerPage = _isPlayerRoute(context);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BlocListener<PlayerBloc, PlayerState>(
        listener: (context, state) {
          if (state is PlayerPlaying) {
            // Reset dismissal every time a song is played
            setState(() {
              _miniPlayerDismissed = false;
            });
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!hideForPlayerPage)
              BlocSelector<PlayerBloc, PlayerState, PlayerState>(
                selector: (state) => state,
                builder: (context, state) {
                  final showMiniPlayer = state is PlayerPlaying;

                  if (!showMiniPlayer || _miniPlayerDismissed) {
                    return const SizedBox.shrink();
                  }

                  return DismissibleMiniPlayer(
                    song: state.song,
                    isPlaying: state.isPlaying,
                    onDismissed: _onDismissed,
                  );
                },
              ),
            const _MainBottomNav(),
          ],
        ),
      ),
    );
  }
}

/// MiniPlayer widget with horizontal swipe-to-dismiss animation
class DismissibleMiniPlayer extends StatefulWidget {
  final SongModel song;
  final bool isPlaying;
  final VoidCallback onDismissed;

  const DismissibleMiniPlayer({
    super.key,
    required this.song,
    required this.isPlaying,
    required this.onDismissed,
  });

  @override
  State<DismissibleMiniPlayer> createState() => _DismissibleMiniPlayerState();
}

class _DismissibleMiniPlayerState extends State<DismissibleMiniPlayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.0, 0), // Slide out to right
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onDismissed();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDismiss() {
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null &&
              details.primaryVelocity! > 300) {
            _handleDismiss();
          }
        },
        child: MiniPlayer(song: widget.song, isPlaying: widget.isPlaying),
      ),
    );
  }
}

/// Your MiniPlayer widget
class MiniPlayer extends StatelessWidget {
  final SongModel song;
  final bool isPlaying;

  const MiniPlayer({super.key, required this.song, required this.isPlaying});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/player', extra: song),
      child: Stack(
        children: [
          Container(
            height: 68,
            margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: _buildMiniPlayerImage(song.songImage),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.songName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        song.artistName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      context.read<PlayerBloc>().add(TogglePlay());
                    },
                  ),
                ),
              ],
            ),
          ),
          // Progress Bar at the bottom
          Positioned(
            left: 26,
            right: 26,
            bottom: 6,
            child: StreamBuilder<Duration>(
              stream: context.read<PlayerBloc>().positionStream,
              builder: (context, posSnapshot) {
                final position = posSnapshot.data ?? Duration.zero;
                return StreamBuilder<Duration?>(
                  stream: context.read<PlayerBloc>().durationStream,
                  builder: (context, durSnapshot) {
                    final duration = durSnapshot.data ?? Duration.zero;
                    final progress = duration.inMilliseconds > 0
                        ? position.inMilliseconds / duration.inMilliseconds
                        : 0.0;
                    return ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 2,
                        backgroundColor: Colors.white10,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF8B80F9), // Purple accent
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniPlayerImage(String path) {
    if (path.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: path,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: 48,
          height: 48,
          color: Colors.white10,
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        errorWidget: (context, url, error) => _buildErrorImage(),
      );
    } else if (File(path).existsSync()) {
      return Image.file(File(path), width: 48, height: 48, fit: BoxFit.cover);
    } else {
      return _buildErrorImage();
    }
  }

  Widget _buildErrorImage() {
    return Image.network(
      "https://picsum.photos/200/200?random=error",
      width: 48,
      height: 48,
      fit: BoxFit.cover,
    );
  }
}

/// Bottom Navigation Bar (unchanged core logic, but styles adjusted to match source)
class _MainBottomNav extends StatelessWidget {
  const _MainBottomNav();

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.black,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF8B80F9), // Purple accent
      unselectedItemColor: Colors.grey,
      currentIndex: _currentIndex(context),
      onTap: (index) => _onTap(context, index),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        BottomNavigationBarItem(
          icon: Icon(Icons.bookmark_outline),
          label: 'Library',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    if (location.startsWith('/search')) return 1;
    if (location.startsWith('/library')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/search');
        break;
      case 2:
        context.go('/library');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }
}
