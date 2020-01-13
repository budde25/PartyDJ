import 'dart:convert';
import 'package:spotify_queue/backend/storageUtil.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:http/http.dart';

class Spotify {
  static final String _clientID = '12e51e7fd567478db5db871585124355';
  static final String _clientSecret = '';
  static final String _callbackUrl = 'dev.budde.spotifyqueue';

  static final String _scope = 'user-read-private';

  static Future<void> init() async {
    // if this is the first login
    while (StorageUtil.getString('access_token') == '' ||
        StorageUtil.getString('refresh_token') == '') {
      await _requestAccessToken();
    }
    while (StorageUtil.getString('username') == '') {
      await _requestUsername();
    }

    // Check if the token has expired and reAuth
    _checkTokenExpiration();
  }

  static Future<void> _checkTokenExpiration() async {
    // the amount of of milliseconds of error to give for refresh, 30000: 30 seconds
    final int millisecondsOfError = 30000;
    int timeOfExpiration = StorageUtil.getInt('expiration') - millisecondsOfError;

    if (DateTime.now().millisecondsSinceEpoch > timeOfExpiration) {
      return _requestTokenUpdate();
    }
  }


  static String _constructUrl() {
    return Uri.https('accounts.spotify.com', '/authorize', {
      'response_type': 'code',
      'client_id': _clientID,
      'redirect_uri': '$_callbackUrl://callback',
      'scope': _scope,
    }).toString();
  }

  static String _constructAuth() {
    return base64Encode(utf8.encode(_clientID + ':' + _clientSecret));
  }

  static Future<String> _requestAuthCode() async {
    final result = await FlutterWebAuth.authenticate(
        url: _constructUrl(), callbackUrlScheme: _callbackUrl);
    return Uri
        .parse(result)
        .queryParameters['code'];
  }

  /// Sets the initial access token, refresh token
  static Future<void> _requestAccessToken() async {
    final String authCode = await _requestAuthCode();
    final Response response = await post(
        'https://accounts.spotify.com/api/token',
        headers: {
          'Authorization': 'Basic ${_constructAuth()}',
        },
        body: {
          'client_id': _clientID,
          'redirect_uri': '$_callbackUrl://callback',
          'grant_type': 'authorization_code',
          'code': authCode,
        }
    );

    final Map body = jsonDecode(response.body);

    String accessToken = body['access_token'];
    String refreshToken = body['refresh_token'];

    // The number of milliseconds until the auth token expires, default: 3,600,000
    int millisecondsToExpiration = int.parse(body['expires_in']) * 1000;
    int millisecondsSinceEpoch = DateTime.now().millisecondsSinceEpoch;

    int timeOfExpiration = millisecondsSinceEpoch + millisecondsToExpiration;

    StorageUtil.putInt('expiration', timeOfExpiration);
    StorageUtil.putString('access_token', accessToken);
    StorageUtil.putString('refresh_token', refreshToken);
  }

  /// Updates the users access token using the refresh token
  static Future<void> _requestTokenUpdate() async {
    final Response response = await post(
        'https://accounts.spotify.com/api/token',
        headers: {
          'Authorization': 'Basic ${_constructAuth()}',
        },
        body: {
          'grant_type': 'refresh_token',
          'refresh_token': StorageUtil.getString('refresh_token'),
        }
    );
    final Map body = jsonDecode(response.body);

    String accessToken = body['expires_in'];

    // The number of milliseconds until the auth token expires, default: 3,600,000
    int millisecondsToExpiration = int.parse(body['expires_in']) * 1000;
    int millisecondsSinceEpoch = DateTime.now().millisecondsSinceEpoch;

    int timeOfExpiration = millisecondsSinceEpoch + millisecondsToExpiration;

    StorageUtil.putString('access_token', accessToken);
    StorageUtil.putInt('expires_in', timeOfExpiration);
  }

  /// Updates the users username
  static Future<void> _requestUsername() async {
    await _checkTokenExpiration();

    final Response response = await get(
      'https://api.spotify.com/v1/me',
      headers: {
        'Authorization': 'Bearer ${StorageUtil.getString('access_token')}',
      },
    );

    String username = jsonDecode(response.body)['display_name'];
    StorageUtil.putString('username', username);
  }

  /// Returns Spotify search results for songs matching the specified query
  static Future<void> getSearchResults(String query) async {
    await _checkTokenExpiration();

    final String url = Uri.encodeFull('https://api.spotify.com/v1/search?q=' +
        query + '&type=track&market=US');
    final Response response = await get(
      url,
      headers: {
        'Authorization': 'Bearer ${StorageUtil.getString('access_token')}',
      },
    );

    return jsonDecode(response.body);
  }
}
  /*

  Future<Map<String, dynamic>> getSearchResults(String query,
      String token) async {
    // Allows query with spaces
    query.replaceAll(' ', '%20');

    Map<String, dynamic> map;
    return client
        .get(
        'https://api.spotify.com/v1/search?q=' +
            query +
            '&type=track&market=US',
        headers: authHeaders(token))
        .then<Map<String, dynamic>>((Response response) {
      if (response.body != '' && response.statusCode == 200) {
        map = json.decode(response.body)['tracks'];
      } else if (response.statusCode == 401) {
        // Token expired
        return null;
      }
      return map;
    }).catchError((Object error) {
      print(error);
      return null;
    });
  }
}
   */
