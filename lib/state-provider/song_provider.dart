import 'package:flutter/material.dart';

//provider for song model

class SongProvider with ChangeNotifier {
  int id = 0;

  int get _id => id;

  void setId(int id) {
    id = _id;
  }
}
