import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player_djsaric/screens/playing_now.dart';
import 'package:music_player_djsaric/state-provider/song_provider.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

class AlbumSongsPage extends StatefulWidget {
  final int albumId;
  final String album;
  const AlbumSongsPage({super.key, required this.albumId, required this.album});

  @override
  State<AlbumSongsPage> createState() => _AlbumSongsPageState();
}

class _AlbumSongsPageState extends State<AlbumSongsPage> {
  Future<List<SongModel>>? songsQuery;
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final StreamController<List<SongModel>> _songsAlbumController =
      StreamController<List<SongModel>>.broadcast();
  Timer? _queryTimer;

  @override
  void initState() {
    super.initState();
    startQueryingSongs();
    //Hold the future result of the songs that will be fetched from the specified album.
  }

  void startQueryingSongs() {
    _queryTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      querySongs();
    });
    querySongs(); // Initial query
  }

  Future<void> querySongs() async {
    bool permissionStatus = await _audioQuery.permissionsStatus();
    if (!permissionStatus) {
      permissionStatus = await _audioQuery.permissionsRequest();
    }
    if (permissionStatus) {
      List<SongModel> songs = await _audioQuery.queryAudiosFrom(
        AudiosFromType.ALBUM_ID,
        widget.albumId,
        sortType: SongSortType.TITLE,
      );
      _songsAlbumController.add(songs);
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.album.toString()),
      ),
      body: StreamBuilder<List<SongModel>>(
        stream: _songsAlbumController.stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No songs found.'));
          }

          List<SongModel> songs = snapshot.data!;

          return ListView.builder(
            itemCount: songs.length,
            itemBuilder: (context, index) {
              SongModel song = songs[index];
              return ListTile(
                title: Text(song.title),
                subtitle: Text(song.artist ?? 'Unknown Artist'),
                onTap: () {
                  // It's playing a song from particular album
                  context.read<SongProvider>().setId(snapshot.data![index].id);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlayingNow(
                          songModel: snapshot.data![index],
                          audioPlayer: _audioPlayer,
                          songList: [],
                        ),
                      ));
                },
              );
            },
          );
        },
      ),
    );
  }
}
