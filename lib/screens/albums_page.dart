import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_player_djsaric/screens/album_songs_page.dart';
import 'package:on_audio_query/on_audio_query.dart';

//Stateful widget, showing albums (using streams for updating UI)
class AlbumsPage extends StatefulWidget {
  AlbumsPage({super.key});

  @override
  State<AlbumsPage> createState() => _AlbumsPageState();
}

class _AlbumsPageState extends State<AlbumsPage> {
  final StreamController<List<AlbumModel>> _albumsStreamController =
      StreamController();

  @override
  void initState() {
    fetchALbums(); //Fetch albums TODO: Try to not forget next time
    super.initState();
  }

  Future<void> fetchALbums() async {
    try {
      await OnAudioQuery().permissionsRequest();

      //Fetch album data here
      List<AlbumModel> albums = await OnAudioQuery().queryAlbums();
      _albumsStreamController.add(albums);
    } catch (e) {
      print('$e');
    }
  }

  @override
  void dispose() {
    _albumsStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<AlbumModel>>(
        stream: _albumsStreamController.stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No albums found here '));
          }
          List<AlbumModel> albums = snapshot.data!;

          return ListView.builder(
            itemCount: albums.length,
            itemBuilder: (context, index) {
              AlbumModel album = albums[index];

              return ListTile(
                title: Text(album.album),
                subtitle: Text(
                    'artist: ${album.artist ?? 'Unknown artist'}  songs: ' +
                        album.numOfSongs.toString()),
                trailing:
                    QueryArtworkWidget(id: album.id, type: ArtworkType.ALBUM),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AlbumSongsPage(
                        albumId: album.id,
                        album: '',
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
