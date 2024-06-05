import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import 'package:music_player_djsaric/state-provider/song_provider.dart';

class ArtworkWidget extends StatefulWidget {
  final int songId;
  const ArtworkWidget({super.key, required this.songId});

  @override
  _ArtworkWidgetState createState() => _ArtworkWidgetState();
}

class _ArtworkWidgetState extends State<ArtworkWidget> {
  late int currentSongId;
  late Future<Widget> artworkFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    currentSongId = context.watch<SongProvider>().id;
    artworkFuture = fetchArtwork(currentSongId);
  }
  //32-45 U BUILD METHOD, FWTCH ARTWORK DA VRAĆA SAMO ARTWORK

  Future<Widget> fetchArtwork(int songId) async {
    final artwork = await OnAudioQuery().queryArtwork(
      songId,
      ArtworkType.AUDIO,
      size: 200, // Size in pixels
      format: ArtworkFormat.JPEG,
    );
    if (artwork != null) {
      return Image.memory(
        artwork,
        fit: BoxFit.cover,
        height: 200,
        width: 200,
      );
    } else {
      return const Icon(
        Icons.music_note_rounded,
        color: Colors.blueAccent,
        size: 200,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final songProvider = context.watch<SongProvider>();

    // Check if the song ID has changed
    if (songProvider.id != currentSongId) {
      currentSongId = songProvider.id;
      artworkFuture = fetchArtwork(currentSongId);
    }

    return FutureBuilder<Widget>(
      future: artworkFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return snapshot.data!;
        } else {
          return const Icon(
            Icons.music_note_rounded,
            color: Colors.blueAccent,
            size: 200,
          );
        }
      },
    );
  }
}
