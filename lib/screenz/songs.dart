import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player_djsaric/screenz/playing_now.dart';
import 'package:on_audio_query/on_audio_query.dart';

//note check out audioquery package: https://pub.dev/packages/on_audio_query
//refer on documentation for messing up with androidmanifest.xml and ios info.plist
class Songs extends StatefulWidget {
  const Songs({super.key});

  @override
  State<Songs> createState() => _SongsState();
}

class _SongsState extends State<Songs> {
  bool _hasPermission = false;
  Future<List<SongModel>>? songsQuery;
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final AudioPlayer _audioPlayer = AudioPlayer();

  //this function accepts uri
  playSong(String? uri) {
    //Sets the source from which this audio player should fetch audio
    try {
      _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(uri!)));
      // uri! means "trust me bro uri is not null"
      _audioPlayer.play(); //name says it all
    } catch (e) {
      //figured out this may mess up so I gotta surround w try-catch
      print("Error parsing song");
    }
  }

  @override
  void initState() {
    super.initState();

    LogConfig logConfig = LogConfig(logType: LogType.DEBUG);
    _audioQuery.setLogConfig(logConfig);

    // Check and request for permission.
    checkAndRequestPermissions();
  }

  checkAndRequestPermissions({bool retry = false}) async {
    // The param 'retryRequest' is false, by default.
    _hasPermission = await _audioQuery.checkAndRequest(
      retryRequest: retry,
    );

    // Only call update the UI if application has all required permissions.
    // _hasPermission ? setState(() {}) : null;
    if (_hasPermission) {
      //if i have permissions build ui
      setState(() {
        songsQuery = _audioQuery.querySongs(
          sortType: null,
          orderType: OrderType.ASC_OR_SMALLER,
          uriType: UriType.EXTERNAL, //external storagem to read from device mem
          ignoreCase: true, //
        );
      });
    }
  }

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
      body: songsQuery == null
          ? SizedBox()
          : FutureBuilder<List<SongModel>>(
              future: songsQuery,
              builder: (context, item) {
                if (item.data == null) {
                  return const Center(
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
                  return const Center(
                    child: Text("No songs found"),
                  );
                }
                return ListView.builder(
                  itemCount: item.data!.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: QueryArtworkWidget(
                        id: item.data![index].id,
                        type: ArtworkType.AUDIO,
                        nullArtworkWidget: const Icon(
                          Icons.music_note_outlined,
                          color: Colors.blueAccent,
                        ),
                      ),
                      title: Text(item
                          .data![index].displayNameWOExt), //return song name
                      subtitle: Text(
                          "${item.data![index].artist}"), //or do->this item.data![index].artist.toString())
                      trailing: const Icon(Icons.more_horiz_sharp,
                          color: Colors.blueAccent),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlayingNow(
                                songModel: item.data![index],
                                audioPlayer: _audioPlayer,
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
