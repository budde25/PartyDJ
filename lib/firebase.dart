import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

void removeSong(String queue, String track) {
  Firestore.instance.collection(queue).document(track).delete();
}

void addSong(String queue, String name, String artist, String track) {
  Firestore.instance.collection(queue).document(track);
  Firestore.instance.collection(queue).document(_getTime().toString())
      .setData({ 'name': name, 'artist': artist, 'track': track});
}

String generateRoom(int length) {
  List<String> available = ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z',
    'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
    '0','1','2','3','4','5','6','7','8','9'];
  Random random = new Random();

  String room = "";
  for (int i = 0; i < length; i++){
    room += available[random.nextInt(available.length)];
  }
  return room;
}

int _getTime() {
  return DateTime.now().millisecondsSinceEpoch;
}