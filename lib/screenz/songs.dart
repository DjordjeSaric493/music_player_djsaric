import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player_djsaric/screenz/playing_now.dart';
import 'package:music_player_djsaric/state-provider/song_provider.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

//Note  audioquery package: https://pub.dev/packages/on_audio_query
//Refer on documentation for  androidmanifest.xml and ios info.plist
class Songs extends StatefulWidget {
  const Songs({super.key});

  @override
  State<Songs> createState() => _SongsState();
}

class _SongsState extends State<Songs> {
  bool _hasPermission = false;
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? scanTimer;
  // StreamController for songs
  final StreamController<List<SongModel>> _songsController =
      StreamController<List<SongModel>>.broadcast();

  // this function accepts uri
  void playSong(String? uri) {
    // Sets the source from which this audio player should fetch audio
    try {
      _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(uri!)));
      // uri! means "trust me bro uri is not null"
      _audioPlayer.play(); // name says it all
    } catch (e) {
      // figured out this may mess up so I gotta surround w try-catch
      print("Error parsing song: $e");
    }
  }

  @override
  void initState() {
    super.initState();

    LogConfig logConfig = LogConfig(logType: LogType.DEBUG);
    _audioQuery.setLogConfig(logConfig);

    // Check and request for permission.
    checkAndRequestPermissions();
    startScan();
  }

  void startScan() {
    scanTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      scanNewMusic();
    });
    scanNewMusic(); // initial scan
  }

  Future<void> scanNewMusic() async {
    try {
      // root of internal storage
      final rootDirectory = Directory('/storage/emulated/0');

      if (rootDirectory.existsSync()) {
        //check syncronous
        scanDirectory(rootDirectory);
      } else {
        print("Can't find directory");
      }
    } catch (e) {
      print("$e");
    }
  }

  /* void scanDirectory(Directory directory) {
    //TODO: DA VRAĆA LISTE PESAMA
    try {
      //this
      List<FileSystemEntity> entities = directory.listSync(recursive: true);
      List<SongModel> newSongs = [];
      for (FileSystemEntity entity in entities) {
        if (entity is File) {
          if (_isMusicFile(entity.path)) {
            // Query the song details and add to newSongs list
            _audioQuery
                .querySongs(
              path: entity.path,
              uriType: UriType.EXTERNAL,
            )
                .then((songs) {
              if (songs.isNotEmpty) {
                newSongs.addAll(songs);
                // Add the new songs to the stream
                _songsController.add(newSongs);
              }
            });
          }
        }
      }
    } catch (e) {
      print('$e');
    }
  }*/
  //try to return list of songs

  Future<List<SongModel>> scanDirectory(Directory directory) async {
    List<SongModel> newSongs = [];
    try {
      List<FileSystemEntity> entities = directory.listSync(recursive: true);
      for (FileSystemEntity entity in entities) {
        if (entity is File) {
          //check if it's a music file, see bool isMusicFIle
          if (_isMusicFile(entity.path)) {
            //now query the song details using audioQuery
            List<SongModel> songs = await _audioQuery.querySongs(
              path: entity.path,
              uriType: UriType.EXTERNAL,
            );
            if (songs.isNotEmpty) {
              newSongs.addAll(songs);
            }
          }
        }
      }
      return newSongs;
    } catch (e) {
      print('$e');
      return [];
    }
  }

  bool _isMusicFile(String path) {
    // if file ends with any of these its music file I guess
    const mediaExtensions = ['.mp3', '.wav', '.flac'];
    return mediaExtensions.any((extension) => path.endsWith(extension));
  }

  Future<void> checkAndRequestPermissions({bool retry = false}) async {
    // The param 'retryRequest' is false, by default.
    _hasPermission = await _audioQuery.checkAndRequest(
      retryRequest: retry,
    );

    // Only update the UI if the application has all required permissions.
    if (_hasPermission) {
      _audioQuery
          .querySongs(
        sortType: null,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL, // external storage to read from device mem
        ignoreCase: true,
      )
          .then((songs) {
        if (songs.isNotEmpty) {
          _songsController.add(songs);
        }
      });
    }
  }

  @override
  void dispose() {
    _songsController.close();
    scanTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //front end 💀
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
      // here I want to make list of songs,
      // I don't how much songs I have in device
      body: StreamBuilder<List<SongModel>>(
        stream: _songsController.stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: LinearProgressIndicator(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(5),
                ),
              ),
            );
          }
          if (snapshot.data!.isEmpty) {
            // TODO: add no songs page
            return const Center(
              child: Text("No songs found"),
            );
          }
          //
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return ListTile(
                key: ValueKey(snapshot.data![index].id),
                leading: QueryArtworkWidget(
                  id: snapshot.data![index].id,
                  type: ArtworkType.AUDIO,
                  nullArtworkWidget: const Icon(
                    Icons.music_note_outlined,
                    color: Colors.blueAccent,
                  ),
                ),
                title: Text(
                    snapshot.data![index].displayNameWOExt), // return song name
                subtitle: Text(
                    "${snapshot.data![index].artist}"), // or do -> this item.data![index].artist.toString()
                trailing: const Icon(Icons.more_horiz_sharp,
                    color: Colors.blueAccent),
                onTap: () {
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
