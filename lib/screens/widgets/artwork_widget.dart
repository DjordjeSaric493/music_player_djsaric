import 'dart:async';
import 'dart:typed_data';

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
  // late Future<Widget> artworkFuture;
  late StreamController<Uint8List?> artworkController;

  @override
  void initState() {
    artworkController = StreamController<Uint8List?>();
    currentSongId = widget.songId;
    fetchArtwork(widget.songId);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    currentSongId = context.watch<SongProvider>().id;
  }

  Stream<Uint8List?> fetchArtwork(int songId) async* {
    final artwork = await OnAudioQuery().queryArtwork(
      songId,
      ArtworkType.AUDIO,
      size: 200, // Size in pixels
      format: ArtworkFormat.JPEG,
    );
    artworkController.add(artwork);
  }

  @override
  void dispose() {
    artworkController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final songProvider = context.watch<SongProvider>();

    // Check if the song ID has changed
    if (songProvider.id != currentSongId) {
      currentSongId = songProvider.id;
    }

    return StreamBuilder<Uint8List?>(
      stream: artworkController.stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active &&
            snapshot.hasData) {
          final albumArtwork = snapshot.data;
          //if there is album art return it
          if (albumArtwork != null) {
            return Image.memory(
              albumArtwork,
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

/* renderuj widget u build a ne u future!!!!
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
    }*/
