import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kistream/features/music/data/models/song_model.dart';
import 'package:kistream/features/music/presentation/bloc/player_bloc.dart';
import 'package:kistream/features/shared/widgets/song_image.dart';
import 'package:kistream/features/shared/widgets/music_visualizer.dart';
import 'package:kistream/core/theme/app_theme.dart';

class SongListTile extends StatelessWidget {
  final SongModel song;
  final List<SongModel> queue;
  final VoidCallback? onTap;

  const SongListTile({
    super.key,
    required this.song,
    required this.queue,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerState>(
      builder: (context, playerState) {
        bool isCurrentlyPlaying = false;
        if (playerState is PlayerPlaying) {
          isCurrentlyPlaying =
              playerState.song.id == song.id && playerState.isPlaying;
        }

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ),
          leading: SongImage(
            imageUrl: song.songImage,
            width: 60,
            height: 60,
            borderRadius: 6,
          ),
          title: Text(
            song.songName,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          subtitle: Text(
            song.artistName,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isCurrentlyPlaying)
                const MusicVisualizer(
                  color: AppTheme.primaryColor,
                  barWidth: 3.0,
                  spacing: 2.0,
                  numberOfBars: 3,
                ),
            ],
          ),
          onTap:
              onTap ??
              () {
                context.read<PlayerBloc>().add(PlaySong(song, queue: queue));
              },
        );
      },
    );
  }
}
