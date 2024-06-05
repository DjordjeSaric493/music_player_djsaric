import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_player_djsaric/screenz/albums_page.dart';
import 'album_songs_page.dart';
import 'songs.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    //Navigate between two pages, see songs.dart and albums_page.dart
    Songs(),
    AlbumsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      //BottomNavBar classic
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.music_note),
            label: 'Songs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music),
            label: 'Albums',
          ),
        ],
      ),
    );
  }
}
