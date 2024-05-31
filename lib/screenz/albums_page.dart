import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_player_djsaric/screenz/album_songs_page.dart';
import 'package:on_audio_query/on_audio_query.dart';

//stf bcuz it can be changed, gonna incorporate more manipulation like delete album when i learn how
//TODO:STREAMBUILDER fetchuj na par minuta
class AlbumsPage extends StatefulWidget {
  const AlbumsPage({super.key});

  @override
  State<AlbumsPage> createState() => _AlbumsPageState();
}

class _AlbumsPageState extends State<AlbumsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<AlbumModel>>(
        future: OnAudioQuery()
            .queryAlbums(), //TODO: Zatraži permisije i ovde, kao u album songs
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No albums found here '));
          }
          List<AlbumModel> albums =
              snapshot.data!; //it' s almost like supachat messing with streams

          return ListView.builder(
            itemCount: albums.length,
            itemBuilder: (context, index) {
              AlbumModel album = albums[index];

              String albumLength = album.album.length.toString() ??
                  'unknown length'; //TODO:OVDE JE DUŽINA STRINGA!!!!
              return ListTile(
                title: Text(album.album),
                subtitle: Text(album.artist ?? 'Unknown artist' + albumLength),
                trailing:
                    QueryArtworkWidget(id: album.id, type: ArtworkType.ALBUM),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AlbumSongsPage(albumId: album.id),
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
//TODO: UČITAVA SA SD NA PAR MINUTA KAO DA FETCH-UJE, KORISTIM STREAMBUILD U TOM SLUČAJU
