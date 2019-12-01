import 'dart:collection' as prefix0;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'search.dart';
import 'platform.dart';

class Queue extends StatefulWidget {
  @override
  _QueueState createState() => _QueueState();
}

String queueId = '1';
prefix0.Queue<Song> songs = new prefix0.Queue();

class _QueueState extends State<Queue> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Song Queue'),
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
            children: <Widget>[
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                    stream: Firestore.instance.collection(queueId).snapshots(),
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError)
                        return new Text('Error: ${snapshot.error}');
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return Text('Retriving Queue');
                        default: return ListView(
                            children: snapshot.data.documents.map((DocumentSnapshot document) {
                              return ListTile (
                                title: Text(document['name']),
                                subtitle: Text(document['artist']),
                                onTap: () {play(document['track']);},
                                trailing: IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () => _removeSong(document['track']),
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

  _removeSong(String track) {
    Firestore.instance.collection(queueId).document(track).delete();
  }
}
