import 'package:cloud_functions/cloud_functions.dart';
import 'package:spotify_queue/backend/spotify.dart';
import 'package:spotify_queue/backend/storageUtil.dart';

class Functions {

  static final HttpsCallable _generateRoomCallable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'generateRoom');
  static final HttpsCallable _closeRoomCallable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'closeRoom');
  static final HttpsCallable _addSongCallable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'addSong');
  static final HttpsCallable _joinRoomCallable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'joinRoom');
  static final HttpsCallable _removeSongCallable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'removeSong');

  /// returns a room code if successful or null if not
  static Future<String> generateRoom(String username) async {
    // check that auth is still valid
    await Spotify.checkTokenExpiration();

    try {
      String accessToken = StorageUtil.getString('access_token');
      HttpsCallableResult response = await _generateRoomCallable.call(<String, dynamic>{
        'username': username,
        'accessToken': accessToken,
      });
      if (response.data['status'] == 'error') {
        print(response.data['error']);
        return null;
      }
      StorageUtil.putString('playlist_id', response.data['playlistId']);
      return response.data['roomCode'];
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future<bool> joinRoom(String queue) async {
    // check that auth is still valid
    await Spotify.checkTokenExpiration();

    try {
      HttpsCallableResult response = await _joinRoomCallable.call(<String, dynamic>{
        'roomCode': queue,
      });
      if (response.data['status'] == 'error') {
        print(response.data['error']);
        return false;
      }
      if (response.data['isRoomOpen']) {
        StorageUtil.putString('playlist_id', response.data['playlistId']);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<bool> closeRoom(String queue) async {
    // check that auth is still valid
    await Spotify.checkTokenExpiration();

    String accessToken = StorageUtil.getString('access_token');
    String playlistId = StorageUtil.getString('playlist_id');

    try {
      HttpsCallableResult response = await _closeRoomCallable.call(<String, dynamic>{
        'roomCode': queue,
        'playlistId': playlistId,
        'accessToken': accessToken,
      });
      StorageUtil.putString('playlist_id', '');
      return response.data['status'] == 'success';
    } catch (e) {
      print(e);
    }
    return false;
  }

  static Future<bool> addSong(String queue, String songUri) async {
    // check that auth is still valid
    await Spotify.checkTokenExpiration();

    try {
      String accessToken = StorageUtil.getString('access_token');
      String playlistId = StorageUtil.getString('playlist_id');

      HttpsCallableResult response = await _addSongCallable.call(<String, dynamic>{
        'roomCode': queue,
        'accessToken': accessToken,
        'songUri': songUri,
        'playlistId': playlistId,
      });
      if (response.data['status'] == 'error') {
        print(response.data['error']);
        return false;
      }
      return response.data['status'] == 'success';
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<bool> removeSong(String queue, String songUri) async {
    // check that auth is still valid
    await Spotify.checkTokenExpiration();

    try {
      String accessToken = StorageUtil.getString('access_token');
      String playlistId = StorageUtil.getString('playlist_id');

      HttpsCallableResult response = await _removeSongCallable.call(<String, dynamic>{
        'roomCode': queue,
        'accessToken': accessToken,
        'songUri': songUri,
        'playlistId': playlistId,
      });
      if (response.data['status'] == 'error') {
        print(response.data['error']);
        return false;
      }
      return response.data['status'] == 'success';
    } catch (e) {
      print(e);
      return false;
    }
  }

}