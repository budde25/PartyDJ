import 'package:flutter/services.dart';
import 'package:spotify_queue/backend/SharedPreferences.dart';
import 'package:spotify_queue/backend/song.dart';
import 'package:spotify_queue/backend/spotify.dart';
import 'package:spotify_queue/frontend/queue.dart';

import '../backend/firestore.dart';

const MethodChannel platform = MethodChannel('dev.budde.spotify_queue');

String username;
String token;

/*Future<String> getToken() async {
  String token;
  try {
    token = await platform.invokeMethod('token');
  } on PlatformException catch (e) {
    print(e.message);
  }
  return token;
}*/

void login() async {
  try {
    platform.invokeMethod('login');
  } on PlatformException catch (e) {
    print(e.message);
  }
}

void startSpotify() async {
  try {
    platform.invokeMethod('spotify');
  } on PlatformException catch (e) {
    print(e.message);
  }
}

void playSong(String track) async {
  try {
    platform.invokeMethod('playSong', <String, String>{'track': track});
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

// TODO fix unexpected method calls
Future<void> methodCallHandler(MethodCall call) {
  try {
    switch (call.method) {
      case "trackEnd":
        playNextSong();
        print('Song Ended');
        break;
      case "song":
        List<dynamic> args = call.arguments;
        setCurrentSong(new Song(
            args[0].toString(), args[1].toString(), args[2].toString()));
        break;
      case "isPaused":
        bool isPaused = call.arguments;
        setIsPlaying(isPaused);
        break;
      case "authorized":
        setToken(call.arguments);
        authorized();
        break;
      default:
        print('Error: unexpected methodcall');
    }
  } catch (e) {
    print(e);
  }
  return null;
}

void startAuth() async {
  bool isToken = await tokenExists();
  if (!isToken) {
    login();
  } else {
    authorized();
  }
}

void authorized() async {
  token = await getToken();

  bool isUsername = await usernameExists();
  if (!isUsername) {
    Map<String, dynamic> userData = await getUserData(token);
    String username = userData['display_name'];
    if (username != "Unable to retrieve username" && username != null) {
      setUsername(username);
    }
  }
  print(username);
}
