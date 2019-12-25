import 'package:flutter/services.dart';

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
  print("gotem" + call.method);
  final String argument = call.arguments;
  if (call.method == "trackEnd"){
    //playNextSong();
    print('Song Ended');
  } else {
    print('Error unknown: ${call.method}');
  }
  return null;
}
