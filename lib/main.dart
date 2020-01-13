import 'package:flutter/material.dart';

import 'package:spotify_queue/frontend/loading.dart';
import 'package:spotify_queue/frontend/home.dart';
import 'package:spotify_queue/frontend/queue.dart';
import 'package:spotify_queue/frontend/search.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: <String, WidgetBuilder> {
        '/': (BuildContext context) => Loading(),
        '/home': (BuildContext context) => Home(),
        '/queue': (BuildContext context) => Queue(),
        '/search': (BuildContext context) => Search(),
      },
    );
  }
}