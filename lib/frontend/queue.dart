import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:spotify_queue/backend/functions.dart';
import 'package:spotify_queue/backend/storageUtil.dart';

class Queue extends StatefulWidget {
  @override
  _QueueState createState() => _QueueState();
}

class _QueueState extends State<Queue> {

  String queue;
  bool isOwner;

  @override
  Widget build(BuildContext context) {

    Map args = ModalRoute.of(context).settings.arguments;
    isOwner = args['isOwner'];
    queue = args['queue'];

    return Scaffold(
      backgroundColor: Colors.green,
      appBar: AppBar(
        backgroundColor: Colors.green[800],
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
        backgroundColor: Colors.green[800],
        onPressed: () => Navigator.pushNamed(context, '/search', arguments: {
          'queue': queue,
        }),
        child: Icon(Icons.add),
        tooltip: 'Add Song',
      ),
      body: Center(
          child: Column(
            children: <Widget>[
              Expanded(
                child: StreamBuilder<DocumentSnapshot>(
                  stream: Firestore.instance.collection('rooms').document(queue).snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (!snapshot.hasData) return const Text('Loading...');
                  final int songCount = snapshot.data['songs'].length;
                  return ListView.builder(
                    itemCount: songCount,
                    itemBuilder: (_, int index) {
                      final List<dynamic> songs = snapshot.data['songs'];
                      return ListTile(
                        leading: Image.network(songs[index]['imageUrl']),
                        title: Text(songs[index]['name']),
                        subtitle: Text(songs[index]['artist']),
                      );
                    }
                  );
                }
                ),
              )
              ],
          ),
      ),
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
        if (await Functions.closeRoom(queue)) {
          StorageUtil.putString('queue', '');
          Navigator.pushReplacementNamed(context, '/home');
        }
      };
    } else {
      title = 'Leave Queue';
      content = 'Are you sure you want to leave the queue?';
      onPressed = () {
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
      backgroundColor: Colors.green,
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
                  )
                  // TODO add QRCode
                ]
            ),
          ),
        ),
      ),
    );
  }
}

