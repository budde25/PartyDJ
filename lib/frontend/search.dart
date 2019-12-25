
import 'package:flutter/material.dart';
import 'package:spotify_queue/frontend/queue.dart';
import '../backend/spotify.dart';
import '../backend/firestore.dart' as fs;
import '../backend/platform.dart';
import '../backend/song.dart';


class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

String token;
String lastSearch;

class _SearchState extends State<Search> {

  final TextEditingController searchController = new TextEditingController();
  List<Song> results = new List();

  @override
  void initState() {
    _loadToken();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            new TextField(
              controller: searchController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Search for songs'
              ),
              onSubmitted: (search) => _search(search),
              autocorrect: true,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: results.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text (results[index].name),
                      subtitle: Text (results[index].artist),
                      onTap: () { fs.addSong(queueId, results[index].name, results[index].artist, results[index].uri);
                        },
                    );
                  }),
            )
          ],
        ),
      )
    );
  }

  _search(String query) async {
    if (query == null || query == '' || query == lastSearch)
      return;

    lastSearch = query;
    results = new List();

    Map search = await getSearchResults(query, token);
    List list = search['items'];

    setState(() {
      for (int i = 0; i < list.length; i++) {
        String name = list[i]['name'];
        String artist = list[i]['artists'][0]['name'];
        String uri = list[i]['uri'];

        results.add(new Song(name, artist, uri));
      }
    });

  }

  void _loadToken() async {
    token = await getToken();
  }

}