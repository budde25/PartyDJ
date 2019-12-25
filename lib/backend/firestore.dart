import 'package:cloud_firestore/cloud_firestore.dart';

import 'utils.dart';

void removeSong(String queue, String track) {
  Firestore.instance.collection(queue).document(track).delete();
}

void addSong(String queue, String name, String artist, String track) {
  Firestore.instance.collection(queue).document(getTime().toString())
      .setData({ 'name': name, 'artist': artist, 'track': track});
}

/*
void playNextSong() {
  ListTile song = songs[0];
  removeSong(queueId, song.title.toString());
  play();
}*/
