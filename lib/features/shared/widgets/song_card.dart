import 'package:flutter/material.dart';
import './song_image.dart';
import './playing_highlight.dart';

class SongCard extends StatelessWidget {
  final String songImage;
  final String songName;
  final VoidCallback? onTap;
  final bool isPlaying;

  const SongCard({
    super.key,
    required this.songImage,
    required this.songName,
    this.onTap,
    this.isPlaying = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 15.0),
        child: Column(
          children: [
            PlayingHighlight(
              isActive: isPlaying,
              borderRadius: 15,
              child: SongImage(
                imageUrl: songImage,
                width: 110,
                height: 110,
                borderRadius: 15,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 110,
              child: Text(
                songName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
