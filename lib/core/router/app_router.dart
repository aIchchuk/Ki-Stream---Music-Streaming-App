import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/pages/main_shell.dart';
import '../../features/library/presentation/pages/library_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/admin_dashboard_page.dart';
import '../../features/music/presentation/pages/add_song_page.dart';
import '../../features/music/presentation/pages/create_playlist_page.dart';
import '../../features/music/presentation/pages/playlist_detail_page.dart';
import '../../features/music/presentation/pages/player_page.dart';
import '../../features/music/data/models/playlist_model.dart';
import '../../features/library/presentation/pages/favorites_page.dart';
import '../../features/library/presentation/pages/playlists_page.dart';
import '../../features/search/presentation/pages/search_page.dart';
import '../../features/music/data/models/song_model.dart';

import '../../features/library/presentation/pages/downloads_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/signup', builder: (context, state) => const SignUpPage()),
    GoRoute(
      path: '/add-song',
      builder: (context, state) => const AddSongPage(),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/player',
          builder: (context, state) {
            final song = state.extra as SongModel;
            return PlayerPage(song: song);
          },
        ),
        GoRoute(path: '/home', builder: (context, state) => const HomePage()),
        GoRoute(
          path: '/search',
          builder: (context, state) => const SearchPage(),
        ),
        GoRoute(
          path: '/library',
          builder: (context, state) => const LibraryPage(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          path: '/favorites',
          builder: (context, state) => const FavoritesPage(),
        ),
        GoRoute(
          path: '/downloads',
          builder: (context, state) => const DownloadsPage(),
        ),
        GoRoute(
          path: '/admin-dashboard',
          builder: (context, state) => const AdminDashboardPage(),
        ),
        GoRoute(
          path: '/playlists',
          builder: (context, state) => const PlaylistsPage(),
        ),
        GoRoute(
          path: '/create-playlist',
          builder: (context, state) => const CreatePlaylistPage(),
        ),
        GoRoute(
          path: '/playlist-detail',
          builder: (context, state) {
            final playlist = state.extra as PlaylistModel;
            return PlaylistDetailPage(playlist: playlist);
          },
        ),
      ],
    ),
  ],
);
