import 'package:flutter/material.dart';
import 'package:spotify_queue/backend/SharedPreferences.dart';
import 'package:spotify_queue/backend/firestore.dart';
import 'package:spotify_queue/frontend/queue.dart';

import 'backend/platform.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spotify Queue',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => new MyHomePage(),
      },
      initialRoute: '/',
    );
  }
}

class MyHomePage extends StatefulWidget {

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".


  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    platform.setMethodCallHandler(methodCallHandler);
    startSpotify();
    startAuth();
  }

  static bool loading;
  static bool error;

  @override
  Widget build(BuildContext context) {

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('Spotify Queue'),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            MaterialButton(
              child: Text('Make queue'),
              onPressed: () => _makeQueue(),
            ),
            MaterialButton(
              child: Text('Join queue'),
              onPressed: () => showDialog(
                context: context,
                builder: (context) {
                  loading = false;
                  error = false;
                  return StatefulBuilder(
                    builder: (context, setState) {
                      TextEditingController code = new TextEditingController();
                      return SimpleDialog(
                        title: !error ? Text('Enter Room Code') : Text('Error, Invalid Room Code'),
                        shape: BeveledRectangleBorder(),
                        children: <Widget>[
                          TextField(
                            decoration: InputDecoration(
                                border: OutlineInputBorder(), labelText: 'Room Code'),
                            controller: code,
                            autocorrect: false,
                            maxLength: 6,
                          ),
                          MaterialButton(
                            onPressed: () {
                              setState(() {
                                error = false;
                                joinQueue(code.text);
                              });
                            },
                            textColor: Theme.of(context).primaryColor,
                            child: const Text('Submit'),
                          ),
                        ],
                      );
                    }
                  );
                }
              )
            ),
          ],
        ),
      ),
    );
  }
  Future<void> joinQueue(String code) async {
    setState(() {
      loading = true;
    });

    String username = await getUsername();
    String owner = await getOwner(code);

    // room is not enabled
    if (owner == null) {
      setState(() {
        error = true;
        print('error');
        loading = false;
      });
      return;
    }

    if (username == owner) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => Queue(code, true)),
              (_) => false);
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => Queue(code, false)));
    }
  }

  Future<void> _makeQueue() async {
    String username = await getUsername();
    String code = createQueue(username);
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) => Queue(code, true)),
            (_) => false);
  }
}