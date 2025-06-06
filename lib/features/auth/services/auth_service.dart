import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:math' as Math;

class AuthService {
  // Base URL for API requests
  static const String baseUrl = 'http://10.0.2.2:8080/api/v1/auth';
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Google Sign-In
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // Google Sign-In process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return {'success': false, 'message': 'Google sign in was cancelled'};
      }

      // Get authentication credentials
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create the request to send to our backend
      final Map<String, dynamic> requestBody = {
        'idToken': googleAuth.idToken,
        'displayName': googleUser.displayName,
        'email': googleUser.email,
        'photoUrl': googleUser.photoUrl,
      };

      print('Google sign in request: $requestBody');

      // Send request to backend
      final response = await http.post(
        Uri.parse('$baseUrl/auth/google/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print(
          'Google sign in response: ${response.statusCode}, ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String? token = data['data']['token'];
        final bool isNewUser = data['data']['newUser'] ?? false;

        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
          await prefs.setString('auth_type', 'google');

          // Save Google user photo URL if available
          if (googleUser.photoUrl != null) {
            await prefs.setString('user_photo', googleUser.photoUrl ?? '');
          }

          // Check if user has a profile
          final bool hasProfile = await _checkUserProfileExists();

          return {
            'success': true,
            'token': token,
            'isNewUser': isNewUser,
            'hasProfile': hasProfile,
            'message': 'Google sign in successful',
          };
        }
      }

      return {
        'success': false,
        'message': 'Failed to authenticate with Google. Please try again.',
      };
    } catch (e) {
      print('Google sign in error: $e');
      return {'success': false, 'message': 'Error during Google sign in: $e'};
    }
  }

  // Sign In
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      print("Starting sign in with email: $email");
      final response = await http.post(
        Uri.parse('$baseUrl/authenticate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print("Sign in response: ${response.statusCode}, ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print("Sign in response data: $data");

        // The backend returns access_token not accessToken (see AuthenticationResponse.java)
        final String? token = data['access_token'];

        if (token == null) {
          print("No token found in response");
          return {
            'success': false,
            'message': 'No authentication token received'
          };
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setString('auth_type', 'email');

        // Save user info if available in the response
        if (data['user'] != null) {
          final user = data['user'];
          if (user['firstName'] != null) {
            await prefs.setString('user_first_name', user['firstName']);
          }
          if (user['lastName'] != null) {
            await prefs.setString('user_last_name', user['lastName']);
          }
          if (user['email'] != null) {
            await prefs.setString('user_email', user['email']);
          }
          if (user['role'] != null) {
            await prefs.setString('user_role', user['role']);
            print("Saved user role: ${user['role']}");
          }
        }

        // Check if user has a profile
        final bool hasProfile = await _checkUserProfileExists();

        return {
          'success': true,
          'token': token,
          'hasProfile': hasProfile,
          'message': 'Sign in successful',
        };
      } else {
        // Extract error message from response
        String message = 'Invalid email or password';
        try {
          final data = json.decode(response.body);
          message = data['message'] ?? message;
        } catch (e) {
          print("Error parsing error response: $e");
        }

        print("Sign in failed: $message");
        return {'success': false, 'message': message};
      }
    } catch (e) {
      print("Error during sign in: $e");
      return {'success': false, 'message': 'Error during sign in: $e'};
    }
  }

  // Check if user has a profile
  Future<bool> _checkUserProfileExists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) return false;

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
        // Make sure to check the actual data structure from your API
        final exists = data['data'] ?? false;
        return exists == true;
      }

      // If error or unexpected response, assume no profile exists
      return false;
    } catch (e) {
      print("Error checking profile existence: $e");
      // On error, assume no profile exists to ensure user creates one
      return false;
    }
  }

  // Sign up method
  Future<Map<String, dynamic>> signUp(
    String name,
    String email,
    String password,
  ) async {
    try {
      print("Starting signup with name: $name, email: $email");
      // Extract first name and last name from the full name
      final List<String> nameParts = name.trim().split(' ');
      final String firstName = nameParts.first;
      final String lastName = nameParts.length > 1
          ? nameParts.skip(1).join(' ')
          : ''; // Join the rest as last name or empty if none

      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'firstname':
              firstName, // Match the exact field name expected by the backend
          'lastname':
              lastName, // Match the exact field name expected by the backend
          'email': email,
          'password': password,
          'role': 'ROLE_USER' // Must match exact enum value in backend
        }),
      );

      print("Register response: ${response.statusCode}, ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        print("Register response data: $data");

        // The backend returns access_token not accessToken (see AuthenticationResponse.java)
        final token = data['access_token'];

        if (token == null) {
          print("No token found in response");
          return {
            'success': false,
            'message': 'No authentication token received'
          };
        }

        // Save token to shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setString('auth_type', 'email');

        // Save user name and email for easier access
        await prefs.setString('user_first_name', firstName);
        await prefs.setString('user_last_name', lastName);
        await prefs.setString('user_email', email);

        return {
          'success': true,
          'message': 'Registration successful',
          'token': token,
        };
      } else {
        // Extract error message from response
        String message = 'Registration failed';
        try {
          final data = json.decode(response.body);
          message = data['message'] ?? message;
        } catch (e) {
          print("Error parsing error response: $e");
        }

        print("Registration failed: $message");
        return {'success': false, 'message': message};
      }
    } catch (e) {
      print("Error during signup: $e");
      return {'success': false, 'message': 'Error during sign up: $e'};
    }
  }

  // Sign out method
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_role');
  }

  // Create admin user
  Future<Map<String, dynamic>> createAdmin(
    String firstName,
    String lastName,
    String email,
    String password,
  ) async {
    return signUp(firstName, email, password);
  }

  // Get current user role
  Future<String> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role') ?? 'USER';
  }

  // Check if user is admin
  Future<bool> isAdmin() async {
    try {
      final role = await getUserRole();
      return role == 'ROLE_ADMIN' || role == 'ADMIN';
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }

  // Save user role to shared preferences
  Future<void> saveUserRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', role);
  }

  // Convenience method for regular sign-up
  Future<Map<String, dynamic>> register(
      String firstName, String lastName, String email, String password) async {
    return signUp("$firstName $lastName", email, password);
  }

  // Add a diagnostic method to help debug authentication issues
  Future<Map<String, dynamic>> getAuthDiagnostics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> diagnostics = {};

      // Get token info
      final token = prefs.getString('auth_token');
      diagnostics['hasToken'] = token != null && token.isNotEmpty;
      if (token != null && token.isNotEmpty) {
        // Only show first 10 chars for security
        diagnostics['tokenPrefix'] =
            token.substring(0, Math.min(10, token.length)) + '...';
      }

      // Get user role
      diagnostics['userRole'] = prefs.getString('user_role') ?? 'Not set';

      // Get auth type
      diagnostics['authType'] = prefs.getString('auth_type') ?? 'Not set';

      // Get user info
      diagnostics['firstName'] =
          prefs.getString('user_first_name') ?? 'Not set';
      diagnostics['lastName'] = prefs.getString('user_last_name') ?? 'Not set';
      diagnostics['email'] = prefs.getString('user_email') ?? 'Not set';

      // Try to verify token with backend
      if (token != null) {
        try {
          final response = await http.get(
            Uri.parse('$baseUrl/me'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          ).timeout(const Duration(seconds: 5));

          diagnostics['backendTokenValid'] = response.statusCode == 200;
          diagnostics['backendResponseCode'] = response.statusCode;

          if (response.statusCode == 200) {
            try {
              final data = json.decode(response.body);
              diagnostics['backendUserData'] = data;
            } catch (e) {
              diagnostics['backendDataParseError'] = e.toString();
            }
          } else {
            diagnostics['backendErrorBody'] = response.body;
          }
        } catch (e) {
          diagnostics['backendError'] = e.toString();
        }
      }

      return diagnostics;
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}
