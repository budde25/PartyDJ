import 'package:flutter/material.dart';

import 'package:spotify_queue/frontend/loading.dart';
import 'package:spotify_queue/frontend/home.dart';
import 'package:spotify_queue/frontend/queue.dart';
import 'package:spotify_queue/frontend/search.dart';
import 'package:spotify_queue/frontend/qr.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.green,
        brightness: Brightness.dark,
      ),
      initialRoute: '/',
      routes: <String, WidgetBuilder> {
        '/': (BuildContext context) => Loading(),
        '/home': (BuildContext context) => Home(),
        '/queue': (BuildContext context) => Queue(),
        '/search': (BuildContext context) => Search(),
        '/qr': (BuildContext context) => QRViewer(),
      },
    );
  }
}