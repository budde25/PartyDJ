import 'dart:convert';

import 'package:http/http.dart';

Client client = new Client();

Future<Map<String, dynamic>> getSearchResults(String query, String token) async {
  Map<String, dynamic> map;
  return client.get('https://api.spotify.com/v1/search?q=' + query + '&type=track', headers: authHeaders(token))
      .then<Map<String, dynamic>>((Response response) {
    if (response.body != '' && response.statusCode == 200) {
      map = json.decode(response.body);
    } else {
      throw 'Invalid Response';
    }
    return map;
  }).catchError((Object error) => <String, dynamic>{'Search error': 'Unable to retrieve results'});
}

Map<String, String> authHeaders(String token) {
  return <String, String> {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token'
  };
}