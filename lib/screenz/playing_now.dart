import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music_player_djsaric/screenz/widgets/artwork_widget.dart';
import 'package:on_audio_query/on_audio_query.dart';

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
  }

  @override
  //design
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;
    //bolje kao grid za responsivity
    return SafeArea(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_outlined),
            ),
            SizedBox(
              height: 30.0,
            ),
            Center(
              child: Column(
                children: [
                  CircleAvatar(radius: 100.0, child: ArtworkWidget()),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Text(
                    widget.songModel.displayNameWOExt, //see supachat app
                    //display name of the song from widget
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 30.0),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    //if value of artist is unknown print Unknown Artist, else parse artist and display it
                    widget.songModel.artist.toString() == "<unknown>"
                        ? "Unknown song artist"
                        : widget.songModel.artist.toString(),
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    //duration  how song is long in format hour:min:sec
                    //position current playing time
                    children: [
                      Text(_position.toString().split(".")[0]),
                      Expanded(
                        child: Slider(
                          min: const Duration(milliseconds: 0)
                              .inSeconds
                              .toDouble(),
                          value: _position.inSeconds
                              .toDouble(), //value accepts double
                          max: _duration.inSeconds.toDouble(),
                          onChanged: (value) {
                            setState(() {
                              change2seconds(value.toInt());
                              value = value;
                            });
                          },
                        ),
                      ),
                      Text(_duration.toString().split(".")[0])
                      //duration is in milisecs, figured out how to displ mins and secs
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        onPressed: () {
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
                        //play/pause button logik -> use setState 4 it
                        onPressed: () {
                          setState(() {
                            //bool value is false so if val is false pause else play
                            if (isPlaying) {
                              //better way to type condition, won't type isPlayin=true, this is not uni project lol
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
                        //skip button logik
                        onPressed: () {
                          if (widget.audioPlayer.hasNext) {
                            widget.audioPlayer.seekToNext();
                          }
                        },
                        icon: const Icon(
                          Icons.skip_next_rounded,
                          size: 40,
                        ),
                      )
                    ],
                  )
                ],
              ),
            )
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
