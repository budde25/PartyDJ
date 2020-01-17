import 'package:flutter/material.dart';
import 'package:spotify_queue/backend/functions.dart';
import 'package:spotify_queue/backend/song.dart';
import 'package:spotify_queue/backend/spotify.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {

  String queue;
  String lastSearch;
  List<Song> results = new List();
  bool loading = false;

  @override
  Widget build(BuildContext context) {

    Map args = ModalRoute.of(context).settings.arguments;
    queue = args['queue'];

    return Scaffold(
      appBar: AppBar(
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
                child: !loading ? ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        title: Text(results[index].name),
                        subtitle: Text(results[index].artist),
                        onTap: () {
                          Functions.addSong(queue, results[index].uri);
                        },
                        leading: Image.network(results[index].albumUrl),
                      );
                    }) : Center(
                  child: SpinKitDoubleBounce(
                    color: Colors.green,
                    size: 40.0,
                  ),
                ),
              )
            ],
          ),
        ));
  }

  _search(String query) async {
    // TODO only if not already in queue
    if (query == null || query == '' || query == lastSearch) return;

    setState(() {
      loading = true;
    });

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

        Song song = new Song(name, artist, uri, image);

        results.add(song);
      }
      loading = false;
    });
  }
}
