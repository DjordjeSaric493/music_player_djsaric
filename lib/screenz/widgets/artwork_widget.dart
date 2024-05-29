import 'package:flutter/material.dart';
import 'package:music_player_djsaric/state-provider/song_provider.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

class ArtworkWidget extends StatelessWidget {
  const ArtworkWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return QueryArtworkWidget(
      id: context.watch<SongProvider>().id,
      type: ArtworkType.AUDIO,
      artworkHeight: 200,
      artworkWidth: 200,
      artworkFit: BoxFit.cover,
      nullArtworkWidget: const Icon(
        Icons.music_note_rounded,
        color: Colors.blueAccent,
        size: 200,
      ),
    );
  }
}
