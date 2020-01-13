import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              MaterialButton(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 42),
                child: Text(
                  'Create Queue',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[200],
                  ),
                ),
                onPressed: () {},
                color: Colors.green[800],
              ),
              SizedBox(height: 32),
              MaterialButton(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 42),
                child: Text(
                  'Join Queue',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[200],
                  ),
                ),
                onPressed: () {},
                color: Colors.green[800],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
