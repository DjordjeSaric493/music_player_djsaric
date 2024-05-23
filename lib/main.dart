import 'package:flutter/material.dart';
import '../widgets/songs.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  //main
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'MusicPlayer by Đ.Sarić',
      home: Songs(),
    );
  }
}
