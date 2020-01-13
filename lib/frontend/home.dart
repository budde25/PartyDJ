import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spotify_queue/backend/storageUtil.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      resizeToAvoidBottomInset: false,
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
                onPressed: () {
                  final String code = 'aaaaaa';
                  StorageUtil.putString('queue', code);
                  Navigator.pushReplacementNamed(context, '/queue', arguments: {
                    'isOwner': true,
                    'queue': code,
                  });
                },
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
                onPressed: () {
                  showModalBottomSheet(context: context, builder: (BuildContext context) {
                    return JoinForm();
                  });
                },
                color: Colors.green[800],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class JoinForm extends StatelessWidget {
  const JoinForm({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController code = new TextEditingController();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.green,
      body: Center(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Form(
            child: Column(
              children: <Widget> [
                Text(
                  'Enter Room Code',
                  style: TextStyle(
                    fontSize: 36,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        controller: code,
                        maxLength: 6,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          fillColor: Colors.green[800],
                          filled: true,
                          contentPadding: EdgeInsets.all(12),
                          isDense: true,
                        ),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Padding(
                      padding: EdgeInsets.only(bottom: 22.0),
                      child: MaterialButton(
                        color: Colors.green[800],
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Text(
                              'Submit',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/queue', arguments: {
                            'isOwner': false,
                            'queue': code.text,
                          });
                        },
                      ),
                    )
                  ],
                )
                ]
            ),
          ),
        ),
      ),
    );
  }
}
