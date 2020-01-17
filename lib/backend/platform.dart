import 'package:flutter/services.dart';
import 'package:spotify_queue/frontend/queue.dart';
import 'song.dart';

class Platform {
  static final MethodChannel methodChannel = MethodChannel('dev.budde.spotify_queue');

  static Future<void> connectSpotify() async {
    try {
      methodChannel.invokeMethod('connect');
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  static Future<void> play() async {
    try {
      methodChannel.invokeMethod('play');
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  static Future<void> pause() async {
    try {
      methodChannel.invokeMethod('pause');
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  static Future<void> skipNext() async {
    try {
      methodChannel.invokeMethod('skip_next');
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  static Future<void> skipPrevious() async {
    try {
      methodChannel.invokeMethod('skip_previous');
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  static Future<void> playItem(String uri) async {
    try {
      methodChannel.invokeMethod('play_song', <String, String>{'track': uri});
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  static Future<void> methodCallHandler(MethodCall call) {
    try {
      switch (call.method) {
        case "song":
          List<dynamic> args = call.arguments;
          String imageUrl = 'https://i.scdn.co/image/' + (args[3].split(':')[2]);
          Song song = new Song(args[0], args[1], args[2], imageUrl);
          setCurrentSong(song);
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

}