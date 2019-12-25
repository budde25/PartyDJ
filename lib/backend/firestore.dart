import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotify_queue/backend/platform.dart';
import 'package:spotify_queue/backend/song.dart';
import '../frontend/queue.dart';

import 'utils.dart';

void removeSong(String queue, String track) {
  Firestore.instance.collection(queue).document(track).delete();
}

void addSong(String queue, String name, String artist, String track) {
  Firestore.instance.collection(queue).document(getTime().toString())
      .setData({ 'name': name, 'artist': artist, 'track': track});
}

void playNextSong() {
  Song song = getNextSong();
  play(song.uri);
  removeSong(queueId, song.id.toString());
  songs.remove(song);
}
