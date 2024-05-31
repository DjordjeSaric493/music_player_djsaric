import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

class AlbumSongsPage extends StatefulWidget {
  final int albumId;
  const AlbumSongsPage({super.key, required this.albumId});

  @override
  State<AlbumSongsPage> createState() => _AlbumSongsPageState();
}

class _AlbumSongsPageState extends State<AlbumSongsPage> {
  Future<List<SongModel>>? songsQuery;
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final AudioPlayer _audioPlayer = AudioPlayer();
  late Future<List<SongModel>> _songsFuture;

  @override
  void initState() {
    super.initState();

    _songsFuture = _fetchSongs();
    //hold the future result of the songs that will be fetched from the specified album.
  }

  Future<List<SongModel>> _fetchSongs() async {
    // Request permission
    bool permissionStatus = await _audioQuery.permissionsStatus();
    if (!permissionStatus) {
      await _audioQuery
          .permissionsRequest(); //if it doesn't have permissions it will ask for it
    }
    // Fetch songs from the specified album
    return await _audioQuery.queryAudiosFrom(
      AudiosFromType.ALBUM_ID, //specified album
      widget.albumId,
      sortType: SongSortType.TITLE, // sort songs by title
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //TODO:
        title: Text('ADD HERE TEXT DO DISPLAY ALBUM NAME '),
      ),
      body: FutureBuilder<List<SongModel>>(
        future: _songsFuture,
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
                  // TODO: Djordje odradi da pebaci na playing now screen
                },
              );
            },
          );
        },
      ),
    );
  }
}
/*
TODO: ideja- za onaj widget koji pušta pesmu, statemngmt, stack jer ide preko listwidgeta izvali kako...

*/