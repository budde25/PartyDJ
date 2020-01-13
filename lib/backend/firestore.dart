/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotify_queue/backend/platform.dart';
import 'package:spotify_queue/backend/song.dart';
import '../frontend/queue.dart';

import 'utils.dart';

void removeSong(String queue, String track) {
  Firestore.instance
      .collection(queue)
      .document('songs')
      .collection('1')
      .document(track)
      .delete();
}

void addSong(
    String queue, String name, String artist, String track, String image) {
  Firestore.instance
      .collection(queue)
      .document('songs')
      .collection('1')
      .document(getTime().toString())
      .setData(
          {'name': name, 'artist': artist, 'track': track, 'image': image});
}

void setSong(String queue, String name, String artist, String track, String image){
  Firestore.instance
      .collection(queue)
      .document('songs')
      .collection('1')
      .document('current')
      .setData(
      {'name': name, 'artist': artist, 'track': track, 'image': image});
}

String createQueue(String username) {
  String code = generateCode(6);
  Firestore.instance
      .collection(code)
      .document('manifest')
      .setData({'enabled': true, 'owner': username});
  return code;
}

void destroyQueue(String queue) {
  Firestore.instance
      .collection(queue)
      .document('manifest')
      .setData({'enabled': false});
}

Future<String> getOwner(String queue) async {
  try {
    Map document;
    await Firestore.instance
        .collection(queue)
        .document('manifest')
        .get()
        .then((DocumentSnapshot ds) {
      document = ds.data;
    });
    bool enabled = document['enabled'];
    String owner = document['owner'];
    return enabled ? owner : null;
  } catch (e) {
    return null;
  }
}

void playNextSong() {
  Song song = getNextSong();
  playSong(song.uri);
  removeSong(queueId, song.id.toString());
  songs.remove(song);
}
*/
