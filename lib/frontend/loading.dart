import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:spotify_queue/backend/functions.dart';
import 'package:spotify_queue/backend/spotify.dart';
import 'package:spotify_queue/backend/storageUtil.dart';

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {

  void spotifyAuth() async {
    // initiate the shared prefs instance
    await StorageUtil.getInstance();
    // initiate the spotify tokens etc
    await Spotify.init();

    // check if user belongs in a queue
    String queue = StorageUtil.getString('queue');
    if (queue != '') {
      Navigator.pushReplacementNamed(context, '/queue', arguments: {
        'isOwner': true,
        'queue': queue,
      });
      return;
    }

    // After that finishes we can load the next page
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  void initState() {
    super.initState();
    spotifyAuth();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: SpinKitDoubleBounce(
          color: Colors.white,
          size: 80.0,
        ),
      )
    );
  }
}
