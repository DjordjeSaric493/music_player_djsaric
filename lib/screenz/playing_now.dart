import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

class PlayingNow extends StatefulWidget {
  const PlayingNow({super.key, required this.songModel});
  final SongModel songModel;

  @override
  State<PlayingNow> createState() => _PlayingNowState();
}

class _PlayingNowState extends State<PlayingNow> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool isPlayin = false;
  @override
  void initState() {
    super.initState();
    playSong();
  }

  //f-tion 4 playing songs
  void playSong() {
    try {
      _audioPlayer
          .setAudioSource(AudioSource.uri(Uri.parse(widget.songModel.uri!)));
      _audioPlayer.play();
      isPlayin = true;
    } catch (e) {
      //secure in case that data is corrupted
      print("cant parse song");
    }
  }

  @override
  //design
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
                  const CircleAvatar(
                    radius: 100.0,
                    child: Icon(
                      Icons.music_note_rounded,
                      size: 80.0,
                    ),
                  ),
                  SizedBox(
                    height: 30.0,
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
                    children: [
                      Text("0.0"),
                      Expanded(
                          child: Slider(value: 0.0, onChanged: (value) {})),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.skip_previous_rounded,
                          size: 40,
                        ),
                      ),
                      IconButton(
                        //play/pause button logik -> use setState 4 it
                        onPressed: () {
                          setState(() {
                            //bool value is false so if val is false pause else play
                            if (isPlayin) {
                              //better way to type condition, won't type isPlayin=true, this is not uni project lol
                              _audioPlayer.pause();
                            } else {
                              _audioPlayer.play();
                            }
                            isPlayin = !isPlayin;
                          });
                        },
                        icon: Icon(
                          isPlayin ? Icons.pause : Icons.play_arrow,
                          size: 40,
                          color: Colors.red,
                        ),
                      ),
                      IconButton(
                        //skip button logik
                        onPressed: () {},
                        icon: Icon(
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
      )),
    );
  }
}
