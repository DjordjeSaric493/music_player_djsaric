import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music_player_djsaric/screenz/home_scr.dart';
import 'package:music_player_djsaric/state-provider/song_provider.dart';
import 'package:provider/provider.dart';
import 'screenz/songs.dart';

Future<void> main() async {
  //background music player
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  runApp(ChangeNotifierProvider(
      create: (context) => SongProvider(), child: const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  //main
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MusicPlayer by Đ.Sarić',
      home: HomeScreen(),
    );
  }
}
