import 'package:flutter/material.dart';
import 'package:spotify_queue/backend/song.dart';
import 'package:spotify_queue/backend/spotify.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {

  String lastSearch;
  List<Song> results = new List();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.green,
      appBar: AppBar(
        backgroundColor: Colors.green[800],
        centerTitle: true,
          title: Text('Search'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(12),
                child: TextField(
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Search for songs'),
                  onSubmitted: (search) => _search(search),
                  autocorrect: true,
                ),
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        title: Text(results[index].name),
                        subtitle: Text(results[index].artist),
                        onTap: () {

                        },
                        leading: Image.network(results[index].imageUri),
                      );
                    }),
              )
            ],
          ),
        ));
  }

  _search(String query) async {
    if (query == null || query == '' || query == lastSearch) return;

    lastSearch = query;
    results = new List();

    Map search = await Spotify.getSearchResults(query);

    List<dynamic> list = search['tracks']['items'];

    setState(() {
      for (int i = 0; i < list.length; i++) {
        String name = list[i]['name'];
        String artist = list[i]['artists'][0]['name'];
        String uri = list[i]['uri'];
        String image = list[i]['album']['images'][2]['url'];

        Song song = new Song(name, artist, uri);
        song.imageUri = image;

        results.add(song);
      }
    });
  }
}
