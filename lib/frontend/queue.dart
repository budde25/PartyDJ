import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:spotify_queue/backend/functions.dart';
import 'package:spotify_queue/backend/storageUtil.dart';
import 'package:spotify_queue/backend/platform.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:spotify_queue/backend/song.dart';

class Queue extends StatefulWidget {
  @override
  _QueueState createState() => _QueueState();
}

class _QueueState extends State<Queue> with WidgetsBindingObserver {

  String queue;
  bool isOwner;
  Song currentSongClient;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    isOwner = StorageUtil.getString('is_owner') == 'true' ? true : false;

    if (isOwner) {
      // sets the method call handler
      Platform.methodChannel.setMethodCallHandler(Platform.methodCallHandler);

      // connect spotify sdk
      Platform.connectSpotify();
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      Platform.connectSpotify();
    }
  }

  @override
  Widget build(BuildContext context) {

    Map args = ModalRoute.of(context).settings.arguments;
    queue = args['queue'];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: Icon(isOwner ? Icons.close : Icons.arrow_back),
          onPressed: () {
            showDialog(
              context: context, builder: (BuildContext context) => _exit(context),
            );
          },
        ),
        title: Text('Song Queue'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) => share(context),
              );
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/search', arguments: {
          'queue': queue,
        }),
        child: Icon(Icons.add),
        tooltip: 'Add Song',
      ),
      body: Center(
          child: Column(
            children: <Widget>[
              NowPlaying(),
              Expanded(
                child: buildStreamBuilder(),
              )
              ],
          ),
      ),
    );
  }

  StreamBuilder<DocumentSnapshot> buildStreamBuilder() {
    return StreamBuilder<DocumentSnapshot>(
                stream: Firestore.instance.collection('rooms').document(queue).snapshots(),
                builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.hasError) return Text('Error');
                if (!snapshot.hasData ) return Text('No items');
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Center(
                      child: SpinKitDoubleBounce(
                          color: Colors.green,
                          size: 80.0,
                      )
                    );
                  default:

                    // should be not needed but stops the errors
                    if (snapshot.data == null) {
                      return Center(
                          child: SpinKitDoubleBounce(
                            color: Colors.green,
                            size: 80.0,
                          )
                      );
                    }

                    // parse current song
                    Map current = snapshot.data['currentSong'];
                    currentSongClient = new Song(current['name'], current['artist'], current['uri'], current['imageUrl']);

                    final int songCount = snapshot.data['songs'].length;
                    return ListView.builder(
                        itemCount: songCount,
                        itemBuilder: (_, int index) {
                          final List<dynamic> songs = snapshot.data['songs'];
                          if (songs[index]['uri'] == currentSongClient.uri) {
                            return Container(
                              decoration: BoxDecoration(color: Colors.green),
                              child: ListTile(
                                  leading: Image.network(songs[index]['imageUrl']),
                                  title: Text(songs[index]['name']),
                                  subtitle: Text(songs[index]['artist']),
                              ),
                            );
                          } else {
                            return ListTile(
                              leading: Image.network(songs[index]['imageUrl']),
                              title: Text(songs[index]['name']),
                              subtitle: Text(songs[index]['artist']),
                            );
                          }
                        }
                    );
                }
              }
              );
  }

Widget _exit(BuildContext context) {
    String title;
    String content;
    Function onPressed;

    if (isOwner) {
      title = 'Close Queue';
      content = 'Are you sure you want to end the queue?';
      onPressed = () async {

        // Hopefully function finishes otherwise we are left with a floating song in database
        Navigator.pushReplacementNamed(context, '/home');
        StorageUtil.putString('queue', '');
        StorageUtil.putString('is_owner', '');
        Functions.closeRoom(queue);

      };
    } else {
      title = 'Leave Queue';
      content = 'Are you sure you want to leave the queue?';
      onPressed = () {
        StorageUtil.putString('is_owner', '');
        Navigator.pushReplacementNamed(context, '/home');
      };
    }

    return AlertDialog(
      title: Text(title),
      content: Text(content),
        actions: <Widget>[
          MaterialButton(
            child: Text('No'),
            onPressed: () => Navigator.pop(context),
          ),
          MaterialButton(
            child: Text('Yes'),
            onPressed: onPressed,
          ),
        ],
      );
    }

  Widget share(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Form(
            child: Column(
                children: <Widget> [
                  Text(
                    'Room Code',
                    style: TextStyle(
                      fontSize: 36,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  SelectableText(
                    queue,
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.white
                    ),
                  ),
                  SizedBox(height: 30),
                  Expanded(
                    child: QrImage(
                      foregroundColor: Colors.green,
                      data: queue,
                      version: QrVersions.auto,
                      size: 250,
                    ),
                  ),
                  SizedBox(height: 30),
                ]
            ),
          ),
        ),
      ),
    );
  }
}

Function setCurrentSong;
Function setIsPlaying;

class NowPlaying extends StatefulWidget {
  @override
  _NowPlayingState createState() => _NowPlayingState();
}

class _NowPlayingState extends State<NowPlaying> {

  bool isOwner;
  bool isPaused;
  bool started;

  @override
  void initState() {
    super.initState();
    setCurrentSong = _refresh;
    setIsPlaying = _playing;
    isOwner = StorageUtil.getString('is_owner')  == 'true' ? true : false;
    isPaused = true;
    started = false;
  }

  Song currentSongOwner;
  Song currentSongClient;

  @override
  Widget build(BuildContext context) {

    if (!isOwner) {
      return SizedBox(height: 10,);
    }

      return Column(
        children: <Widget>[
          SizedBox(height: 20,),
          buildListTile(),
          Text(
            'Queue',
            style: TextStyle(
              fontSize: 24,
            ),
          ),
          SizedBox(height: 10,),
        ],
      );

  }

  ListTile buildListTile() {
      return ListTile(
          leading: currentSongOwner == null ? null : Image.network(currentSongOwner.albumUrl),
          title: Text(currentSongOwner == null ? 'No song playing' : currentSongOwner.name),
          subtitle: Text(currentSongOwner == null ? '' : currentSongOwner.artist),
          trailing: buildRow(),
      );
  }

  Row buildRow() {
    if (!started) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.play_arrow),
            onPressed: () {
              setState(() {
                String playlistId = StorageUtil.getString('playlist_id');
                Platform.playItem('spotify:playlist:$playlistId');
                started = true;
              });
            },
          ),
        ],
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.skip_previous),
            onPressed: () => Platform.skipPrevious(),
          ),
          IconButton(
            icon: Icon(isPaused == true ? Icons.play_arrow : Icons.pause),
            onPressed: () { isPaused ? Platform.play() : Platform.pause(); },
          ),
          IconButton(
            icon: Icon(Icons.skip_next),
            onPressed: () => Platform.skipNext(),
          )
        ],
      );
    }
  }


  void _refresh(Song song) {
    setState(() {
      if (song != currentSongOwner && song != null) {
        currentSongOwner = song;
        firestoreSetCurrentSong(song);
      }
    });
  }

  void _playing(bool paused) {
    setState(() {
      isPaused = paused;
    });
  }

  Future<void> firestoreSetCurrentSong(Song song) async {
    String queue = StorageUtil.getString('queue');
    Firestore.instance.collection('rooms').document(queue).updateData({
      'currentSong': {
        'name': song.name,
        'artist': song.artist,
        'uri': song.uri,
        'imageUrl': song.albumUrl,
      }
    });
  }
}