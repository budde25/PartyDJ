import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'search.dart';
import '../backend/platform.dart';
import '../backend/song.dart';
import '../backend/utils.dart';
import '../backend/firestore.dart';

String queueId;
List<Song> songs;

Song currentSong;
bool isPaused;

Function setCurrentSong;
Function setIsPlaying;

class Queue extends StatefulWidget {
  @override
  _QueueState createState() => _QueueState();

  Queue(String id) {
    if (id != null) {
      queueId = id;
    } else {
      queueId = generateCode(6);
    }
    songs = new List();
  }
}

class _QueueState extends State<Queue> {
  @override
  void initState() {
    super.initState();
    platform.setMethodCallHandler(methodCallHandler);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Song Queue'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.share),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) => _buildDialog(context),
                );
              },
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (BuildContext context) => Search())),
          child: Icon(Icons.add),
          tooltip: 'search',
        ),
        body: Center(
          child: Column(
            children: <Widget> [
              NowPlaying(),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                    stream: Firestore.instance.collection(queueId).snapshots(),
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError)
                        return new Text('Error: ${snapshot.error}');
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return Text('Retriving Queue');
                        default:
                          return ListView(
                            children: snapshot.data.documents.map((DocumentSnapshot document) {
                              // Adding to the array
                              String name = document['name'];
                              String artist = document['artist'];
                              String track = document['track'];
                              int id = int.parse(document.documentID);
                              Song song = new Song(name, artist, track);
                              song.id = id;
                              if (!songs.contains(song)) {
                                songs.add(song);
                              }

                              return ListTile(
                                title: Text(document['name']),
                                subtitle: Text(document['artist']),
                                onTap: () => playSong(document['track']),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () => removeSong(queueId, document.documentID),
                                ),
                              );
                            }).toList(),
                      );
                      }
                    }
                )
              )
            ],
          ),
        )
    );
  }

  Widget _buildDialog(BuildContext context) {
    return new AlertDialog(
      title: const Text('Room Code'),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(queueId)
        ],
      ),
      actions: <Widget>[
      ],
    );
  }
}

Song getNextSong() {
  Song min = songs[0];
  for (Song song in songs){
    if (song.id < min.id) {
      min = song;
    }
  }
  return min;
}

class NowPlaying extends StatefulWidget {
  @override
  _NowPlayingState createState() => _NowPlayingState();
}

class _NowPlayingState extends State<NowPlaying> {

  @override
  void initState() {
    super.initState();
    setCurrentSong = _refresh;
    setIsPlaying = _playing;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(currentSong == null ? 'No song playing' : currentSong.name),
      subtitle: Text(currentSong == null ? '' : currentSong.artist),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            icon: Icon(isPaused == true ? Icons.play_arrow : Icons.pause),
            onPressed: () => isPaused == true ? play() : pause(),
          ),
          IconButton(
            icon: Icon(Icons.skip_next),
            onPressed: () => skip(),
          )
        ],
      ),
    );
  }

  void _refresh(Song song) {
    setState(() {
      currentSong = song;
    });
  }

  void _playing(bool paused) {
    setState(() {
      isPaused = paused;
    });
  }
}
