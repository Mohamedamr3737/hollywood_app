import 'package:shared_preferences/shared_preferences.dart';

Future<void> storeTokens(String accessToken, int expiresIn) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Get the current time
  DateTime now = DateTime.now();

  // Calculate the expiration time of the access token
  DateTime expiryTime = now.add(Duration(seconds: expiresIn));

  // Store tokens and expiration time
  await prefs.setString('access_token', accessToken);
  await prefs.setString('access_token_expiry', expiryTime.toIso8601String());
}
