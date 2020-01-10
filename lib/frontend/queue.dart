import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'search.dart';
import '../backend/platform.dart';
import '../backend/song.dart';
import '../backend/utils.dart';
import '../backend/firestore.dart';

String queueId;
List<Song> songs;

Song currentSongClient;
Song currentSongOwner;

bool isPaused;
bool isOwner;
bool isStarted;

Function setCurrentSong;
Function setIsPlaying;

class Queue extends StatefulWidget {
  @override
  _QueueState createState() => _QueueState();

  Queue(String id, bool owner) {
    isOwner = owner;
    if (id != null) {
      queueId = id;
    } else {
      queueId = generateCode(6);
    }
    songs = new List();
    isStarted = false;
  }
}

class _QueueState extends State<Queue> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(isOwner ? Icons.close : Icons.arrow_back),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) => _exit(context),
              );
            },
          ),
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
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) => Search())),
          child: Icon(Icons.add),
          tooltip: 'add song',
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              NowPlaying(),
              Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                      stream: Firestore.instance
                          .collection(queueId)
                          .document('songs')
                          .collection('1')
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError)
                          return Center (
                            child: Text('Error: ${snapshot.error}')
                          );
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          default:
                            return ListView(
                              children: snapshot.data.documents
                                  .map((DocumentSnapshot document) {
                                // Adding to the array
                                String name = document['name'];
                                String artist = document['artist'];
                                String track = document['track'];

                                Song song = new Song(name, artist, track);
                                if (document.documentID == 'current') {
                                  currentSongClient = song;
                                } else {
                                  int id = int.parse(document.documentID);
                                  song.id = id;
                                  if (!songs.contains(song)) {
                                    songs.add(song);
                                  }
                                }

                                if (isOwner) {
                                  return ListTile(
                                    title: Text(document['name']),
                                    subtitle: Text(document['artist']),
                                    leading: Image.network(document['image']),
                                    trailing: IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () => removeSong(
                                          queueId, document.documentID),
                                    ),
                                  );
                                } else {
                                  return ListTile(
                                    title: Text(document['name']),
                                    subtitle: Text(document['artist']),
                                    leading: Image.network(document['image']),
                                  );
                                }
                              }).toList(),
                            );
                        }
                      }))
            ],
          ),
        ));

  }

  Widget _exit(BuildContext context) {
    if (isOwner) {
      return AlertDialog(
        title: Text('Close Queue'),
        content: Text('Are you sure you want to end the queue?'),
        actions: <Widget>[
          MaterialButton(
            child: Text('Yes'),
            onPressed: () => _leave(),
          ),
          MaterialButton(
            child: Text('No'),
            onPressed: () => Navigator.pop(context),
          )
        ],
      );
    } else {
      return AlertDialog(
        title: Text('Leave Queue'),
        content: Text('Are you sure you want to leave the queue?'),
        actions: <Widget>[
          MaterialButton(
            child: Text('Yes'),
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false),
          ),
          MaterialButton(
            child: Text('No'),
            onPressed: () => Navigator.pop(context),
          )
        ],
      );
    }
  }

  Future<void> _leave() async {
    Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    destroyQueue(queueId);
  }

  Widget _buildDialog(BuildContext context) {
    return AlertDialog(
        title: const Text('Room Code'),
        content: SelectableText(queueId));
  }
}

Song getNextSong() {
  Song min = songs[0];
  for (Song song in songs) {
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
    if (!isStarted && isOwner) {
      return Padding(
        padding: EdgeInsets.all(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(),
          ),
          child: ListTile(
            leading: currentSongOwner == null ? null : Image.network(currentSongOwner.imageUri),
            title: Text(
                currentSongOwner == null ? 'No song playing' : currentSongOwner.name),
            subtitle: Text(currentSongOwner == null ? '' : currentSongOwner.artist),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Start'),
                IconButton(
                  icon: Icon(Icons.play_arrow),
                  onPressed: () {
                    setState(() {
                      if (songs.length > 0) {
                        isStarted = true;
                        playNextSong();
                      }
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      );
    } else if (isOwner) {
      return Padding(
        padding: EdgeInsets.all(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(),
          ),
          child: ListTile(
            leading: currentSongOwner == null ? null : Image.network(currentSongOwner.imageUri),
            title: Text(
                currentSongOwner == null ? 'No song playing' : currentSongOwner.name),
            subtitle: Text(currentSongOwner == null ? '' : currentSongOwner.artist),
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
          ),
        ),
      );
    } else {
      return Padding(
        padding: EdgeInsets.all(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(),
          ),
          child: ListTile(
            leading: Image.network(currentSongClient.imageUri),
            title: Text(
                currentSongClient == null ? 'No song playing' : currentSongOwner.name),
            subtitle: Text(currentSongOwner == null ? '' : currentSongOwner.artist),
          ),
        ),
      );
    }
  }

  void _refresh(Song song) {
    setState(() {
      currentSongOwner = song;
      setSong(queueId, song.name, song.artist, song.uri, song.imageUri);
    });
  }

  void _playing(bool paused) {
    setState(() {
      isPaused = paused;
    });
  }
}
