import 'dart:convert';
import 'package:spotify_queue/backend/storageUtil.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:http/http.dart';

class Spotify {
  static final String _clientID = '12e51e7fd567478db5db871585124355';
  static final String _clientSecret = '';
  static final String _callbackUrl = 'dev.budde.spotifyqueue';

  static final String _scope = 'user-read-private playlist-modify-public user-modify-playback-state streaming';

  static Future<void> init() async {

    // if this is the first login
    if (StorageUtil.getString('access_token') == '') {
      await _requestAccessToken();
    }


    if (StorageUtil.getString('username') == '') {
      await _requestUsername();
    }

    // Check if the token has expired and reAuthenticate
    await checkTokenExpiration();
    return;
  }

  static Future<void> checkTokenExpiration() async {
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
      String result = await FlutterWebAuth.authenticate(
          url: _constructUrl(), callbackUrlScheme: _callbackUrl).catchError((error) {
            print(error);
            return null;
      });
      return Uri.parse(result).queryParameters['code'];
  }

  /// Sets the initial access token, refresh token
  static Future<bool> _requestAccessToken() async {
    final String authCode = await _requestAuthCode();
    try {
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
      int millisecondsToExpiration = body['expires_in'] * 1000;
      int millisecondsSinceEpoch = DateTime
          .now()
          .millisecondsSinceEpoch;

      int timeOfExpiration = millisecondsSinceEpoch + millisecondsToExpiration;

      StorageUtil.putInt('expiration', timeOfExpiration);
      StorageUtil.putString('access_token', accessToken);
      StorageUtil.putString('refresh_token', refreshToken);
      return true;
    } catch (e) {
      return false;
    }
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

    String accessToken = body['access_token'];

    // The number of milliseconds until the auth token expires, default: 3,600,000
    int millisecondsToExpiration = body['expires_in'] * 1000;
    int millisecondsSinceEpoch = DateTime.now().millisecondsSinceEpoch;

    int timeOfExpiration = millisecondsSinceEpoch + millisecondsToExpiration;

    StorageUtil.putString('access_token', accessToken);
    StorageUtil.putInt('expires_in', timeOfExpiration);
  }

  /// Updates the users username
  static Future<void> _requestUsername() async {
    await checkTokenExpiration();

    final Response response = await get(
      'https://api.spotify.com/v1/me',
      headers: {
        'Authorization': 'Bearer ${StorageUtil.getString('access_token')}',
      },
    );

    String username = jsonDecode(response.body)['id'];
    StorageUtil.putString('username', username);
  }

  /// Returns Spotify search results for songs matching the specified query
  static Future<Map<String,dynamic>> getSearchResults(String query) async {
    await checkTokenExpiration();

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

  static Future<void> _setRepeatOff() async {
    await checkTokenExpiration();

    final String url = Uri.encodeFull('https://api.spotify.com/v1/me/player/repeat?state=off');
    await put(
      url,
      headers: {
        'Authorization': 'Bearer ${StorageUtil.getString('access_token')}',
      },
    );
  }

  static Future<void> _setShuffleOff() async {
    await checkTokenExpiration();

    final String url = Uri.encodeFull('https://api.spotify.com/v1/me/player/shuffle?state=false');
    await put(
      url,
      headers: {
        'Authorization': 'Bearer ${StorageUtil.getString('access_token')}',
      },
    );
  }

  static Future<bool> startPlaylist() async {
    await _setRepeatOff();
    await _setShuffleOff();

  }

  static Future<bool> play() async {
    await checkTokenExpiration();

    final String url = Uri.encodeFull('https://api.spotify.com/v1/me/player/play');
    await put(
      url,
      headers: {
        'Authorization': 'Bearer ${StorageUtil.getString('access_token')}',
      },
    );
    return true;
  }

  static Future<bool> pause() async {
    await checkTokenExpiration();

    final String url = Uri.encodeFull('https://api.spotify.com/v1/me/player/pause');
    await put(
      url,
      headers: {
        'Authorization': 'Bearer ${StorageUtil.getString('access_token')}',
      },
    );
    return true;
  }

  static Future<bool> next() async {
    await checkTokenExpiration();

    final String url = Uri.encodeFull('https://api.spotify.com/v1/me/player/next');
    await post(
      url,
      headers: {
        'Authorization': 'Bearer ${StorageUtil.getString('access_token')}',
      },
    );
    return true;
  }

  static Future<bool> previous() async {
    await checkTokenExpiration();

    final String url = Uri.encodeFull('https://api.spotify.com/v1/me/player/previous');
    await post(
      url,
      headers: {
        'Authorization': 'Bearer ${StorageUtil.getString('access_token')}',
      },
    );
    return true;
  }
}
