import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music_player_djsaric/screenz/widgets/artwork_widget.dart';
import 'package:music_player_djsaric/state-provider/song_provider.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

class PlayingNow extends StatefulWidget {
  const PlayingNow(
      {super.key, required this.songModel, required this.audioPlayer});
  final SongModel songModel;
  final AudioPlayer audioPlayer;

  @override
  State<PlayingNow> createState() => _PlayingNowState();
}

class _PlayingNowState extends State<PlayingNow> {
  Duration _duration = const Duration();
  Duration _position = const Duration();

  bool isPlaying = false;

  // StreamController for songs
  final StreamController<List<SongModel>> _songsController =
      StreamController<List<SongModel>>.broadcast();

  @override
  void initState() {
    super.initState();
    playSong();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  //f-tion 4 playing songs
  void playSong() {
    try {
      widget.audioPlayer
          .setAudioSource(AudioSource.uri(Uri.parse(widget.songModel.uri!),
              tag: MediaItem(
                // Specify a unique ID for each media item:
                id: '${widget.songModel.id}',
                // Metadata to display in the notification:
                album: '${widget.songModel.album}',
                title: '${widget.songModel.displayNameWOExt}',
                artUri: Uri.parse(widget.songModel.id.toString()),
              )));
      widget.audioPlayer.play();
      isPlaying = true;
    } catch (e) {
      //secure in case that data is corrupted
      print("cant parse song");
    }

    widget.audioPlayer.durationStream.listen((event) {
      setState(() {
        _duration = event!;
      });
    });
    widget.audioPlayer.positionStream.listen((event) {
      setState(() {
        _position = event; //rcvr cant be null so dont need to use !
      });
    });

    context.read<SongProvider>().id = widget.songModel.id; //get a proper id
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutGrid(
          areas: '''
            back back back
            image image image
            name name name
            artist artist artist
            position position position
            controls controls controls
          ''',
          columnSizes: [1.fr, 1.fr, 1.fr],
          rowSizes: const [
            auto,
            auto,
            auto,
            auto,
            auto,
            auto,
          ],
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.arrow_back_outlined),
            ).inGridArea('back'),
            Center(
              child: CircleAvatar(
                radius: 100.0,
                child: ArtworkWidget(key: ValueKey(widget.songModel.id)),
              ),
            ).inGridArea('image'),
            Center(
              child: Text(
                widget.songModel.displayNameWOExt,
                overflow: TextOverflow.fade,
                maxLines: 1,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 30.0),
              ),
            ).inGridArea('name'),
            Center(
              child: Text(
                widget.songModel.artist.toString() == "<unknown>"
                    ? "Unknown song artist"
                    : widget.songModel.artist.toString(),
                overflow: TextOverflow.fade,
                maxLines: 1,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 20.0),
              ),
            ).inGridArea('artist'),
            Row(
              children: [
                Text(_position.toString().split(".")[0]),
                Expanded(
                  child: Slider(
                    min: const Duration(milliseconds: 0).inSeconds.toDouble(),
                    value: _position.inSeconds.toDouble(),
                    max: _duration.inSeconds.toDouble(),
                    onChanged: (value) {
                      setState(() {
                        change2seconds(value.toInt());
                      });
                    },
                  ),
                ),
                Text(_duration.toString().split(".")[0]),
              ],
            ).inGridArea('position'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: () {
                    //TODO:NEXT I PREVIOUS ME ZAJEBAVA NEĆE DA RADI -> VRV SLIČNO KAO SA PLAY TREBA
                    if (widget.audioPlayer.hasPrevious) {
                      widget.audioPlayer.seekToPrevious();
                    }
                  },
                  icon: const Icon(
                    Icons.skip_previous_rounded,
                    size: 40,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      //PLAY RADI
                      if (isPlaying) {
                        widget.audioPlayer.pause();
                      } else {
                        widget.audioPlayer.play();
                      }
                      isPlaying = !isPlaying;
                    });
                  },
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 40,
                    color: Colors.red,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (widget.audioPlayer.hasNext) {
                      widget.audioPlayer.seekToNext();
                    }
                  },
                  icon: const Icon(
                    Icons.skip_next_rounded,
                    size: 40,
                  ),
                ),
              ],
            ).inGridArea('controls'),
          ],
        ),
      ),
    );
  }

  void change2seconds(int seconds) {
    Duration duration = Duration(seconds: seconds);
    widget.audioPlayer.seek(duration);
  }
}
