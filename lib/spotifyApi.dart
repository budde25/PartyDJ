import 'dart:convert';

import 'package:http/http.dart';

Client client = new Client();

Future<Map<String, dynamic>> getSearchResults(String query, String token) async {

  // Allows query with spaces
  if (query.contains(' ')){
    query.replaceAll(' ', '%20');
  }

  Map<String, dynamic> tracks;
  return client.get('https://api.spotify.com/v1/search?q=' + query + '&type=track&market=US', headers: authHeaders(token))
      .then<Map<String, dynamic>>((Response response) {
    if (response.body != '' && response.statusCode == 200) {
      Map<String, dynamic> map = json.decode(response.body);
      tracks = map['tracks'];
    } else {
      throw 'Invalid Response';
    }
    return tracks;
  }).catchError((Object error) => <String, dynamic>{'Search error': 'Unable to retrieve results \n $error'});
}

Map<String, String> authHeaders(String token) {
  return <String, String> {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token'
  };
}