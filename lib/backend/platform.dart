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

void play(String track) async {
  try {
    platform.invokeMethod('play', <String, String> {'track':track});
  } on PlatformException catch (e) {
    print(e.message);
  }
}

Future<void> methodCallHandler(MethodCall call) {
  switch (call.method) {
    case "trackEnd":
      playNextSong();
      print('Song Ended');
      break;
    case "song":
      List<dynamic> args = call.arguments;
      callback(
          new Song(args[0].toString(), args[1].toString(), args[2].toString()));
      break;
    default:
      print('Error: unexpected methodcall');
  }
  return null;
}
