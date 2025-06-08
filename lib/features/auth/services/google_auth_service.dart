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
      print("Starting Google Sign-In process...");
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print("User canceled Google Sign-In");
        return {'success': false, 'message': 'Sign in was canceled'};
      }

      print("User signed in with Google: ${googleUser.email}");

      // Get authentication details from Google
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        print("Failed to obtain ID token from Google");
        return {
          'success': false,
          'message': 'Failed to obtain authentication token',
        };
      }

      print("Obtained Google ID token, sending to backend...");

      // Send the ID token to your backend
      final response = await http
          .post(
        Uri.parse('$baseUrl/google/mobile'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'idToken': idToken, 'platform': 'android'}),
      )
          .timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          print('Backend request timed out');
          return http.Response(
              '{"message":"Connection timed out. Please check your internet connection and try again."}',
              408);
        },
      );

      print("Backend response status: ${response.statusCode}");
      print("Backend response body: ${response.body}");

      if (response.statusCode == 200) {
        try {
          // Parse the response from the backend
          final Map<String, dynamic> data = json.decode(response.body);
          print("Backend response data: $data");

          // Store authentication data
          final prefs = await SharedPreferences.getInstance();

          // Store token from the response - backend uses access_token (see AuthenticationResponse.java)
          final String? token = data['access_token'];

          if (token == null) {
            print("Warning: No token in backend response");
            return {
              'success': false,
              'message': 'Authentication failed. Please try again later.'
            };
          }

          await prefs.setString('auth_token', token);
          print("Saved authentication token");

          // Save user role if available in the response
          if (data['user'] != null && data['user']['role'] != null) {
            await prefs.setString('user_role', data['user']['role']);
            print("Saved user role: ${data['user']['role']}");
          }

          // Parse name into first and last name
          final String displayName = googleUser.displayName ?? '';
          final List<String> nameParts = displayName.split(' ');
          final String firstName = nameParts.isNotEmpty ? nameParts.first : '';
          final String lastName =
              nameParts.length > 1 ? nameParts.skip(1).join(' ') : '';

          // Store Google profile data regardless of backend response
          await prefs.setString('user_name', displayName);
          await prefs.setString('user_first_name', firstName);
          await prefs.setString('user_last_name', lastName);
          await prefs.setString('user_email', googleUser.email);

          // Store profile picture if available
          if (googleUser.photoUrl != null && googleUser.photoUrl!.isNotEmpty) {
            await prefs.setString('user_photo', googleUser.photoUrl!);
            print("Saved Google profile picture: ${googleUser.photoUrl}");
          }

          await prefs.setString('auth_type', 'google');

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
            },
            'token': token,
            'hasProfile': hasProfile,
          };
        } catch (e) {
          print("Error parsing backend response: $e");
          return {
            'success': false,
            'message': 'Unable to complete sign-in. Please try again later.',
          };
        }
      } else {
        // Handle error responses
        String errorMessage = 'Authentication failed. Please try again.';
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;

          // Convert technical error messages to user-friendly ones
          if (errorMessage.contains('Connection refused') ||
              errorMessage.contains('refused') ||
              errorMessage.contains('10.0.2.2')) {
            errorMessage = 'Cannot connect to server. Please try again later.';
          }
        } catch (e) {
          print("Could not parse error response: $e");
        }

        print("Authentication failed: $errorMessage");
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      print("Google Sign-In error: $e");

      // Create user-friendly error message
      String userFriendlyMessage = "Sign in failed. Please try again.";

      if (e.toString().contains('network') ||
          e.toString().contains('socket') ||
          e.toString().contains('connection')) {
        userFriendlyMessage =
            "Network error. Please check your internet connection.";
      } else if (e.toString().contains('canceled') ||
          e.toString().contains('cancelled')) {
        userFriendlyMessage = "Sign in was canceled.";
      } else if (e.toString().contains('credentials')) {
        userFriendlyMessage =
            "Google sign-in failed. Please try again or use email login.";
      }

      return {'success': false, 'message': userFriendlyMessage};
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
