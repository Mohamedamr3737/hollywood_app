import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../view/login_page.dart';

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

Future<bool> isTokenExpired() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? expiryTimeString = prefs.getString('access_token_expiry');

  if (expiryTimeString != null) {
    DateTime expiryTime = DateTime.parse(expiryTimeString);
    DateTime now = DateTime.now();

    // Check if the token will expire in the next 5 minutes
    if (expiryTime.isBefore(now.add(Duration(minutes: 5)))) {
      return true; // Token is about to expire
    }
  }

  return false; // Token is still valid
}

  // Method to retrieve the access token from SharedPreferences
  Future<String?> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token'); // Retrieve the stored token
  }

Future<String?> refreshAccessToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? access_token = prefs.getString('access_token'); // Retrieve the stored token

  if (access_token != null) {
    // Make the request to refresh the access token
    var response = await http.post(
      Uri.parse('https://portal.ahmed-hussain.com/api/patient/auth/refresh'), // Replace with your API endpoint
      headers: {

          'Authorization': 'Bearer $access_token', // Add the Bearer token to the header
          'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      String newAccessToken = responseData['access_token'];
      int expiresIn = responseData['expires_in'];

      // Store the new access token and expiration time
      await storeTokens(newAccessToken, expiresIn);

      print("Access token refreshed successfully.");
      return newAccessToken; // Return the new access token
    } else {
      print('Failed to refresh access token: ${response.body}');
      // return null; // Token refresh failed
      Get.offAll(() => const LoginView());
    }
  }

  Get.offAll(() => const LoginView());
}





