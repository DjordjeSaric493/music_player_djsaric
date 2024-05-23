import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

//note check out audioquery package: https://pub.dev/packages/on_audio_query
//refer on documentation for messing up with androidmanifest.xml and ios info.plist
class Songs extends StatefulWidget {
  const Songs({super.key});

  @override
  State<Songs> createState() => _SongsState();
}

class _SongsState extends State<Songs> {
  final _myAudioQuery = new OnAudioQuery();
  @override
  Widget build(BuildContext context) {
    //f-ing front end 💀
    return Scaffold(
      appBar: AppBar(
        title: const Text("MusicPlayer by Dj. Sarić "),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search_sharp),
            color: Colors.blue,
          ),
        ],
      ),
      //here i want to make list of songs,
      //i dunno how much songs i have in device
      body: FutureBuilder<List<SongModel>>(
        future: _myAudioQuery.querySongs(
          sortType: null,
          orderType: OrderType.ASC_OR_SMALLER,
          uriType: UriType.EXTERNAL, //external storagem to read from device mem
          ignoreCase: true, //
        ),
        builder: (context, item) {
          if (item.data == null) {
            return Center(
              child: LinearProgressIndicator(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(5),
                ),
              ),
            );
          }
          if (item.data!.isEmpty) {
            //  TODO: zameni sa nečim lepšim kasnije
            return Center(
              child: Text("No songs found"),
            );
          }
          return ListView.builder(
            itemBuilder: (context, index) => ListTile(
              leading:
                  const Icon(Icons.music_note_sharp, color: Colors.blueAccent),
              title:
                  Text(item.data![index].displayNameWOExt), //return song name
              subtitle: Text(
                  "${item.data![index].artist}"), //or do->this item.data![index].artist.toString())
              trailing:
                  const Icon(Icons.more_horiz_sharp, color: Colors.blueAccent),
            ),
            itemCount: 50, //show list of 50 songs, will change later
          );
        },
      ),
    );
  }
}
