import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kistream/core/theme/app_theme.dart';
import '../../../music/presentation/bloc/downloads_bloc.dart';
import '../../../shared/widgets/song_list_tile.dart';

class DownloadsPage extends StatelessWidget {
  const DownloadsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Downloads",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocBuilder<DownloadsBloc, DownloadsState>(
        builder: (context, state) {
          if (state is DownloadsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DownloadsLoaded) {
            if (state.songs.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.download_for_offline_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 20),
                    Text(
                      "No downloaded songs yet.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: state.songs.length,
              itemBuilder: (context, index) {
                final song = state.songs[index];
                return SongListTile(song: song, queue: state.songs);
              },
            );
          } else if (state is DownloadsError) {
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
}
