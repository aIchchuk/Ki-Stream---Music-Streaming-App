import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/server_health_data_source.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../music/domain/repositories/song_repository.dart';
import '../../../music/data/models/song_model.dart';
import '../../../music/domain/repositories/playlist_repository.dart';
import '../../../music/data/models/playlist_model.dart';
import '../../../shared/widgets/song_image.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  bool _showUsers = false;
  bool _showSongs = false;
  bool _showPlaylists = false;
  bool _isServerDown = false;

  @override
  void initState() {
    super.initState();
    _checkServerStatus();
  }

  Future<void> _checkServerStatus() async {
    final isRunning = await sl<ServerHealthDataSource>().isServerRunning();
    if (mounted) {
      setState(() => _isServerDown = !isRunning);
    }
  }

  void _showServerError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Server is unreachable. Admin actions are disabled."),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _deleteUser(String id, String name) async {
    if (_isServerDown) {
      _showServerError();
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text("Delete User", style: TextStyle(color: Colors.white)),
        content: Text(
          "Are you sure you want to delete user '$name'?\nThis action cannot be undone.",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await GetIt.I<AuthRepository>().deleteUser(id);
        setState(() {}); // Refresh list
      } catch (e) {
        _showError(e.toString());
      }
    }
  }

  Future<void> _deleteSong(String id, String name) async {
    if (_isServerDown) {
      _showServerError();
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text("Delete Song", style: TextStyle(color: Colors.white)),
        content: Text(
          "Are you sure you want to delete song '$name'?\nThis action cannot be undone.",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await GetIt.I<SongRepository>().deleteSong(id);
        setState(() {}); // Refresh list
      } catch (e) {
        _showError(e.toString());
      }
    }
  }

  Future<void> _deletePlaylist(String id, String name) async {
    if (_isServerDown) {
      _showServerError();
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text(
          "Delete Playlist",
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          "Are you sure you want to delete playlist '$name'?\nThis action cannot be undone.",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await GetIt.I<PlaylistRepository>().deletePlaylist(id);
        setState(() {}); // Refresh list
      } catch (e) {
        _showError(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,

      body: (!_showUsers && !_showSongs && !_showPlaylists)
          ? FutureBuilder<Map<String, int>>(
              future:
                  Future.wait([
                    GetIt.I<AuthRepository>().getAllUsers(),
                    GetIt.I<SongRepository>().getSongs(),
                    GetIt.I<PlaylistRepository>().getPlaylists(),
                  ]).then(
                    (results) => {
                      'users': (results[0] as List<UserModel>).length,
                      'songs': (results[1] as List<SongModel>).length,
                      'playlists': (results[2] as List<PlaylistModel>).length,
                    },
                  ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading stats: ${snapshot.error}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => setState(() {}),
                          child: const Text("Retry"),
                        ),
                      ],
                    ),
                  );
                }

                final stats =
                    snapshot.data ?? {'users': 0, 'songs': 0, 'playlists': 0};

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStatCard(
                          "Total Users",
                          stats['users']!,
                          Icons.people,
                        ),
                        const SizedBox(height: 20),
                        _buildStatCard(
                          "Total Songs",
                          stats['songs']!,
                          Icons.music_note,
                        ),
                        const SizedBox(height: 20),
                        _buildStatCard(
                          "Total Playlists",
                          stats['playlists']!,
                          Icons.playlist_play_rounded,
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton(
                          onPressed: () => setState(() => _showUsers = true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            fixedSize: const Size(250, 60),
                          ),
                          child: const Text(
                            "Check Users",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        ElevatedButton(
                          onPressed: () => setState(() => _showSongs = true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            fixedSize: const Size(250, 60),
                          ),
                          child: const Text(
                            "Check Songs",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        ElevatedButton(
                          onPressed: () =>
                              setState(() => _showPlaylists = true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            fixedSize: const Size(250, 60),
                          ),
                          child: const Text(
                            "Check Playlists",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        ElevatedButton(
                          onPressed: _showClearCacheConfirmation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.withValues(alpha: 0.8),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            fixedSize: const Size(250, 60),
                          ),
                          child: const Text(
                            "Clear Local Cache",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          : _showUsers
          ? _buildUsersList()
          : _showSongs
          ? _buildSongsList()
          : _buildPlaylistsList(),
      appBar: AppBar(
        leading: (_showUsers || _showSongs || _showPlaylists)
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() {
                  _showUsers = false;
                  _showSongs = false;
                  _showPlaylists = false;
                }),
              )
            : null,
        title: Row(
          children: [
            Text(
              _showUsers
                  ? "All Users"
                  : _showSongs
                  ? "All Songs"
                  : _showPlaylists
                  ? "All Playlists"
                  : "Admin Dashboard",
              style: const TextStyle(color: Colors.white),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _isServerDown ? Colors.red : Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _isServerDown ? "Offline" : "Online",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
    );
  }

  Future<void> _showClearCacheConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text(
          "Clear Local Cache",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "This will delete ALL local data (users, songs, playlists) stored in Hive. This will NOT affect the server. Continue?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Clear All"),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await GetIt.I<AuthRepository>().clearLocalCache();
        await GetIt.I<SongRepository>().clearLocalCache();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Local cache cleared successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {}); // Refresh stats
      } catch (e) {
        _showError("Failed to clear cache: $e");
      }
    }
  }

  Widget _buildUsersList() {
    return FutureBuilder<List<UserModel>>(
      future: GetIt.I<AuthRepository>().getAllUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Error loading users: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text("Retry"),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'No users found',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        final users = snapshot.data!;
        return ListView.builder(
          itemCount: users.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final user = users[index];
            return Card(
              color: AppTheme.surfaceColor,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  backgroundImage: _getProfileImageProvider(user.photoUrl),
                  child: (user.photoUrl == null || user.photoUrl!.isEmpty)
                      ? Text(
                          user.displayName.isNotEmpty
                              ? user.displayName[0].toUpperCase()
                              : "?",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                title: Text(
                  user.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(user.email, style: TextStyle(color: Colors.grey[400])),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${user.id}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _deleteUser(user.id, user.displayName),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSongsList() {
    return FutureBuilder<List<SongModel>>(
      future: GetIt.I<SongRepository>().getSongs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Error loading songs: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text("Retry"),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'No songs found',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        final songs = snapshot.data!;
        return ListView.builder(
          itemCount: songs.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final song = songs[index];
            return Card(
              color: AppTheme.surfaceColor,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: SongImage(
                  imageUrl: song.songImage,
                  width: 50,
                  height: 50,
                  borderRadius: 8,
                ),
                title: Text(
                  song.songName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      song.artistName,
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${song.id}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _deleteSong(song.id, song.songName),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPlaylistsList() {
    return FutureBuilder<List<PlaylistModel>>(
      future: GetIt.I<PlaylistRepository>().getPlaylists(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Error loading playlists: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text("Retry"),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'No playlists found',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        final playlists = snapshot.data!;
        return ListView.builder(
          itemCount: playlists.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final playlist = playlists[index];
            final color = Colors
                .primaries[playlist.mood.hashCode % Colors.primaries.length];

            return Card(
              color: AppTheme.surfaceColor,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: playlist.imagePath == null
                        ? LinearGradient(
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
                  ),
                  child: playlist.imagePath == null
                      ? const Icon(Icons.music_note, color: Colors.white70)
                      : null,
                ),
                title: Text(
                  playlist.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      '${playlist.songIds.length} songs • ${playlist.mood}',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'By: ${playlist.creatorName ?? 'Unknown'}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _deletePlaylist(playlist.id, playlist.name),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard(String label, int value, IconData icon) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 30),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 5),
          Text(
            value.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  ImageProvider? _getProfileImageProvider(String? path) {
    if (path == null || path.isEmpty) return null;
    return SongImage.getImageProvider(path);
  }
}
