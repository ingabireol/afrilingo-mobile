import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:afrilingo/features/profile/services/profile_service.dart';
import 'dart:math' as Math;

class GoogleAuthServiceNew {
  // Base URL for the backend API
  static const String baseUrl = 'http://10.0.2.2:8080/api/v1/auth';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId:
        '210719579165-a8rkvcijq26amrpvlkpqcn3n6vc8or4v.apps.googleusercontent.com',
  );

  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // Start the Google sign-in flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        return {'success': false, 'message': 'Sign in was canceled'};
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Extract name parts for better user experience
      final String displayName = googleUser.displayName ?? '';
      final List<String> nameParts = displayName.split(' ');
      final String firstName = nameParts.isNotEmpty ? nameParts.first : '';
      final String lastName =
          nameParts.length > 1 ? nameParts.skip(1).join(' ') : '';

      // Create request payload
      final payload = {
        'idToken': googleAuth.idToken,
        'email': googleUser.email,
        'firstName': firstName,
        'lastName': lastName,
        'photoUrl': googleUser.photoUrl,
      };

      print("Sending Google authentication request: $payload");

      // Send request to your backend
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/v1/auth/google/mobile'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      print("Google auth response: ${response.statusCode}, ${response.body}");

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          final token = data['accessToken'];

          if (token == null) {
            print("No token in response");
            return {
              'success': false,
              'message': 'No authentication token received from server',
            };
          }

          // Save authentication data to shared preferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
          await prefs.setString('auth_type', 'google');
          await prefs.setString('user_first_name', firstName);
          await prefs.setString('user_last_name', lastName);
          await prefs.setString('user_email', googleUser.email);

          // Save user role if available
          if (data['user'] != null && data['user']['role'] != null) {
            await prefs.setString('user_role', data['user']['role']);
          }

          // Save photo URL if available
          if (googleUser.photoUrl != null) {
            await prefs.setString('user_photo', googleUser.photoUrl ?? '');
          }

          // Check if user has a profile
          final hasProfile = await _checkUserProfileExists(token);

          return {
            'success': true,
            'message': 'Authentication successful',
            'user': {
              'displayName': displayName,
              'firstName': firstName,
              'lastName': lastName,
              'email': googleUser.email,
              'photoUrl': googleUser.photoUrl,
              'role': data['user'] != null ? data['user']['role'] : null,
            },
            'token': token,
            'hasProfile': hasProfile,
          };
        } catch (e) {
          print("Error parsing backend response: $e");
          return {
            'success': false,
            'message': 'Error processing server response: $e',
          };
        }
      } else {
        // Handle error responses
        String errorMessage = 'Authentication failed';
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (e) {
          print("Could not parse error response: $e");
        }

        print("Authentication failed: $errorMessage");
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      print("Google Sign-In error: $e");
      return {'success': false, 'message': "Google Sign-In error: $e"};
    }
  }

  Future<void> signOut() async {
    // Sign out from Google
    await _googleSignIn.signOut();

    // Clear local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_photo');
    await prefs.remove('user_id');
    await prefs.remove('user_role');
    await prefs.remove('auth_type');
  }

  // Check if user is signed in based on stored token
  Future<bool> isSignedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final authType = prefs.getString('auth_type');
    final token = prefs.getString('auth_token');

    // Only consider signed in if we have both a token and auth_type is google
    return authType == 'google' && token != null;
  }

  // Check if user has a profile
  Future<bool> _checkUserProfileExists(String? token) async {
    if (token == null) return false;

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/api/v1/profile/exists'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print("Profile check response: ${response.statusCode}, ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final exists = data['data'] ?? false;
        return exists == true;
      }

      return false;
    } catch (e) {
      print("Error checking profile existence: $e");
      return false;
    }
  }
}
