import 'package:flutter/services.dart';
import 'package:spotify_queue/backend/song.dart';
import 'package:spotify_queue/frontend/queue.dart';

import '../backend/firestore.dart';

const MethodChannel platform = MethodChannel('dev.budde.spotify_queue');

Future<String> getToken() async {
  String token;
  try {
    token = await platform.invokeMethod('token');
  } on PlatformException catch (e) {
    print(e.message);
  }
  print(token);
  return token;
}

void playSong(String track) async {
  try {
    platform.invokeMethod('playSong', <String, String> {'track':track});
  } on PlatformException catch (e) {
    print(e.message);
  }
}

void play() async {
  try {
    platform.invokeMethod('play');
  } on PlatformException catch (e) {
    print(e.message);
  }
}

void pause() async {
  try {
    platform.invokeMethod('pause');
  } on PlatformException catch (e) {
    print(e.message);
  }
}

void skip() async {
  try {
    platform.invokeMethod('skip');
  } on PlatformException catch (e) {
    print(e.message);
  }
}

Future<void> methodCallHandler(MethodCall call) {
  try {
    switch (call.method) {
      case "trackEnd":
        playNextSong();
        print('Song Ended');
        break;
      case "song":
        List<dynamic> args = call.arguments;
        setCurrentSong(
            new Song(
                args[0].toString(), args[1].toString(), args[2].toString()));
        break;
      case "isPaused":
        bool isPaused = call.arguments;
        setIsPlaying(isPaused);
        break;
      default:
        print('Error: unexpected methodcall');
    }
  } catch (e) {
    print(e);
  }
  return null;
}
