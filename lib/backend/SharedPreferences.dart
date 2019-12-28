import 'package:shared_preferences/shared_preferences.dart';

Future<void> setToken(String token) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('token', token);
}

Future<String> getToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('token');
}

Future<bool> tokenExists() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getKeys().contains('token');
}

Future<void> setUsername(String username) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('username', username);
}

Future<String> getUsername() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('username');
}

Future<bool> usernameExists() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getKeys().contains('username');
}
