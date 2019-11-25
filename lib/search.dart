import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'spotifyApi.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class Song {
  String name;
  String artist;
  String track;

  Song(String name, String artist, String track) {
    this.name = name;
    this.artist = artist;
    this.track = track;
  }
}

class _SearchState extends State<Search> {

  TextEditingController search = new TextEditingController();
  List<Song> results = new List();

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Column(
          children: <Widget>[
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Search for songs'
              ),
              onSubmitted: _update(search.text),
              autocorrect: true,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: results.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text (results[index].name),
                      subtitle: Text (results[index].artist),
                    );
                  }),
            )
          ],
        ),
      )
    );
  }

  _update(String text) {
    _search(text);
  }

  Future<void> _search(String query) async {
    String token = await _getToken();
    Map search = await getSearchResults(query, token);
    for (int i = 0; i < search.length; i++) {
      results.add(
          new Song(search['items']['name'],
              search['items']['artist'], search['items']['uri']));
    }
  }
  
  Future<String> _getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }


}
